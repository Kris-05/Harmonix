import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;

class VideoService {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool isSendingFrames = false;
  SendPort? isolateSendPort;

  // 🎥 Initialize Camera
  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0],
        ResolutionPreset.medium,
      );
      await _cameraController!.initialize();
    } else {
      print("❌ No camera available.");
    }
  }

  // 🎥 Start Sending Frames
  Future<void> startSendingFrames() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print("❌ Camera not initialized.");
      return;
    }

    if (isSendingFrames) {
      print("⚠️ Frame sending already in progress.");
      return;
    }

    isSendingFrames = true;
    print("📡 Sending frames started...");

    // Spawn isolate for background frame sending
    _startFrameSending();
  }

  // 🛑 Stop Sending Frames
  Future<void> stopSendingFrames() async {
    if (!isSendingFrames) {
      print("⚠️ No frame sending in progress.");
      return;
    }

    isSendingFrames = false;
    isolateSendPort?.send('stop');
    print("🛑 Frame sending stopped.");
  }

  // 🎯 Start Isolate to Send Frames Continuously
  void _startFrameSending() async {
    final receivePort = ReceivePort();
    isolateSendPort = receivePort.sendPort;

    // Spawn isolate for continuous frame sending
    await Isolate.spawn(_sendFramesIsolate, receivePort.sendPort);

    // Listen for stop signal
    receivePort.listen((message) {
      if (message == 'stopped') {
        print("✅ Frame sending stopped by isolate.");
      }
    });
  }
}

// 🎥 Isolate to Capture Frames and Send to Backend
void _sendFramesIsolate(SendPort mainSendPort) async {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  bool keepSending = true;

  receivePort.listen((dynamic message) {
    if (message == 'stop') {
      keepSending = false;
      mainSendPort.send('stopped');
    }
  });

  // Send frames continuously until stopped
  while (keepSending) {
    try {
      // Simulate getting frame data (replace with real frame capture)
      String frameData = "frame_data_${DateTime.now().millisecondsSinceEpoch}";

      // Send frame to API
      await _sendFrameToAPI(frameData);
      await Future.delayed(const Duration(milliseconds: 200)); // 5 FPS
    } catch (e) {
      print("❌ Error sending frame: $e");
    }
  }
}

// 🚀 Send Frame to FastAPI Backend
Future<void> _sendFrameToAPI(String frameData) async {
  const String apiUrl = "http://192.168.1.100:8000/predict"; // Change to your API

  try {
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"frame": frameData}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("✅ Gesture Prediction: ${data['gesture']}");
    } else {
      print("❌ API Error: ${response.statusCode}");
    }
  } catch (e) {
    print("❌ Error sending frame to API: $e");
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image/image.dart' as img;

class VideoService {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool isSendingFrames = false;
  SendPort? isolateSendPort;
  ReceivePort? receivePort;
  bool isolateInitialized = false;

  // Initialize Camera
  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![0], // Back Camera
        ResolutionPreset.low, // Low resolution to reduce lag
      );

      await _cameraController!.initialize();
      print("Camera Initialized.");
    } else {
      print("No camera available.");
    }
  }

  // Start Sending Frames with Image Stream
  Future<void> startSendingFrames() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print("Camera not initialized.");
      return;
    }

    if (isSendingFrames) {
      print("Frame sending already in progress.");
      return;
    }

    isSendingFrames = true;
    print("Sending frames started...");

    // Start isolate only once
    if (!isolateInitialized) {
      await _startIsolate();
    }

    // Start image stream and send frames to isolate
    _cameraController!.startImageStream((CameraImage image) {
      if (isSendingFrames) {
        String frameData = _convertYUV420toBase64(image);
        isolateSendPort?.send(frameData);
      }
    });
  }

  // Stop Sending Frames
  Future<void> stopSendingFrames() async {
    if (!isSendingFrames) {
      print("No frame sending in progress.");
      return;
    }

    isSendingFrames = false;
    _cameraController?.stopImageStream(); // Stop the image stream
    isolateSendPort?.send('stop');
    print("Frame sending stopped.");
  }

  // Start Isolate for Frame Sending
  Future<void> _startIsolate() async {
    receivePort = ReceivePort();
    await Isolate.spawn(_sendFramesIsolate, receivePort!.sendPort);

    // Wait for the isolate to send its SendPort back
    isolateSendPort = await receivePort!.first as SendPort;
    isolateInitialized = true;
    print("Isolate started and ready to send frames.");
  }

  // Convert Camera Frame (YUV420) to Base64 PNG
  String _convertYUV420toBase64(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;

      // Create an empty RGB image
      final img.Image rgbImage = img.Image(width: width, height: height);

      // Convert YUV420 to RGB manually
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          final int uvIndex = (y >> 1) * width + (x & ~1);
          final int yValue = image.planes[0].bytes[y * width + x];
          final int uValue = image.planes[1].bytes[uvIndex];
          final int vValue = image.planes[2].bytes[uvIndex];

          // Convert YUV to RGB
          int r = (yValue + 1.402 * (vValue - 128)).toInt();
          int g = (yValue - 0.344 * (uValue - 128) - 0.714 * (vValue - 128)).toInt();
          int b = (yValue + 1.772 * (uValue - 128)).toInt();

          // Clamp values to valid range
          r = r.clamp(0, 255);
          g = g.clamp(0, 255);
          b = b.clamp(0, 255);

          // Set pixel with alpha (default to 255)
          rgbImage.setPixelRgba(x, y, r, g, b, 255);
        }
      }

      // Encode image as PNG and convert to Base64
      List<int> pngBytes = img.encodePng(rgbImage);
      String base64Image = base64Encode(pngBytes);
      return base64Image;
    } catch (e) {
      print("Error converting YUV to Base64: $e");
      return "";
    }
  }
}

// Send Frame to FastAPI Backend
Future<void> _sendFrameToAPI(String frameData) async {
  final String apiUrl = "http://192.168.137.117:8000/sendFrames";

  try {
    if (frameData.isEmpty) {
      print("Empty frame. Skipping...");
      return;
    }

    print("Sending frame to API...");
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"frame": frameData}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print("Gesture Prediction: ${data['gesture']}");
    } else {
      print("API Error: ${response.statusCode}");
    }
  } catch (e) {
    print("Error sending frame to API: $e");
  }
}

// Isolate for Frame Processing and API Sending
void _sendFramesIsolate(SendPort mainSendPort) async {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  bool keepSending = true;

  receivePort.listen((dynamic message) async {
    if (message == 'stop') {
      keepSending = false;
      print("Isolate stopping...");
    } else if (message is String) {
      await _sendFrameToAPI(message);
    }
  });

  while (keepSending) {
    await Future.delayed(const Duration(milliseconds: 200)); // Prevent CPU overload
  }
}

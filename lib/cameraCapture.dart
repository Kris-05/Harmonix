import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as imglib;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class VideoService {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  bool isSendingFrames = false;
  SendPort? isolateSendPort;
  ReceivePort? receivePort;
  bool isolateInitialized = false;
  IO.Socket? socket;


  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(
        cameras![1], // Front camera
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _cameraController!.initialize();
      print("Camera Initialized: ${_cameraController!.value.previewSize}");
    } else {
      print("No camera available.");
    }
  }


  void connectSocket() {
    socket = IO.io('http://192.168.254.28:8000/ws/socket.io/', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket!.connect();

    socket!.onConnect((_) {
      print(" WebSocket connected");
    });

    socket!.onDisconnect((_) => print(" WebSocket disconnected"));

    socket!.onError((error) {
      print(" WebSocket connection error: $error");
    });
  }


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
    print(" Sending frames started...");

    if (!isolateInitialized) {
      await _startIsolate();
    }

    _cameraController!.startImageStream((CameraImage image) {
      if (isSendingFrames) {
        isolateSendPort?.send(image);
      }
    });
  }

  Future<void> stopSendingFrames() async {
    if (!isSendingFrames) {
      print(" No frame sending in progress.");
      return;
    }

    isSendingFrames = false;
    _cameraController?.stopImageStream();
    isolateSendPort?.send('stop');
    print(" Frame sending stopped.");
  }


  Future<void> _startIsolate() async {
    receivePort = ReceivePort();
    await Isolate.spawn(_sendFramesIsolate, receivePort!.sendPort);

    receivePort!.listen((dynamic message) {
      if (message is SendPort) {
        isolateSendPort = message;
        isolateInitialized = true;
        print(" Isolate started and ready to send frames.");
      }
    });
  }
}


Uint8List convertYUV420toRGB(CameraImage image) {
  final int width = image.width;
  final int height = image.height;

  final Plane yPlane = image.planes[0];
  final Plane uPlane = image.planes[1];
  final Plane vPlane = image.planes[2];

  final int uvRowStride = uPlane.bytesPerRow;
  final int uvPixelStride = uPlane.bytesPerPixel!;

  final imglib.Image img = imglib.Image(width: width, height: height);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final int yIndex = y * yPlane.bytesPerRow + x;
      final int uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;

      final int yp = yPlane.bytes[yIndex];
      final int up = uPlane.bytes[uvIndex];
      final int vp = vPlane.bytes[uvIndex];

      // Convert YUV to RGB
      int r = (yp + vp * 1.402 - 179).round().clamp(0, 255);
      int g = (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128))
          .round()
          .clamp(0, 255);
      int b = (yp + 1.772 * (up - 128)).round().clamp(0, 255);

      img.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  return Uint8List.fromList(imglib.encodeJpg(img));
}

void _sendFramesIsolate(SendPort mainSendPort) async {
  final receivePort = ReceivePort();
  mainSendPort.send(receivePort.sendPort);

  IO.Socket? socket;

  socket = IO.io('http://192.168.254.28:8000/', <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': true,
  });

  socket.connect();

    socket.onConnect((_) {
    print(" Socket Concected to Back..");
  });

  socket.onConnectError((error) {
    print("  Error: $error");
  });

  socket.onError((error) {
    print(" IO Error: $error");
  });

  socket!.onDisconnect((_) {
    print(" Disconnected from Socket!!..");
  });
    


  receivePort.listen((dynamic message) async {
    if (message == 'stop') {
      print(" Isolated Thread stopping...");
    } else if (message is CameraImage) {
      final Uint8List rgbBytes = convertYUV420toRGB(message);
      if (rgbBytes.isNotEmpty) {
        print(socket);
        if (socket != null && socket.connected) {
          socket.emit('frame', rgbBytes); // Emit frames
          print(" Frame sent through WebSocket");
        } else {
          print(" WebSocket not connected.");
        }
      } else {
        print(" Skipping frame coz! conversion error.");
      }
    }
  });
}

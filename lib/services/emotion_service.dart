import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; 

class EmotionService {
  static const String _baseUrl = 'http://localhost:8000'; // Android emulator
  // static const String _baseUrl = 'http://localhost:8000'; // iOS simulator
  // static const String _baseUrl = 'http://YOUR_LOCAL_IP:8000'; // Physical device

  static Future<Map<String, dynamic>?> detectEmotion(XFile imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/detect-emotion'),
      );
      
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ));

      var response = await request.send();
      
      if (response.statusCode == 200) {
        return json.decode(await response.stream.bytesToString());
      } else {
        final error = await response.stream.bytesToString();
        throw Exception('Failed to detect emotion: $error');
      }
    } catch (e) {
      print('Error in EmotionService: $e');
      rethrow;
    }
  }
}


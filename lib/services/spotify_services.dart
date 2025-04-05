import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyService {
  static String _accessToken = "";
  static DateTime _tokenExpiry = DateTime.now();

  // Emotion to query mapping
  static const _emotionToQuery = {
    'happy': 'genre:pop mood:happy',
    'sad': 'genre:blues mood:sad',
    'angry': 'genre:metal mood:aggressive',
    'neutral': 'genre:indie',
  };

  static String _getQueryForEmotion(String emotion) {
    return _emotionToQuery[emotion.toLowerCase()] ?? 'mood:${emotion.toLowerCase()}';
  }

  static Future<List<dynamic>> getTracksByEmotion(String emotion) async {
    final accessToken = await getAccessToken();
    final query = _getQueryForEmotion(emotion);
    
    final url = Uri.parse(
      "https://api.spotify.com/v1/search?q=$query&type=track&limit=50&market=US"
    );

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['tracks']['items'] ?? [];
    }
    throw Exception('Failed to load tracks by emotion');
  }

  static Future<List<dynamic>> getTracksByAudioFeatures(String emotion) async {
    final accessToken = await getAccessToken();
    
    // Emotion to audio features mapping
    final features = {
      'happy': {'valence': 0.7, 'energy': 0.7, 'danceability': 0.7},
      'sad': {'valence': 0.3, 'energy': 0.3, 'acousticness': 0.7},
      'angry': {'energy': 0.9, 'valence': 0.3, 'loudness': -5},
      'neutral': {'valence': 0.5, 'energy': 0.5},
    }[emotion.toLowerCase()] ?? {};

    // Build query parameters
    final params = features.entries
        .map((e) => 'target_${e.key}=${e.value}')
        .join('&');
    
    final url = Uri.parse(
      "https://api.spotify.com/v1/recommendations?limit=50&market=US&$params"
    );

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json"
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['tracks'] ?? [];
    }
    throw Exception('Failed to load recommended tracks');
  }

  static Future<void> fetchAccessToken() async {
    final String clientId = "0ca75692e8f2445d9f983c10e451c244";
    final String clientSecret = "23184296d0e845a2b1360b0b97c0f15e";
    final String credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

    final response = await http.post(
      Uri.parse("https://accounts.spotify.com/api/token"),
      headers: {
        "Authorization": "Basic $credentials",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: "grant_type=client_credentials",
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      _tokenExpiry = DateTime.now().add(Duration(seconds: data['expires_in']));
      print("New Access Token: $_accessToken");
    } else {
      print("Error getting token: ${response.statusCode}");
    }
  }

  static Future<String> getAccessToken() async {
    if (_accessToken.isEmpty || DateTime.now().isAfter(_tokenExpiry)) {
      await fetchAccessToken();
    }
    return _accessToken;
  }
}

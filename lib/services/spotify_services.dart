import 'dart:convert';
import 'package:http/http.dart' as http;

class SpotifyService {
  // Fetches and Store - access token and its expiration time.
  static String _accessToken = "";
  static DateTime _tokenExpiry = DateTime.now();

  static Future<void> fetchAccessToken() async {
    // encode client credentials
    final String clientId = "0ca75692e8f2445d9f983c10e451c244";
    final String clientSecret = "23184296d0e845a2b1360b0b97c0f15e";
    final String credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));

    // send post req to get access token
    final response = await http.post(
      Uri.parse("https://accounts.spotify.com/api/token"),
      headers: {
        "Authorization": "Basic $credentials",
        "Content-Type": "application/x-www-form-urlencoded",
      },
      // tells Spotify to return a token for non-user authentication.
      body: "grant_type=client_credentials",
    );
 
    // handle response
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
      _tokenExpiry = DateTime.now().add(Duration(seconds: data['expires_in']));
      print("New Access Token: $_accessToken");
    } else {
      print("Error getting token: ${response.statusCode}");
    }
  }

  // for checking and using the token
  static Future<String> getAccessToken() async {
    if (_accessToken.isEmpty || DateTime.now().isAfter(_tokenExpiry)) {
      await fetchAccessToken();
    }
    return _accessToken;
  }

  // Fetch top artists from Spotify
  static Future<List<Map<String, dynamic>>> getTopArtists() async {
    final String token = await getAccessToken();

    final response = await http.get(
      Uri.parse("https://api.spotify.com/v1/browse/new-releases"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> items = data['albums']['items'];

      return items.map((item) {
        return {
          "name": item['artists'][0]['name'],  // Get the first artist's name
          "imgPath": item['images'][0]['url'], // Album image as artist image
        };
      }).toList();
    } else {
      throw Exception("Failed to fetch artists: ${response.body}");
    }
  }
}
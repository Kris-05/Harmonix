import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:spotify_ui/services/spotify_service.dart';

class Spotify {

  static Future<Map<String,dynamic>?> getSongInfo(String songId)async {

    try{
            String accessToken = await SpotifyService.getAccessToken();
            String url = "https://api.spotify.com/v1/tracks/$songId";

            final response = await http.get(
              Uri.parse(url),
              headers: {
                "Authorization": "Bearer $accessToken",
                "Content-Type": "application/json"
              },
            );
            if (response.statusCode == 200) {
            var data = jsonDecode(response.body);
            print("Song Name: ${data['name']}");
            print("Artist: ${data['artists'][0]['name']}");
            print("Album Name: ${data['album']['name']}");
            print("Album Image URL: ${data['album']['images'][0]['url']}");
            return data;
          } else {
            return null;
          }
    }
    catch(err){
      return null;
    }
  }



}
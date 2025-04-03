import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Playlistapi {
    static String _url =dotenv.env['API_URL'] ?? 'http://127.0.0.1:8000';

  static Future<Map<String,dynamic>> createPlaylistApi({String? playListName,String? email="sakthi@gmail.com"})async{
      print("playlist Create Api Called!!!, /playlist/createPlaylist");

      
      try{
        final response = await http.post(
        Uri.parse("$_url/playlist/createPlaylist"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name':playListName,
          'email':email
        }),
      );

      if(response.statusCode==200){
        print("Ok!!");
        return jsonDecode(response.body);
      }
      else{
        throw Exception("error occured:${response.body}");
      }
      }
      catch(err){
        return {"error": err.toString()};
      }
  }

  static Future<Map<String,dynamic>> deletePlaylist({String? playListName,String? email="sakthi@gmail.com", required String id}) async {
       
       try{
        final res = await http.post(
          Uri.parse("$_url/playlist/deletePlaylist"),headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name':playListName,
          'email':email,
          'id':id
        }),
        );
      if(res.statusCode==200){
              print("Ok!!");
              return jsonDecode(res.body);
            }
            else{
              throw Exception("error occured:${res.body}");
            }
            }
            catch(err){
              return {"error": err.toString()};
         }
  }

  static Future<Map<String,dynamic>> addToPlaylist({String? id,List<dynamic>? songs, required String email}) async {
          
          try{
            final res=await http.post(Uri.parse("$_url/playlist/addToPlaylist"),headers: {
                'Content-Type': 'application/json',
                },
                body: jsonEncode({
                  "songs":songs,
                  'id':id,
                  'email':email
                }),);

            if(res.statusCode==200){
              print("Ok!!");
              return jsonDecode(res.body);
            }
            else{
              throw Exception("error occured:${res.body}");
            }


          }
          catch(err){
            throw Exception(err.toString());
          }

  }

static Future<List<dynamic>> getPlayListSongs({required String id,required String email,
      }) async {
        try {
          final res = await http.post(
            Uri.parse("$_url/playlist/getSongsPlayList"),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': email,
              'id': id,
            }),
          );

          if (res.statusCode == 200) {
            print("Songs Retrieved Successfully!");
            final data = jsonDecode(res.body);

            if (data.containsKey('songs')) {
              return data['songs'];
            } else {
              throw Exception("No songs found in the response!");
            }
          } else {
            throw Exception("Error occurred: ${res.body}");
          }
        } catch (err) {
          print("Error fetching playlist: $err");
          return []; 
          }
        }

static Future<bool> isPlaylistLiked({
    required String id,
    required String email,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$_url/playlist/isLiked"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'id': id,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data.containsKey('isLiked')) {
          return data['isLiked'] ?? false;
        } else {
          throw Exception("Error: 'isLiked' not found in response.");
        }
      } else {
        throw Exception("Error occurred: ${res.body}");
      }
    } catch (err) {
      print("Error fetching isLiked: $err");
      throw Exception("Error checking isLiked");
    }
  }


static Future<void> ChangeLike({
    required String id,
    required String email,
  }) async {
    try {
      final res = await http.post(
        Uri.parse("$_url/playlist/changeLike"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'id': id,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
      } else {
        throw Exception("Error occurred: ${res.body}");
      }
    } catch (err) {
      print("Error fetching isLiked: $err");
      throw Exception("Error checking isLiked");
    }
  }

static Future<List<dynamic>> fetchAllPlaylist({required String email}) async {
  try {
    final res = await http.get(
      Uri.parse("$_url/playlist/getAllPlaylists?email=$email"),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      final data=jsonDecode(res.body);
      return data['playlist'];

    } else {
      throw Exception("Error occurred: ${res.body}");
    }
  } catch (err) {
    print("Error fetching all playlists: $err");
    return [];
  }
}
}




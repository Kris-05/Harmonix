import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class Auth{
   
  static Future<Map<String,dynamic> > createAccountApi({required String name,required String password,required String gender,required String email,required List<String> languages}) async{
    print(" $name ,$password,$email,$gender");

    final String url =dotenv.env['API_URL'] ?? 'http://127.0.0.1:8000';

    try {
      final response = await http.post(
        Uri.parse("$url/createAccount"),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "name": name,
          "gender": gender,
          "password": password,
          "email": email,
          "preferred_languages":languages
        }),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        print("Account created successfully: ${response.body}");
        return jsonDecode(response.body);
      } else {
        print("Error: ${response.body}");
        throw Exception(response.body);
      }
    } catch (e) {
      print("Exception: $e");
      return {"error": e.toString()};
    }

  }

  static Future<Map<String,dynamic>> loginApi ({required String email,required String password}) async {

          final url=dotenv.env['API_URL'] ?? 'http://127.0.0.1:8000';

          try{

            print("Login Route Called....");
            
            final res= await http.post(
              Uri.parse("$url/login"),
              headers: {
                'Content-Type': 'application/json',
            },
            body: jsonEncode({
              "password": password,
              "email": email,
            }),
            );
          
            print(res.statusCode);
            if (res.statusCode == 200) {
              print("Account Logged In successfully: ${res.body}");
              return jsonDecode(res.body);
            } else {
              print("Error: ${res.body}");
              throw Exception(res.body);
            }
          } catch (e) {
            throw  Exception(e);
          }
        }

}
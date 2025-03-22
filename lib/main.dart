
import 'package:flutter/material.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


// Yov Krishnaa Olungaa Comment pannu daaa
// Oru Mairum Purila....

void main() async {
   await dotenv.load(fileName: "lib/.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harmonix',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      routes: AppRoutes.getRoutes(),
      initialRoute: AppRoutes.splashPage,
    );
  }
}


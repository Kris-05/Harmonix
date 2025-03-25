import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';


// Yov Krishnaa Olungaa Comment pannu daaa
// Oru Mairum Purila....

// void main() async {
//    await dotenv.load(fileName: "lib/.env");
//   runApp(const MyApp());
// }

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harmonix',
      debugShowCheckedModeBanner: false,  //to remove debug banner
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.blackColor,
          selectedItemColor: Colors.green, // Active tab color
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold), // Active text style
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        )
      ),
      routes: AppRoutes.getRoutes(),
      initialRoute: AppRoutes.splashPage,
    );
  }
}


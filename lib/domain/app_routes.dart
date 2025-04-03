// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:spotify_ui/ui/dashboard/songs/widgets/music_player.dart';
import 'package:spotify_ui/ui/login/choose_artist.dart';
import 'package:spotify_ui/ui/dashboard/home_page.dart';
import 'package:spotify_ui/ui/intro/intro_page.dart';
import 'package:spotify_ui/ui/login/create_accout.dart';
import 'package:spotify_ui/ui/login/name_page.dart';
import 'package:spotify_ui/ui/splash/splash_page.dart';
import 'package:spotify_ui/ui/login/login.dart';

class AppRoutes {
  // These are the Routes...
  static const String splashPage = "/";
  static const String introPage = "/intro";
  static const String createAccountPage = "/create_account";
  static const String namePage = "create_account/name";
  static const String loginPage='/login';
  static const String artistPage = "/choose_artist";
  static const String homePage = "/home";
  static const String songsPage = "/songs";

// This Mapping Routing.....
  static Map<String, Widget Function(BuildContext)> getRoutes () => {
    splashPage: (context) => SplashPage(),
    introPage: (context) => IntroPage(),
    createAccountPage: (context) => CreateAccout(),
    namePage: (context) => NamePage(),
    loginPage:(context)=>Login(),
    artistPage: (context) => ChooseArtist(),
    homePage: (context) => HomePage(),
  };

  // Handle dynamic routes
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case songsPage:
        // Expect a Map<String, dynamic> as arguments
        final args = settings.arguments as Map<String, dynamic>?; 
        if (args != null && args.containsKey('trackId')) {
          final trackId = args['trackId'] as String; // Extract trackId
          return MaterialPageRoute(
            builder: (context) => MusicPlayer(trackId: trackId),
          );
        }
        return _errorRoute(); // Return error if args are not valid
      default:
        return null; // Unknown route
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        body: Center(child: Text("Page not found")),
      ),
    );
  }
}

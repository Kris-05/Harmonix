import 'package:flutter/widgets.dart';
import 'package:spotify_ui/ui/login/choose_artist.dart';
import 'package:spotify_ui/ui/dashboard/home_page.dart';
import 'package:spotify_ui/ui/intro/intro_page.dart';
import 'package:spotify_ui/ui/login/create_accout.dart';
import 'package:spotify_ui/ui/login/name_page.dart';
import 'package:spotify_ui/ui/splash/splash_page.dart';
import 'package:spotify_ui/ui/login/login.dart';
import 'package:spotify_ui/cameraCapture.dart';

class AppRoutes {
  // These are the Routes...
  static const String splashPage = "/";
  static const String introPage = "/intro";
  static const String createAccountPage = "/create_account";
  static const String namePage = "create_account/name";
  static const String loginPage = '/login';
  static const String artistPage = "/choose_artist";
  static const String homePage = "/home";

  // This Mapping Routing.....
  static Map<String, Widget Function(BuildContext)> getRoutes(VideoService videoService) => {
        splashPage: (context) => SplashPage(),
        introPage: (context) => IntroPage(videoService: videoService),
        createAccountPage: (context) => CreateAccout(),
        namePage: (context) => NamePage(),
        loginPage: (context) => Login(),
        artistPage: (context) => ChooseArtist(),
        homePage: (context) => HomePage(),
      };
}

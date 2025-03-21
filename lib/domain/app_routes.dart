import 'package:flutter/widgets.dart';
import 'package:spotify_ui/ui/intro/intro_page.dart';
import 'package:spotify_ui/ui/login/create_accout.dart';
import 'package:spotify_ui/ui/login/name_page.dart';
import 'package:spotify_ui/ui/splash/splash_page.dart';

class AppRoutes {
  static const String splashPage = "/";
  static const String introPage = "/intro";
  static const String createAccountPage = "/create_account";
  static const String namePage = "create_account/name";

  static Map<String, Widget Function(BuildContext)> getRoutes () => {
    splashPage: (context) => SplashPage(),
    introPage: (context) => IntroPage(),
    createAccountPage: (context) => CreateAccout(),
    namePage: (context) => NamePage(),
  };
}

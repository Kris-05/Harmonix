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
import 'package:spotify_ui/cameraCapture.dart';
import 'package:spotify_ui/ui/dashboard/library/playlist_specific_page.dart';
import 'package:spotify_ui/ui/dashboard/library/create_playlist.dart';

class AppRoutes {
  // These are the Routes...
  static const String splashPage = "/";
  static const String introPage = "/intro";
  static const String createAccountPage = "/create_account";
  static const String namePage = "create_account/name";
  static const String loginPage = '/login';
  static const String artistPage = "/choose_artist";
  static const String homePage = "/home";
  static const String songsPage = "/songs";
  static const String playListSpecific ="/PlayListSpecific";
  static const String createPlaylist ="/createPlaylist";

// This Mapping Routing.....
  static Map<String, Widget Function(BuildContext)> getRoutes(VideoService videoService) => {
    splashPage: (context) => SplashPage(),
    introPage: (context) => IntroPage(videoService: videoService),
    createAccountPage: (context) => CreateAccout(),
    namePage: (context) => NamePage(),
    loginPage:(context)=>Login(),
    artistPage: (context) => ChooseArtist(),
    homePage: (context) => HomePage(),
    createPlaylist:(context){
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return CreatePlaylist(fetchPl: args['onPlaylistCreated']);
    },
        
    playListSpecific: (context) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return PlaylistSpecificPage(
        isLiked: args['isLiked'],
        bgColor:args['BgColor'],
        playListName: args['playListName'],
        id: args['id'],
        onUpdate:args['onUpdate']
      );
    },
  };

  // Handle dynamic routes
 static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case songsPage:
      final args = settings.arguments as Map<String, dynamic>?;

      if (args != null &&
          args['trackId'] is String &&
          args['isLocal'] is bool &&
          args['audioQueue'] is List) {
        
        final trackId = args['trackId'] as String;
        final isLocal = args['isLocal'] as bool;
        final audioQueue = List<Map<String, String>>.from(args['audioQueue']);

        // Optional values
        final pre = args['pre'] as String? ?? '';
        final nxt = args['nxt'] as String? ?? '';

        return MaterialPageRoute(
          builder: (context) => MusicPlayer(
            trackId: trackId,
            pre: pre,
            nxt: nxt,
            isLocal: isLocal,
            audioQueue: audioQueue,
          ),
        );
      }

      return _errorRoute();

    default:
      return null;
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

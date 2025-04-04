import 'package:flutter/material.dart';
import 'package:spotify_ui/ui/dashboard/songs/model/Music.dart';

class LyricsPage extends StatelessWidget {
  final Music music;

  const LyricsPage({
    super.key, 
    required this.music
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [music.songColor ?? Color.fromARGB(255, 78, 47, 56), const Color(0xff121212)] // gradient from top to bottom
        )
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Make Scaffold transparent
        body: Center(
          child: const Text("Lyric Page", style: TextStyle(color: Colors.white),),
        ),
      ),
    );
  }
}
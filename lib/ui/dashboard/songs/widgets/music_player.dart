import 'package:flutter/material.dart';
import 'package:spotify_ui/domain/app_colors.dart';

class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    String songName = args?['songName'] ?? "Unknown Song";
    String artistName = args?['artistName'] ?? "Unknown Artist";
    String imgPath = args?['imgPath'] ?? "assets/images/placeholder.jpg"; 


    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        title: Text("Now PLaying"),
        backgroundColor: AppColors.blackColor,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imgPath, width: 150, height: 150, fit: BoxFit.cover),
          SizedBox(height: 20),
          Text(songName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(artistName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: (){},
                icon: Icon(Icons.skip_previous, size: 40, color: Colors.white,)
              ),
              IconButton(
                onPressed: (){},
                icon: Icon(Icons.play_arrow, size: 40, color: Colors.white,)
              ),
              IconButton(
                onPressed: (){},
                icon: Icon(Icons.skip_next, size: 40, color: Colors.white,)
              ),
            ]
          )
        ],
      ),
    );
  }
}
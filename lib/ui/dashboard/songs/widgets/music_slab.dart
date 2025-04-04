import 'package:flutter/material.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/ui_helper.dart';

class MusicSlab extends StatefulWidget {
  final String songName;
  final String artistName;
  final String imgPath;

  const MusicSlab({
    super.key,
    required this.songName,
    required this.artistName,
    required this.imgPath,
  });

  @override
  State<MusicSlab> createState() => _MusicSlabState();
}

class _MusicSlabState extends State<MusicSlab> {

  bool isLiked = false;
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.pushNamed(
          context, 
          AppRoutes.songsPage,
          arguments: {
            'songName': widget.songName,
            'artistName': widget.artistName,
            'imgPath': widget.imgPath,
          },
        );
      },
      child: Container(
        height: 66,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 232, 185, 241)
        ),
        padding: EdgeInsets.all(9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              //  Container(
              //     width: 48,
              //     decoration: BoxDecoration(
              //       image: DecorationImage(
              //         image: AssetImage("assets/images/Afterburner.png"),
              //         fit: BoxFit.cover, 
              //       ),
              //     ),
              //   ),
                Image.asset(widget.imgPath, width: 48, height: 48, fit: BoxFit.cover),
                mSpacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.songName, style: TextStyle(fontSize: 14, color: AppColors.whiteColor, fontWeight: FontWeight.w500)),
                    Text(widget.artistName, style: TextStyle(fontSize: 12, color: AppColors.greyColor, fontWeight: FontWeight.w500)),
                  ],
                )
              ],
            ),
        
            Row(children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    isLiked = !isLiked; 
                  });
                },
                icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
                color: isLiked ? AppColors.primaryColor : AppColors.whiteColor, 
                iconSize: 25,
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    isPlaying = !isPlaying; 
                  });
                },
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow), 
                color: AppColors.whiteColor,
                iconSize: 30,
              ),
            ])
          ]
        ),
      ),
    );
  }
}
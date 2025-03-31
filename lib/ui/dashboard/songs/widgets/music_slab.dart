import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/providers/music_provider.dart';

class MusicSlab extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {

    final musicState = ref.watch(musicProvider);
    final musicNotifier = ref.read(musicProvider.notifier);

    return GestureDetector(
      onTap: (){
        // Update global state when clicking the MusicSlab
        musicNotifier.setSong(songName, artistName, imgPath);
        Navigator.pushNamed(context, AppRoutes.songsPage);
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
                Image.asset(imgPath, width: 48, height: 48, fit: BoxFit.cover),
                mSpacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(songName, style: TextStyle(fontSize: 14, color: AppColors.whiteColor, fontWeight: FontWeight.w500)),
                    Text(artistName, style: TextStyle(fontSize: 12, color: AppColors.greyColor, fontWeight: FontWeight.w500)),
                  ],
                )
              ],
            ),
        
            Row(children: [
              IconButton(
                onPressed: () {
                   musicNotifier.toggleLike(); // Updated to use Riverpod
                },
                icon: Icon(musicState.isLiked ? Icons.favorite : Icons.favorite_border),
                color: musicState.isLiked ? AppColors.primaryColor : AppColors.whiteColor, 
                iconSize: 25,
              ),
              IconButton(
                 onPressed: () {
                  musicNotifier.togglePlayPause(); // Updated to use Riverpod
                },
                icon: Icon(musicState.isPlaying ? Icons.pause : Icons.play_arrow),
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_ui/providers/music_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/ui_helper.dart';

class SongsPage extends ConsumerWidget {
  const SongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // ignore: unused_local_variable
    final selectedSong = ref.watch(musicProvider);
    
    final musicNotifier = ref.read(musicProvider.notifier);

    final List<Map<String, dynamic>> mRecentPlayedList = [
      {
        "imgPath": "assets/images/Afterburner.png",
        "name": "One - Metallica",
        "artist": "1(Remastered)"
      },
      {
        "imgPath": "assets/images/Anthem.png",
        "name": "Summertime Sadness",
        "artist": "Lana Del Rey"
      },
      {
        "imgPath": "assets/images/Artists.png",
        "name": "Let's Get It On",
        "artist": "Marvin Gaye"
      },
      {
        "imgPath": "assets/images/Bryce_Vine.png",
        "name": "Drew Barrymore",
        "artist": "Indie Pop"
      },
    ];

    final List<Map<String, dynamic>> mEditorPicksList = [
      {
        "imgPath": "assets/images/Afterburner.png",
        "name": "Shape of You",
        "artist": "Ed Sheeran"
      },
      {
        "imgPath": "assets/images/Anthem.png",
        "name": "Circles",
        "artist": "Post Malone"
      },
      {
        "imgPath": "assets/images/Artists.png",
        "name": "I Don't Fuck With You",
        "artist": "Big Sean"
      },
      {
        "imgPath": "assets/images/Bryce_Vine.png",
        "name": "Heat Waves",
        "artist": "Glass Animals"
      },
    ];

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.blackColor,
        body: Column(
          children: [
            mSpacer(),
            recentlyPlayedUI(), // top bar
            mSpacer(),
            recentlyPlayedList(mRecentPlayedList, musicNotifier), // recently played
            playListUI(),
            mSpacer(mHeight: 20),
            editorPicksUI(mEditorPicksList, musicNotifier),
          ],
        ),
      ),
    );
  }

  Widget recentlyPlayedUI(){
    return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(
                  "Recently Played",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Spacer(),
                Icon(Icons.camera_alt, size: 25, color: Colors.white),
                mSpacer(),
                Icon(Icons.mic, size: 25, color: Colors.white),
                mSpacer(),
                SvgPicture.asset("assets/svg/Settings.svg", color: Colors.white),
              ],
            ),
          )
        ]
    );
  }

  Widget recentlyPlayedList(List<Map<String, dynamic>> songs, MusicNotifier notifier){
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () {
              notifier.setSong(songs[i]['name'], songs[i]['artist'], songs[i]['imgPath']);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  Image.asset(songs[i]['imgPath'], width: 100, height: 100),
                  mSpacer(),
                  Text(songs[i]['name'], style: TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget playListUI(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text("Playlist", style: TextStyle(color: Colors.white, fontSize: 22)),
            mSpacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.black, // Background color
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  border: Border.all(color: Colors.white, width: 2), // White border
                ),
                child: const Center(
                  child: Icon(Icons.add, color: Colors.white, size: 40), // Centered plus icon
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget editorPicksUI(List<Map<String, dynamic>> songs, MusicNotifier notifier){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text("Editor's Picks", style: TextStyle(color: Colors.white, fontSize: 22)),
        ),
        mSpacer(),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: songs.length,
            itemBuilder: (_, i) {
              return GestureDetector(
                onTap: () {
                  notifier.setSong(songs[i]['name'], songs[i]['artist'], songs[i]['imgPath']);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      Image.asset(songs[i]['imgPath'], width: 100, height: 100),
                      mSpacer(),
                      Text(songs[i]['name'], style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              );
            }
          ),
        )
      ],
    );
  }
}
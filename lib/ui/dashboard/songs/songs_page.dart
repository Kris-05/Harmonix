import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/ui/dashboard/songs/widgets/music_slab.dart';

class SongsPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSongSelected;

  const SongsPage({super.key, required this.onSongSelected});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  
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

  Map<String, dynamic>? selectedSong;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.blackColor,
        body: Column(
          children: [
            mSpacer(),
            recentlyPlayedUI(), // top bar
            mSpacer(),
            recentlyPlayedList(), // recently played
            playListUI(),
            mSpacer(mHeight: 20),
            editorPicksUI(),
            if(selectedSong != null)
              MusicSlab(
                songName: selectedSong!['name'],
                artistName: selectedSong!['artist'],
                imgPath: selectedSong!['imgPath']
              )
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
                Text("Recently Played",
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

  Widget recentlyPlayedList(){
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mRecentPlayedList.length,
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: (){
              widget.onSongSelected(mRecentPlayedList[i]); // send song to home Page
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  Image.asset(mRecentPlayedList[i]['imgPath'], width: 100, height: 100),
                  mSpacer(),
                  Text(mRecentPlayedList[i]['name'], style: TextStyle(color: Colors.white, fontSize: 12),),
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

  Widget editorPicksUI(){
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
            itemCount: mEditorPicksList.length,
            itemBuilder: (_, i) {
              return GestureDetector(
                onTap: (){
                  setState(() {
                    widget.onSongSelected(mEditorPicksList[i]); // send song to home Page
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      Image.asset(mEditorPicksList[i]['imgPath'], width: 100, height: 100),
                      mSpacer(),
                      Text(mEditorPicksList[i]['name'], style: TextStyle(color: Colors.white, fontSize: 12),),
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
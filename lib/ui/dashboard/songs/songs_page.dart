import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/ui_helper.dart';

class SongsPage extends StatelessWidget {
  SongsPage({super.key});

  final List<Map<String, dynamic>> mRecentPlayedList = [
    {
      "imgPath": "assets/images/Afterburner.png",
      "name": "1(Remastered)"
    },
    {
      "imgPath": "assets/images/Anthem.png",
      "name": "Lana Del Rey"
    },
    {
      "imgPath": "assets/images/Artists.png",
      "name": "Marvin Gaye"
    },
    {
      "imgPath": "assets/images/Bryce_Vine.png",
      "name": "Indie Pop"
    },
  ];

  final List<Map<String, dynamic>> mEditorPicksList = [
    {
      "imgPath": "assets/images/Afterburner.png",
      "name": "Ed Sheeran"
    },
    {
      "imgPath": "assets/images/Anthem.png",
      "name": "Post Malone"
    },
    {
      "imgPath": "assets/images/Artists.png",
      "name": "Big Sean"
    },
    {
      "imgPath": "assets/images/Bryce_Vine.png",
      "name": "Glass Animals"
    },
  ];

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
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                Image.asset(mRecentPlayedList[i]['imgPath'], width: 100, height: 100),
                mSpacer(),
                Text(mRecentPlayedList[i]['name'], style: TextStyle(color: Colors.white, fontSize: 12),),
              ],
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    Image.asset(mEditorPicksList[i]['imgPath'], width: 100, height: 100),
                    mSpacer(),
                    Text(mEditorPicksList[i]['name'], style: TextStyle(color: Colors.white, fontSize: 12),),
                  ],
                ),
              );
            }
          ),
        )
      ],
    );
  }

}
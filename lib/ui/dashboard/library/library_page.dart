import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/api/playlistApi.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/ui/custom_widgets/type_button_chip.dart';
import 'package:spotify_ui/ui/custom_widgets/liked_songs_lib.dart';
import 'package:spotify_ui/ui/custom_widgets/playlist_comp_lib.dart';
import 'package:spotify_ui/ui/custom_widgets/Artist_comp_lib.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late Future<List<dynamic>> playlists;

  @override
  void initState() {
    playlists = Playlistapi.fetchAllPlaylist(email: "sakthi@gmail.com");
    print(playlists);
  }

  void fetchPlayList() {
    setState(() {
      playlists = Playlistapi.fetchAllPlaylist(email: "sakthi@gmail.com");
    });
    print("playList Updated!!!");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.blackColor,
          body: Column(
            children: [
              mSpacer(),
              libraryHeader(context, () {
                setState(() {
                  playlists = Playlistapi.fetchAllPlaylist(
                    email: "sakthi@gmail.com",
                  );
                });
                print("playList Updated!!!");
              }),
              mSpacer(),
              libraryButtons(),
              mSpacer(mHeight: 14),
              libRecent(),
              mSpacer(mHeight: 14),

              // Wrap with Expanded or Flexible to allow scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      LikedSongsLib(
                        likedCount: 10,
                        title: "Liked Songs",
                        subTitle: "Playlist",
                        isPinned: true,
                      ),
                      mSpacer(mHeight: 3),
                      FutureBuilder<List<dynamic>>(
                        future: playlists,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text("Error loading songs! Try again."),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Text("OOpsss. Cip!!!");
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(vertical: 0),
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              final playlist = snapshot.data![index];
                              return PlaylistComp(
                                title: playlist['name'],
                                Owner: "SakthiPriyan",
                                id: playlist['id'],
                                onUpdate: fetchPlayList,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget libraryHeader(context, VoidCallback func) {
  return Padding(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        CircleAvatar(),
        mSpacer(),
        Text(
          "Your Library",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        Spacer(),
        InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.createPlaylist,
              arguments: {'onPlaylistCreated': func},
            );
          },
          customBorder: const CircleBorder(),
          child: ClipOval(child: Icon(Icons.add, size: 35, color: Colors.grey)),
        ),
      ],
    ),
  );
}

Widget libraryButtons() {
  List<String> libNavi = ["Playlists", "Artists", "Albums", "Podcasts & shows"];
  return (Padding(
    padding: EdgeInsets.symmetric(horizontal: 11.0, vertical: 5.0),
    child: SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: libNavi.length,
        itemBuilder: (_, ind) {
          return TypeButtonChip(name: libNavi[ind]);
        },
      ),
    ),
  ));
}

Widget libRecent() {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
    child: Row(
      children: [
        RotatedBox(
          quarterTurns: 1,
          child: Icon(
            Icons.compare_arrows_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),

        Text(
          "Recently played",
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        SvgPicture.asset("assets/svg/menuLib.svg", color: Colors.white),
      ],
    ),
  );
}

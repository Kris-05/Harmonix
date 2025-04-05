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

    const List<Map<String, dynamic>> mRecentPlayedList = [
      {
        "imgPath": "https://i.scdn.co/image/ab67616d0000b273daf19986ce2c148768f5c362",
        "name": "Mortals",
        "artist": "Warriyo",
        "trackId": "3Fg5uhtWBlW0es8GSqQ6Ff"
      },
      {
        "imgPath": "https://i.scdn.co/image/ab67616d0000b273b0dd6a5cd1dec96c4119c262",
        "name": "One of the Girls",
        "artist": "The Weeknd, JENNIE, Lily-Rose Depp",
        "trackId": "7CyPwkp0oE8Ro9Dd5CUDjW"
      },
      {
        "imgPath": "https://i.scdn.co/image/ab67616d0000b273495ce6da9aeb159e94eaa453",
        "name": "Closer",
        "artist": "The Chainsmokers",
        "trackId": "7BKLCZ1jbUBVqRi2FVlTVw"
      },
      {
        "imgPath": "https://i.scdn.co/image/ab67616d0000b27337677af5b4f23fe9dc8a3c04",
        "name": "Animals",
        "artist": "Maroon 5",
        "trackId": "3h4T9Bg8OVSUYa6danHeH5",
      },
    ];

    final List<Map<String, dynamic>> mEditorPicksList = [
      {
        "imgPath": "https://i.scdn.co/image/ab67616d0000b273b6b3b7f26f0bc0e0197163a0",
        "name": "Arabic Kuthu",
        "artist": "Anirudh Ravichander",
        "trackId": "6yvxu91deFKt3X1QoV6qMv",
      },
      {
        "imgPath": "https://i.scdn.co/image/ab67616d0000b2736d97b3dc154dfdbe2321fb5c",
        "name": "Chuttamalle",
        "artist": "Shilpa Rao, Anirudh Ravichander",
        "trackId": "1bxzr3JK05fMTcweGAZUHp",
      },
      {
        "imgPath": "https://i.scdn.co/image/ab67616d0000b273c812fd378635732ad755733d",
        "name": "Badass (From `Leo`)",
        "artist": "Anirudh Ravichander",
        "trackId": "3h4T9Bg8OVSUYa6danHeH5",
      },
      {
        "imgPath": "https://i.scdn.co/image/ab67616d0000b273e6065f209e0a01986206bd53",
        "name": "Sailor Song",
        "artist": "Gigi Perez",
        "trackId": "3h4T9Bg8OVSUYa6danHeH5",
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
            recentlyPlayedList(mRecentPlayedList, ref, musicNotifier), // recently played
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

  Widget recentlyPlayedList(List<Map<String, dynamic>> songs, WidgetRef ref,MusicNotifier notifier){
    final musicNotifier = ref.read(musicProvider.notifier);

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () {
              print("Clicked song - ${songs[i]['name']}");
              musicNotifier.setSong(songs[i]['name'], songs[i]['artist'], songs[i]['imgPath'], songs[i]['trackId'],);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    child: Image.network(
                      songs[i]['imgPath'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return SizedBox(
                          width: 100,
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[800], // Placeholder color
                          child: Icon(Icons.broken_image, color: Colors.white),
                        );
                      },
                    ),
                  ),
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
                  notifier.setSong(songs[i]['name'], songs[i]['artist'], songs[i]['imgPath'], songs[i]['trackId']);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10), // Rounded corners
                        child: Image.network(
                          songs[i]['imgPath'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 100,
                              height: 100,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[800], // Placeholder color
                              child: Icon(Icons.broken_image, color: Colors.white),
                            );
                          },
                        ),
                      ),
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
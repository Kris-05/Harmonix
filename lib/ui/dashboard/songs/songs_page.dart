import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/providers/music_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:spotify_ui/ui/dashboard/search/search_page.dart';

class SongsPage extends ConsumerStatefulWidget {
  const SongsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ignore: unused_local_variable
    final selectedSong = ref.watch(musicProvider);
    final musicNotifier = ref.read(musicProvider.notifier);

    const List<Map<String, dynamic>> mRecentPlayedList = [
      {
        "imgPath":
            "https://i.scdn.co/image/ab67616d0000b273daf19986ce2c148768f5c362",
        "name": "Mortals",
        "artist": "Warriyo",
        "trackId": "3Fg5uhtWBlW0es8GSqQ6Ff",
      },
      {
        "imgPath":
            "https://i.scdn.co/image/ab67616d0000b273b0dd6a5cd1dec96c4119c262",
        "name": "One of the Girls",
        "artist": "The Weeknd, JENNIE, Lily-Rose Depp",
        "trackId": "7CyPwkp0oE8Ro9Dd5CUDjW",
      },
      {
        "imgPath":
            "https://i.scdn.co/image/ab67616d0000b273495ce6da9aeb159e94eaa453",
        "name": "Closer",
        "artist": "The Chainsmokers",
        "trackId": "7BKLCZ1jbUBVqRi2FVlTVw",
      },
      {
        "imgPath":
            "https://i.scdn.co/image/ab67616d0000b27337677af5b4f23fe9dc8a3c04",
        "name": "Animals",
        "artist": "Maroon 5",
        "trackId": "3h4T9Bg8OVSUYa6danHeH5",
      },
    ];

    final List<Map<String, dynamic>> mEditorPicksList = [
      {
        "imgPath":
            "https://i.scdn.co/image/ab67616d0000b273b6b3b7f26f0bc0e0197163a0",
        "name": "Arabic Kuthu",
        "artist": "Anirudh Ravichander",
        "trackId": "6yvxu91deFKt3X1QoV6qMv",
      },
      {
        "imgPath":
            "https://i.scdn.co/image/ab67616d0000b2736d97b3dc154dfdbe2321fb5c",
        "name": "Chuttamalle",
        "artist": "Shilpa Rao, Anirudh Ravichander",
        "trackId": "1bxzr3JK05fMTcweGAZUHp",
      },
      {
        "imgPath":
            "https://i.scdn.co/image/ab67616d0000b273c812fd378635732ad755733d",
        "name": "Badass (From `Leo`)",
        "artist": "Anirudh Ravichander",
        "trackId": "3h4T9Bg8OVSUYa6danHeH5",
      },
      {
        "imgPath":
            "https://i.scdn.co/image/ab67616d0000b273e6065f209e0a01986206bd53",
        "name": "Sailor Song",
        "artist": "Gigi Perez",
        "trackId": "3h4T9Bg8OVSUYa6danHeH5",
      },
    ];

    final List<Map<String, String>> localSongs = [
      {"id": "6HGoVbCUr63SgU3TjxEVj6", "path": "assets/audio/four.mp3"},
      {"id": "2fWntvE5ES959CohvGfF3f", "path": "assets/audio/two.mp3"},
      {"id": "7dFqLUWUZ7CKsEAFwf3d4H", "path": "assets/audio/three.mp3"},
      {"id": "709CXottAkQWL83UqsilQc", "path": "assets/audio/one.mp3"},
    ];

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.blackColor,
        body: Column(
          children: [
            mSpacer(),
            recentlyPlayedUI(), // top bar
            mSpacer(),
            recentlyPlayedList(
              mRecentPlayedList,
              context,
              ref,
              musicNotifier,
              localSongs,
            ), // recently played
            playListUI(context),
            mSpacer(mHeight: 20),
            editorPicksUI(mEditorPicksList, musicNotifier),
          ],
        ),
        floatingActionButton:
            _isListening
                ? FloatingActionButton(
                  onPressed: _toggleRecording,
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.mic, color: Colors.white),
                )
                : null,
      ),
    );
  }

  Widget recentlyPlayedUI() {
  Widget recentlyPlayedUI() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Text(
                "Recently Played",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Spacer(),
              Icon(Icons.camera_alt, size: 25, color: Colors.white),
              mSpacer(),
              Icon(Icons.mic, size: 25, color: Colors.white),
              mSpacer(),
              SvgPicture.asset("assets/svg/Settings.svg", color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }

  Widget recentlyPlayedList(
    List<Map<String, dynamic>> songs,
    BuildContext context,
    WidgetRef ref,
    MusicNotifier notifier,
    List<Map<String, String>> localSongs,
  ) {
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

              // get only the ids form the map
              final localSongIds = localSongs.map((song) => song['id']!).toList();
              
              musicNotifier.setQueue(plQueue: localSongIds);
              musicNotifier.setLocalSongs(songs: localSongs);

              // Get prev and next based on current song
              final pre = musicNotifier.getPlPre(localSongIds[0]);
              final nxt = musicNotifier.getPlNext(localSongIds[0]);

              print("pre: $pre");
              print("nxt: $nxt");

              // Set song details
              musicNotifier.setSong(
                name: songs[i]['name'],
                artist: songs[i]['artist'],
                image: songs[i]['imgPath'],
                trackId: songs[i]['trackId'],
                pre: pre,
                nxt: nxt,
                plQueue: localSongIds,
              );

              Navigator.pushNamed(
                context,
                AppRoutes.songsPage,
                arguments: {'trackId': localSongIds[0], 'isLocal': true, 'audioQueue': localSongs},
              );
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
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
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
                  Text(
                    songs[i]['name'],
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget playListUI(context) {
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
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ), // White border
              ),
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.createPlaylist,
                    arguments: {'onPlaylistCreated': () {}},
                  );
                },
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 40,
                  ), // Centered plus icon
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget editorPicksUI(
    List<Map<String, dynamic>> songs,
    MusicNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            "Editor's Picks",
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
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
                  notifier.setSong(
                    name: songs[i]['name'],
                    artist: songs[i]['artist'],
                    image: songs[i]['imgPath'],
                    trackId: songs[i]['trackId'],
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          10,
                        ), // Rounded corners
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
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              (loadingProgress
                                                      .expectedTotalBytes ??
                                                  1)
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
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                      mSpacer(),
                      Text(
                        songs[i]['name'],
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

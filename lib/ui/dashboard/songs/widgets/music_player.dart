import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_scroll_text/auto_scroll_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_ui/domain/custom_strings.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
// import 'package:spotify_ui/providers/music_provider.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/ui/dashboard/songs/model/Music.dart';
import 'package:spotify_ui/ui/dashboard/songs/widgets/artwork_image.dart';
import 'package:spotify_ui/ui/dashboard/songs/widgets/lyrics_page.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MusicPlayer extends ConsumerStatefulWidget {
  const MusicPlayer({super.key});

  @override
  ConsumerState<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends ConsumerState<MusicPlayer> {

    final player = AudioPlayer();
    Music music = Music(
      trackId: "3Fg5uhtWBlW0es8GSqQ6Ff", // Spotify track ID
    );
    // 7CyPwkp0oE8Ro9Dd5CUDjW - one of the girls
    // 3Fg5uhtWBlW0es8GSqQ6Ff - mortals

    @override
    void initState() {
      // print("hello");
      fetchAndPlayMusic();
      super.initState();
    }

    Future<void> fetchAndPlayMusic() async {
      try {
        print("Fetching song...");
        final credentials = SpotifyApiCredentials(CustomStrings.clientId, CustomStrings.clientSecret);
        final spotify = SpotifyApi(credentials);

        final track = await spotify.tracks.get(music.trackId);

        //Extract data
        String? fetchedSongName = track.name;
        String? fetchedArtistName = track.artists!.isNotEmpty ? track.artists?.first.name : "Unknown Artist";
        String? fetchedSongImage = track.album?.images?.isNotEmpty == true ? track.album!.images?.first.url : null;

        if (fetchedSongImage != null) {
          final tempSongColor = await getImagePalette(NetworkImage(fetchedSongImage));
          if (tempSongColor != null) {
            music.songColor = tempSongColor;
          }
        }

        String? fetchedArtistImage;
        if (track.artists!.isNotEmpty) {
          final artist = await spotify.artists.get(track.artists!.first.id!);
          fetchedArtistImage = artist.images!.isNotEmpty ? artist.images!.first.url : null;
        }

        print("Song: $fetchedSongName by $fetchedArtistName");
        print("Song Image: $fetchedSongImage");
        print("Artist Image: $fetchedArtistImage");

        // Update state
        setState(() {
          music.songName = fetchedSongName ?? "Unknown Song";
          music.artistName = fetchedArtistName ?? "Unknown Artist";
          music.songImage = fetchedSongImage ?? "https://i.pinimg.com/736x/ea/25/71/ea257196036ec7a33135c1927948d4e5.jpg"; // Default image
          music.artistImage = fetchedArtistImage ?? "https://i.pinimg.com/736x/ea/25/71/ea257196036ec7a33135c1927948d4e5.jpg"; // Default image
        });

        // Find and play YouTube audio
        final yt = YoutubeExplode();
        final video = (await yt.search.search(music.songName ?? "One Of The Girls (with JENNIE, Lily Rose Depp)")).first; // default song - if none found
        final videoId = video.id.value;
        print("YouTube Video Found: ${video.title}");

        var manifest = await yt.videos.streamsClient.getManifest(videoId);
        var audioUrl = manifest.audioOnly.first.url;

        setState(() {
          music.duration = video.duration;
        });

        print("Playing song...");
        await player.play(UrlSource(audioUrl.toString()));
      } catch (e) {
        print("Error: $e");
      }
    }

  // generate accroding image color
  Future<Color?> getImagePalette(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor?.color;
  }

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
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Column(
              children: [
                // header
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.arrow_downward, color: Colors.white,),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Playing Now", style: TextStyle(color: AppColors.primaryColor)),
                        mSpacer(mHeight: 6),
                        // artist image + dynamic text 
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(music.artistImage ?? "https://i.pinimg.com/736x/ea/25/71/ea257196036ec7a33135c1927948d4e5.jpg"),
                              radius: 10,
                            ),
                            mSpacer(mWidth: 4),
                            Text("From recents", style: TextStyle(fontSize: 20 ,color: AppColors.whiteColor)),
                          ],
                        ),
                      ],
                    ),
                    Icon(Icons.close, color: Colors.white,),
                  ],
                ),
                // song image
                Expanded(
                  flex: 3,
                  child: Center(
                    child: music.songImage == null
                        ? CircularProgressIndicator()  // Show loading indicator
                        : ArtworkImage(image: music.songImage!)
                  )
                ),
                // song name + player + buttons
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      // song name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 300,
                                child: AutoScrollText(
                                  music.songName ?? "Loading...",
                                  style: TextStyle(
                                    fontSize: 20, 
                                    color: AppColors.whiteColor
                                  ),
                                  mode: AutoScrollTextMode.bouncing,
                                  pauseBetween: Duration(seconds: 1),
                                ),
                              ),
                              Text(music.artistName ?? "Loading...", style: TextStyle(color: AppColors.greyColor)),
                            ]
                          ),
                          const Icon(Icons.favorite, color: AppColors.primaryColor)
                        ],
                      ),
                      mSpacer(mHeight: 16),
                      // player
                      StreamBuilder(
                        stream: player.onPositionChanged,
                        builder: (context, data) {
                          return ProgressBar(
                            progress: data.data ?? Duration(seconds: 0),
                            total: music.duration ?? Duration(minutes: 1),
                            bufferedBarColor: Colors.white60,
                            baseBarColor: Colors.white10,
                            thumbColor: AppColors.whiteColor,
                            progressBarColor: AppColors.whiteColor,
                            timeLabelTextStyle: TextStyle(color: Colors.white),
                            onSeek: (duration) {
                              print('User selected a new time: $duration');
                              player.seek(duration);
                            },
                          );
                        }
                      ),
                      mSpacer(mHeight: 16),
                      // buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            // for route with args - .push is recommended
                            // for predefined routes like login - our AppRoutes
                            onPressed: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => LyricsPage()
                                ));
                            },
                            icon: const Icon(
                              Icons.lyrics_outlined, 
                              color: Colors.white
                            )
                          ),
                          IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.skip_previous,
                                color: Colors.white, size: 36
                              )
                          ),
                          IconButton(
                              onPressed: () async {
                                if(player.state == PlayerState.playing){
                                  await player.pause();
                                } else {
                                  await player.resume();
                                }
                                setState(() {});
                              },
                              icon: Icon(
                                player.state == PlayerState.playing ? Icons.pause : Icons.play_circle,   
                                color: Colors.white, size: 60,
                              )
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.skip_next,   
                              color: Colors.white, size: 36,
                            )
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.loop,   
                              color: AppColors.primaryColor,
                            )
                          ),
                        ],
                      )
                    ],
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
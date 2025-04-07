  import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
  import 'package:audioplayers/audioplayers.dart';
  import 'package:auto_scroll_text/auto_scroll_text.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:palette_generator/palette_generator.dart';
  import 'package:spotify/spotify.dart';
  import 'package:spotify_ui/cameraCapture.dart';
  import 'package:spotify_ui/domain/app_routes.dart';
  import 'package:spotify_ui/domain/custom_strings.dart';
  import 'package:spotify_ui/domain/ui_helper.dart';
  import 'package:spotify_ui/domain/app_colors.dart';
  import 'package:spotify_ui/providers/gesture_provider.dart';
  import 'package:spotify_ui/providers/music_provider.dart';
  import 'package:spotify_ui/ui/dashboard/songs/model/Music.dart';
  import 'package:spotify_ui/ui/dashboard/songs/widgets/artwork_image.dart';
  import 'package:spotify_ui/ui/dashboard/songs/widgets/lyrics_page.dart';
  import 'package:youtube_explode_dart/youtube_explode_dart.dart';

  class MusicPlayer extends ConsumerStatefulWidget {
    final String trackId;
    final String pre;
    final String nxt;
    // New fields to optionally skip Spotify API fetch
  late List<Map<String, String>>?audioQueue; // path to local audio file (asset or file)
  late bool? isLocal;

     MusicPlayer({super.key, required this.trackId,required this.pre, required this.nxt,this.audioQueue,
    this.isLocal,});

    @override
    ConsumerState<MusicPlayer> createState() => _MusicPlayerState();
  }

  class _MusicPlayerState extends ConsumerState<MusicPlayer> {

      final player = AudioPlayer();
      late Music music; 
      
      VideoService videoService = VideoService();
      // 7CyPwkp0oE8Ro9Dd5CUDjW - one of the girls
      // 3Fg5uhtWBlW0es8GSqQ6Ff - mortals
      // 3h4T9Bg8OVSUYa6danHeH5 - animals
      // 28pMkd9JEFnupyk4SnCTPn - kanmoodi thirakum pothu
      // Initialize before running app
      
    @override
      void initState() {
        // print("hello");
        music = Music(trackId: widget.trackId);
        print(widget.isLocal);
        fetchAndPlayMusic();
        super.initState();
        

        final gestureNotifier = ref.read(gestureProvider.notifier);
        // final gestureState = ref.watch(gestureProvider);
        final isGestureNaviActivated=gestureNotifier.getGesture();

        if(isGestureNaviActivated){
           print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n  Fucker !!!!!  \n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\ ");
              initCameraFunction(videoService);
             
        }
        else{
          print("Gesture Is in Off State");
        }


        // keestu fix!
        if (widget.isLocal == true) {
      print("Playing from local...");
      if (widget.audioQueue != null && widget.trackId.isNotEmpty) {
        final localTrack = widget.audioQueue!.firstWhere(
          (track) => track['id'] == widget.trackId,
          orElse: () => {},
        );
        final path = localTrack['path'];

        if (path != null) {
          playLocalAudio(path);
        } else {
          print("Local path not found for trackId: ${widget.trackId}");
        }
      }
    }
      }

      @override
      void dispose() {
        // / dispose audio player
         // stop camera and close socket if initialized
        videoService.stopSendingFrames();
        videoService.deActivateCamera();
        super.dispose();
      }


      void initCameraFunction(VideoService videoService)async {
        
        await videoService.initializeCamera();
        videoService.connectSocket(); // Connect socket
        await videoService.startSendingFrames(); // Start sending frames
        final container = ProviderContainer();
        _listenToGestureStream(videoService, container);
      }

      void handleNext(MusicNotifier musicNotifier)async{
         String temp = musicNotifier.getPlNext(widget.trackId);
                              print("from nxt button: $temp");
                              await player.pause();

                              // Update global state when clicking the MusicSlab
                              musicNotifier.setSong(
                                name: music.songName,
                                artist: music.artistName,
                                image: music.songImage,
                                nxt: widget.nxt,
                              );
                              
                              Navigator.pushNamed(
                                context,
                                AppRoutes.songsPage,
                                arguments: {
                                  'trackId': musicNotifier.getPlNext(
                                    widget.trackId,
                                  ),
                                  'pre': musicNotifier.getPlPre(widget.nxt),
                                  'nxt': musicNotifier.getPlNext(widget.nxt),
                                  'isLocal': widget.isLocal,
                                  'audioQueue': widget.audioQueue,
                                },
                              );
      }

      void handlePre(MusicNotifier musicNotifier)async {
            String temp = musicNotifier.getPlPre(widget.trackId);
                              print("from prev button: $temp");
                              await player.pause();

                              // Update global state when clicking the MusicSlab
                              musicNotifier.setSong(
                                name: music.songName,
                                artist: music.artistName,
                                image: music.songImage,
                                trackId: temp,
                              );

                              Navigator.pushNamed(
                                context,
                                AppRoutes.songsPage,
                                arguments: {
                                  'trackId': temp,
                                  'pre': musicNotifier.getPlPre(temp),
                                  'nxt': musicNotifier.getPlNext(temp),
                                  'isLocal': widget.isLocal,
                                  'audioQueue': widget.audioQueue,
                                },
                              );
      }
      void _listenToGestureStream(VideoService videoService, ProviderContainer container) {
              final musicNotifier = ref.read(musicProvider.notifier);
              
                videoService.gestureStream.listen((gesture) {
                  // final music = container.read(musicNotifierProvider.notifier);

                  switch (gesture.toLowerCase()) {
                    case 'play':
                      // music.play();
                      print('play');
                      musicNotifier.togglePlayPause();
                      break;
                    case 'next':
                    case 'next2':
                       handleNext(musicNotifier);
                      break;
                    case 'previous':
                    case 'previous2':
                      // music.previous();
                      print('pre');

                     handlePre(musicNotifier);
                      break;
                    default:
                      print("Unknown gesture: $gesture");
                  }
                });
              }


       Future<void> playLocalAudio(String path) async {
    try {
      print("Playing local audio: $path");

      if (path.startsWith("assets/")) {
        await player.play(AssetSource(path.replaceFirst("assets/", "")));
      } else {
        await player.play(DeviceFileSource(path));
      }

      player.onDurationChanged.listen((duration) {
        setState(() {
          music.duration = duration;
        });
      });
    } catch (e) {
      print("Local audio play error: $e");
    }
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

          if (widget.isLocal == true) {
        print("Skipping YouTube playback since it's local.");
      }

      if (widget.isLocal == true) return;

          print("Playing song...");
          await player.play(UrlSource(audioUrl.toString()));

          print("State check -  $PlayerState.playing");
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
    final musicState = ref.watch(musicProvider);
    final musicNotifier = ref.read(musicProvider.notifier);
    final gestureState = ref.watch(gestureProvider);
    final gestureNotifier = ref.read(gestureProvider.notifier);
    
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
                      // Minimize Button
                      IconButton(
                        icon: Icon(Icons.arrow_downward, color: Colors.white),
                        onPressed: () {
                          Navigator.pop(context, player); // Brings back to previous screen (e.g., music list)
                        },
                      ),
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
                      // Close Button
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () async {
                          await player.stop(); // Stops playback
                          Navigator.pop(context); // Exits the song page
                        },
                      ),
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
                                    builder: (context) => LyricsPage(music: music)
                                  ));
                              },
                              icon: const Icon(
                                Icons.lyrics_outlined, 
                                color: Colors.white
                              )
                            ),
                            IconButton(
                                onPressed: () async {
                              String temp = musicNotifier.getPlPre(widget.trackId);
                              print("from prev button: $temp");
                              await player.pause();

                              // Update global state when clicking the MusicSlab
                              musicNotifier.setSong(
                                name: music.songName,
                                artist: music.artistName,
                                image: music.songImage,
                                trackId: temp,
                              );

                              Navigator.pushNamed(
                                context,
                                AppRoutes.songsPage,
                                arguments: {
                                  'trackId': temp,
                                  'pre': musicNotifier.getPlPre(temp),
                                  'nxt': musicNotifier.getPlNext(temp),
                                  'isLocal': widget.isLocal,
                                  'audioQueue': widget.audioQueue,
                                },
                              );
                            },
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
                                  player.state == PlayerState.playing ? Icons.pause : Icons.play_circle ,   
                                  color: Colors.white, size: 60,
                                )
                            ),
                            IconButton(
                              onPressed: () async {
                              String temp = musicNotifier.getPlNext(widget.trackId);
                              print("from nxt button: $temp");
                              await player.pause();

                              // Update global state when clicking the MusicSlab
                              musicNotifier.setSong(
                                name: music.songName,
                                artist: music.artistName,
                                image: music.songImage,
                                nxt: widget.nxt,
                              );
                              
                              Navigator.pushNamed(
                                context,
                                AppRoutes.songsPage,
                                arguments: {
                                  'trackId': musicNotifier.getPlNext(
                                    widget.trackId,
                                  ),
                                  'pre': musicNotifier.getPlPre(widget.nxt),
                                  'nxt': musicNotifier.getPlNext(widget.nxt),
                                  'isLocal': widget.isLocal,
                                  'audioQueue': widget.audioQueue,
                                },
                              );
                            },
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
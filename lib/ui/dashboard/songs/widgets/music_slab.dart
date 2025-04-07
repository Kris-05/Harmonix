import 'package:audioplayers/audioplayers.dart';
import 'package:auto_scroll_text/auto_scroll_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:spotify/spotify.dart' hide Image;
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/custom_strings.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/providers/music_provider.dart';

// Riverpod provider for dominant color
final dominantColorProvider = StateProvider<Color>((ref) => Colors.transparent);
final trackInfoProvider = StateProvider<Map<String, String>>((ref) => {
  "songName": "",
  "artistName": "",
  "imgPath": "",
});

class MusicSlab extends ConsumerStatefulWidget {
  final String trackId;
  final AudioPlayer player;
  String pre,nxt;

  MusicSlab({
    super.key,
    required this.trackId,
    required this.player, required this.pre, required this.nxt,
  });

  @override
  ConsumerState<MusicSlab> createState() => _MusicSlabState();
}

class _MusicSlabState extends ConsumerState<MusicSlab> {
  late String _currentTrackId;

  @override
  void initState() {
    super.initState();
    _currentTrackId = widget.trackId;
    _fetchData(); // Initial fetch
  }

  @override
  void didUpdateWidget(MusicSlab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackId != widget.trackId) {
      _currentTrackId = widget.trackId;
      _fetchData(); // Fetch again if track changed
    }
  }

  Future<void> _fetchData() async {
    await fetchTrackInfo();
    await getImagePalette();
  }

  Future<void> fetchTrackInfo() async {
    try {
      final credentials = SpotifyApiCredentials(CustomStrings.clientId, CustomStrings.clientSecret);
      final spotify = SpotifyApi(credentials);

      final track = await spotify.tracks.get(_currentTrackId);

      final song = track.name ?? "Unknown";
      final artist = track.artists?.first.name ?? "Unknown Artist";
      final image = track.album?.images?.first.url ?? "";

      ref.read(trackInfoProvider.notifier).state = {
        "songName": song,
        "artistName": artist,
        "imgPath": image,
      };

      ref.read(musicProvider.notifier).setSong(name: song,artist:  artist,image:  image,trackId: _currentTrackId);
    } catch (e) {
      print("Error fetching track info: $e");
    }
  }

  Future<void> getImagePalette() async {
    final imageUrl = ref.read(trackInfoProvider)["imgPath"] ?? "";
    if (imageUrl.isNotEmpty) {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(NetworkImage(imageUrl));

      final Color extractedColor =
          paletteGenerator.dominantColor?.color ?? Colors.grey;

      ref.read(dominantColorProvider.notifier).state = extractedColor;
    }
  }


  @override
  Widget build(BuildContext context) {
    final musicState = ref.watch(musicProvider);
    final musicNotifier = ref.read(musicProvider.notifier);
    final trackInfo = ref.watch(trackInfoProvider);
    final Color dominantColor = ref.watch(dominantColorProvider);

    // Call getImagePalette when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) => getImagePalette());
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchTrackInfo());

    return GestureDetector(
      onTap: () {
        // Update global state when clicking the MusicSlab
        musicNotifier.setSong(
          name: trackInfo["songName"] ?? "Loading...",
          artist: trackInfo["artistName"] ?? "Loading..",
          image: trackInfo["imgPath"] ?? "",
          trackId: _currentTrackId,
        );
        Navigator.pushNamed(
          context,
          AppRoutes.songsPage,
          arguments: {'trackId': _currentTrackId,'pre':widget.pre,'nxt':widget.nxt}, // Pass trackId as an argument
        );
      },
      child: Container(
        height: 66,
        width: double.infinity,
        decoration: BoxDecoration(color: dominantColor.withOpacity(0.6)),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // song meta
            Row(
              children: [
                // song image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                  child: Image.network(
                    trackInfo["imgPath"] ?? "",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox(
                        width: 50,
                        height: 50,
                        child: Center(
                          child: CircularProgressIndicator(
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
                        width: 50,
                        height: 50,
                        color: Colors.grey[800], // Placeholder color
                        child: Icon(Icons.broken_image, color: Colors.white),
                      );
                    },
                  ),
                ),
                mSpacer(),
                // Song + artist name 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // song name
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: AutoScrollText(
                        trackInfo["songName"] ?? "Loading...",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w500,
                        ),
                        mode: AutoScrollTextMode.bouncing,
                        pauseBetween: Duration(seconds: 1),
                      ),
                    ),
                    // artist name
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: AutoScrollText(
                        trackInfo["artistName"] ?? "Loading...",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                        mode: AutoScrollTextMode.bouncing,
                        pauseBetween: Duration(seconds: 1),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // like + pause
            Row(children: [
                IconButton(
                  onPressed: () {
                    musicNotifier.toggleLike(); // Updated to use Riverpod
                  },
                  icon: Icon(
                    musicState.isLiked ? Icons.favorite : Icons.favorite_border,
                  ),
                  color:
                      musicState.isLiked
                          ? AppColors.primaryColor
                          : AppColors.whiteColor,
                  iconSize: 25,
                ),
                IconButton(
                  onPressed: () {
                    musicNotifier.togglePlayPause(); // Updated to use Riverpod
                  },
                  icon: Icon(
                    musicState.isPlaying ? Icons.pause : Icons.play_arrow,
                  ),
                  color: AppColors.whiteColor,
                  iconSize: 30,
                ),
              ],
            ),
          ],
        ),   
      ),
    );
  }
}

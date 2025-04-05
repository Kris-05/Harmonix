import 'package:audioplayers/audioplayers.dart';
import 'package:auto_scroll_text/auto_scroll_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/providers/music_provider.dart';

// Riverpod provider for dominant color
final dominantColorProvider = StateProvider<Color>((ref) => Colors.transparent);

class MusicSlab extends ConsumerWidget {
  final String songName;
  final String artistName;
  final String imgPath;
  final String trackId;
  final AudioPlayer player;

  const MusicSlab({
    super.key,
    required this.songName,
    required this.artistName,
    required this.imgPath,
    required this.trackId,
    required this.player,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicState = ref.watch(musicProvider);
    final musicNotifier = ref.read(musicProvider.notifier);
    final Color dominantColor = ref.watch(dominantColorProvider);

    // Function to extract dominant color
    Future<void> getImagePalette() async {
      final PaletteGenerator paletteGenerator =
          await PaletteGenerator.fromImageProvider(NetworkImage(imgPath));

      final Color extractedColor =
          paletteGenerator.dominantColor?.color ?? Colors.grey;

      // Update state with new color
      ref.read(dominantColorProvider.notifier).state = extractedColor;
    }

    // Call getImagePalette when widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) => getImagePalette());

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [   
        GestureDetector(
          onTap: () {
            // Update global state when clicking the MusicSlab
            musicNotifier.setSong(songName, artistName, imgPath, trackId);
            Navigator.pushNamed(
              context,
              AppRoutes.songsPage,
              arguments: {'trackId': trackId}, // Pass trackId as an argument
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
                        musicState.imgPath,
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
                            musicState.songName,
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
                            musicState.artistName,
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
        ),

        mSpacer(), // Adds spacing
        Center(
          child: Text(
            "Now Playing: $songName",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

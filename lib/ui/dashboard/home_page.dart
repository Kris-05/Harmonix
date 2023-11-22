import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_ui/providers/home_provider.dart';
import 'package:spotify_ui/providers/music_provider.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/ui/dashboard/library/library_page.dart';
import 'package:spotify_ui/ui/dashboard/search/search_page.dart';
import 'package:spotify_ui/ui/dashboard/songs/songs_page.dart';
import 'package:spotify_ui/ui/dashboard/songs/widgets/music_slab.dart';

class HomePage extends ConsumerWidget  {

  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final selectedIndex = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final selectedSong = ref.watch(musicProvider);

    final player = AudioPlayer(); // Create an AudioPlayer instance

    final List<Widget> pages = [
      const SongsPage(),
      const SearchPage(),
      const LibraryPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Stack(
        children: [
          pages[selectedIndex],
          if(selectedSong.songName.isNotEmpty)
            Positioned.fill(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: MusicSlab(
                  songName: selectedSong.songName, 
                  artistName: selectedSong.artistName,
                  imgPath: selectedSong.imgPath,
                  trackId: selectedSong.trackId,
                  player: player,
                  pre:'28pMkd9JEFnupyk4SnCTPn',
                  nxt:'3h4T9Bg8OVSUYa6danHeH5'
                ),
              ),
            )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => homeNotifier.setPage(i),
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              selectedIndex == 0  ? "assets/svg/Home_Solid.svg" : "assets/svg/Home_outline.svg",
              color: selectedIndex == 0 ? AppColors.primaryColor : AppColors.greyColor,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/svg/Search_Solid.svg",
              color: selectedIndex == 1 ? AppColors.primaryColor : AppColors.greyColor,
            ),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              selectedIndex == 2  ? "assets/svg/Library_Solid.svg" : "assets/svg/Library_outline.svg",
              color: selectedIndex == 2 ? AppColors.primaryColor : AppColors.greyColor,
            ),
            label: "Library",
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/ui/dashboard/library/library_page.dart';
import 'package:spotify_ui/ui/dashboard/search/search_page.dart';
import 'package:spotify_ui/ui/dashboard/songs/songs_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int selectedIndex = 0;

  final pages = [
    SongsPage(),
    const SearchPage(),
    const LibraryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) {
          setState(() {
            selectedIndex = i;
          });
        },
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
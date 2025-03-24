import 'package:flutter/material.dart';
import 'package:spotify_ui/domain/app_colors.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Center(
        child: Text("Search Page", style: TextStyle(color: Colors.white, fontSize: 24)),
      ),
    );
  }
}
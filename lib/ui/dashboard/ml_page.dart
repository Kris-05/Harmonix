import 'package:flutter/material.dart';
import 'package:spotify_ui/domain/app_colors.dart';

class MlPage extends StatelessWidget {
  const MlPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Center(
        child: Text("ML Page", style: TextStyle(color: Colors.white, fontSize: 24)),
      ),
    );
  }
}
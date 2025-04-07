// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:spotify_ui/domain/app_colors.dart';
// import 'package:spotify_ui/ui/dashboard/songs/model/Playlist.dart';

// class PlaylistPage extends StatelessWidget {
//   const PlaylistPage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final playlist = ref.watch(playlistProvider).playlist;
//     return Scaffold(
//       backgroundColor: AppColors.blackColor,
//       appBar: AppBar(
//         title: const Text("Playlist"),
//       ),
//       body: Consumer<PlaylistPage>(

//         builder: (context, value, child){
//           final List<Song> playlist = value.playlist;
//           return ListView.builder(
//             itemBuilder: (context, index) => ListTile()
//           ); 
//         }, 
//       )
//     );
//   }
// }
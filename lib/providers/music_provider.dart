import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicState {
  final String songName;
  final String artistName;
  final String imgPath;
  final bool isPlaying;
  final bool isLiked;

  MusicState({
    this.songName = '',
    this.artistName = '',
    this.imgPath = '',
    this.isPlaying = false,
    this.isLiked = false,
  });

  MusicState copyWith({
    String? songName,
    String? artistName,
    String? imgPath,
    bool? isPlaying,
    bool? isLiked,
  }) {
    return MusicState(
      songName: songName ?? this.songName,
      artistName: artistName ?? this.artistName,
      imgPath: imgPath ?? this.imgPath,
      isPlaying: isPlaying ?? this.isPlaying,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

class MusicNotifier extends StateNotifier<MusicState> {
  MusicNotifier() : super(MusicState());

  void setSong(String name, String artist, String image) {
    state = state.copyWith(songName: name, artistName: artist, imgPath: image, isPlaying: true);
  }

  void togglePlayPause() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void toggleLike() {
    state = state.copyWith(isLiked: !state.isLiked);
  }
}

final musicProvider = StateNotifierProvider<MusicNotifier, MusicState>((ref) => MusicNotifier());

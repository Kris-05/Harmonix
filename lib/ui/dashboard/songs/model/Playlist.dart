import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Song {
  final String trackId;
  final String songPath;

  Song({required this.trackId, required this.songPath});
}

class Playlist extends ChangeNotifier {
  final List<Song> _playList = [
    // naa adicha thaanga maten
    Song(
      trackId: '3Fg5uhtWBlW0es8GSqQ6Ff',
      songPath: 'assets/audio/one.mp3',
    ),
    // kadhal yaani
    Song(
      trackId: '3Fg5uhtWBlW0es8GSqQ6Ff',
      songPath: 'assets/audio/one.mp3',
    ),
    // yaaro manadhile
    Song(
      trackId: '3Fg5uhtWBlW0es8GSqQ6Ff',
      songPath: 'assets/audio/one.mp3',
    ),
    // 
    Song(
      trackId: '3Fg5uhtWBlW0es8GSqQ6Ff',
      songPath: 'assets/audio/one.mp3',
    ),
  ];

  int? _currSongIndex;

  List<Song> get playlist => _playList;
  int? get currSongIndex => _currSongIndex;
}

final playlistProvider = ChangeNotifierProvider((ref) => Playlist());
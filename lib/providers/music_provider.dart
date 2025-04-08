import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusicState {
  final String songName;
  final String artistName;
  final String imgPath;
  final String trackId; 
  final bool isPlaying;
  final bool isLiked;
  late String pre;
  late String nxt;
  List<dynamic>?queue=[];
  List<Map<String, String>>? localSongs;

  MusicState({
    this.songName = '',
    this.artistName = '',
    this.imgPath = '',
    this.trackId = '', // Initialize trackId
    this.isPlaying = false,
    this.isLiked = false,
    this.nxt='28pMkd9JEFnupyk4SnCTPn',
    this.pre='3h4T9Bg8OVSUYa6danHeH5',
     this.queue,
     this.localSongs, 

  });

  MusicState copyWith({
    String? songName,
    String? artistName,
    String? imgPath,
    String? trackId, // Include trackId
    bool? isPlaying,
    bool? isLiked,
    String ?pre,
    String ?nxt,
    List<dynamic>?queue,
    List<Map<String, String>>? localSongs,

  }) {
    return MusicState(
      songName: songName ?? this.songName,
      artistName: artistName ?? this.artistName,
      imgPath: imgPath ?? this.imgPath,
      trackId: trackId ?? this.trackId, // Copy trackId
      isPlaying: isPlaying ?? this.isPlaying,
      isLiked: isLiked ?? this.isLiked,
      pre:pre?? this.pre,
      nxt:nxt??this.nxt,
      queue: queue??this.queue,
      localSongs: localSongs ?? this.localSongs,
    );
  }
}

class MusicNotifier extends StateNotifier<MusicState> {
  MusicNotifier() : super(MusicState());

  void setSong({String? name, String? artist, String? image, String? trackId,String pre='28pMkd9JEFnupyk4SnCTPn',String nxt='3h4T9Bg8OVSUYa6danHeH5',List<dynamic>? plQueue,}) {
    print("provi:$nxt ,,pre:$pre");
    state = state.copyWith(
      songName: name,
      artistName: artist,
      imgPath: image,
      trackId: trackId,
      isPlaying: true,
      pre: pre,
      nxt:nxt
    );
  }


  void setQueue({List<dynamic>? plQueue,}) {
    state = state.copyWith(
      queue: plQueue,
    );
  }

  void setLocalSongs({List<Map<String, String>>? songs}) {
    state = state.copyWith(
      localSongs: songs
    );
  }

  String getPlPre(String trackId) {
    final queue = state.queue ?? [];
    if (queue.isEmpty) return '';

    final index = queue.indexWhere((song) => song == trackId);
    if (index == -1) return ''; 

    final preIndex = index == 0 ? queue.length - 1 : index - 1;

    print("getPlPre: ${queue[preIndex]} => ${queue[preIndex]}");
    return queue[preIndex];
  }

  String getPlNext(String trackId) {
    final queue = state.queue ?? [];
    if (queue.isEmpty) return '';

    final index = queue.indexWhere((song) => song == trackId);
    if (index == -1) return '';

    final nextIndex = (index + 1) % queue.length;
    print("getPlNext: ${queue[nextIndex]} => ${queue[nextIndex]}");
    return queue[nextIndex];
  }



  void clearSong() {
    state = MusicState();
  }

  void togglePlayPause() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void toggleLike() {
    state = state.copyWith(isLiked: !state.isLiked);
  }
}

final musicProvider = StateNotifierProvider<MusicNotifier, MusicState>((ref) => MusicNotifier());

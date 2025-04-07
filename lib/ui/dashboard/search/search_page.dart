import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_ui/providers/music_provider.dart';
import 'dart:convert';
import 'package:spotify_ui/services/spotify_services.dart';
// import 'package:spotify_ui/ui/dashboard/songs/widgets/music_player.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final GlobalKey<_SearchBarUIState> _searchBarKey = GlobalKey();
  bool _isProcessingImage = false;

  Future<void> _onSearch(String query) async {
    final searchBarState = _searchBarKey.currentState;
    if (searchBarState == null) return;

    searchBarState._searchController.text = query;
    searchBarState.setState(() => searchBarState._isSearching = true);

    try {
      List<dynamic> tracks = [];
      
      if (['happy', 'sad', 'angry', 'neutral'].contains(query.toLowerCase())) {
        // Try audio features first, fallback to emotion search
        try {
          tracks = await SpotifyService.getTracksByAudioFeatures(query);
        } catch (e) {
          tracks = await SpotifyService.getTracksByEmotion(query);
        }
      } else {
        tracks = await searchBarState._fetchTracks(query);
      }

      searchBarState.setState(() => searchBarState._searchResults = tracks);
    } catch (e) {
      if (searchBarState.mounted) {
        ScaffoldMessenger.of(searchBarState.context).showSnackBar(
          SnackBar(content: Text('Search error: ${e.toString()}')),
        );
      }
    } finally {
      if (searchBarState.mounted) {
        searchBarState.setState(() => searchBarState._isSearching = false);
      }
    }
  }

  Future<void> _handleCameraPress() async {
    if (_isProcessingImage) return;
    setState(() => _isProcessingImage = true);

    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (image == null || !mounted) return;
      // Find the user's emotion
      final result = await compute(_processEmotionInIsolate, image.path);
      final file = File(image.path);
      if (await file.exists()) await file.delete();

      if (!mounted) return;

      if (result == null || result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result?['error'] ?? 'No emotion detected')),
        );
      } else {
        // Get the dominant emotion
        final emotion = result['dominant_emotion']?.toString().toLowerCase() ?? 'neutral';
        _onSearch(emotion); // searches based on the emotion.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.blackColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleUI(),
            mSpacer(mHeight: 14),
            Expanded(
              child: SearchBarUI(
                key: _searchBarKey,
                onSearch: _onSearch,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 10.0),
      child: Row(
        children: [
          Text(
            'Search',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: _isProcessingImage
                ? const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  )
                : const Icon(Icons.camera_enhance_outlined, 
                    size: 30, color: Colors.white),
            onPressed: _handleCameraPress,
          ),
          mSpacer(mWidth: 20),
        ],
      ),
    );
  }
}

class SearchBarUI extends ConsumerStatefulWidget {
  final Function(String) onSearch;
  
  const SearchBarUI({
    super.key,
    required this.onSearch,
  });

  @override
  _SearchBarUIState createState() => _SearchBarUIState();
}

class _SearchBarUIState extends ConsumerState<SearchBarUI> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  List<dynamic> _trackQueue = [];

  bool _isSearching = false;

  Future<List<dynamic>> _fetchTracks(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _trackQueue = [];
      });
      return;
    }

    setState(() => _isSearching = true);
    
    try {
      final accessToken = await SpotifyService.getAccessToken();
      final response = await http.get(
        Uri.parse(
          "https://api.spotify.com/v1/search?q=${Uri.encodeQueryComponent(query)}&type=track&limit=10"
        ),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['tracks']['items'] ?? [];
          _trackQueue = data['tracks']['items'].map((track) => track['id']).toList();
        });
        print("Track Queue: $_trackQueue"); // for debugging
      } else {
        print("Error fetching tracks: ${response.statusCode}");
        setState(() {
          _searchResults = [];
          _trackQueue = [];
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _searchResults = [];
        _trackQueue = [];
      });
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) widget.onSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
            ),
            child: TextField(
              controller: _searchController,
              cursorColor: AppColors.primaryColor,
              autofocus: false,
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: "Search songs, artists...",
                hintStyle: const TextStyle(color: Colors.black),
                border: InputBorder.none,
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search, size: 30),
                  onPressed: _performSearch,
                ),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : null,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
        
        // Search Results
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        'Search for songs',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 20),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final track = _searchResults[index];
                        return _buildTrackItem(track);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildTrackItem(Map<String, dynamic> track) {
    String artists = (track['artists'] as List<dynamic>?)
        ?.map<String>((artist) => artist['name'].toString())
        .join(', ') ?? 'Unknown Artist';

    String durationText = '0:00';
    if (track['duration_ms'] != null) {
      Duration duration = Duration(milliseconds: track['duration_ms'] as int);
      durationText = '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: (track['album']?['images'] as List<dynamic>?)?.isNotEmpty == true
          ? ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                track['album']['images'][0]['url'].toString(),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            )
          : const SizedBox(width: 50, height: 50),
      title: Text(
        track['name']?.toString() ?? 'Unknown Track',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        artists,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        durationText,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
      onTap: () {
        print('Selected track: ${track['name']} (ID: ${track['id']})');

        final musicNotifier = ref.read(musicProvider.notifier);
        final currentTrackId = track['id'];

         // Set the full queue
        musicNotifier.setQueue(plQueue: _trackQueue);

        // Get prev and next based on current song
        final pre = musicNotifier.getPlPre(currentTrackId);
        final nxt = musicNotifier.getPlNext(currentTrackId);

        // Set song details
        musicNotifier.setSong(
          name: track['name'],
          artist: (track['artists'] as List).map((e) => e['name']).join(', '),
          image: track['album']['images'][0]['url'],
          trackId: currentTrackId,
          pre: pre,
          nxt: nxt,
          plQueue: _trackQueue,
        );

        Navigator.pushNamed(
          context, 
          AppRoutes.songsPage, 
          arguments: {'trackId': track['id'] } ,
        );
      },
    );
  }
}
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:spotify_ui/services/emotion_service.dart';
import 'package:spotify_ui/services/spotify_services.dart';

// Isolate function for emotion processing
Future<Map<String, dynamic>?> _processEmotionInIsolate(String imagePath) async {
  try {
    return await EmotionService.detectEmotion(XFile(imagePath));
  } catch (e) {
    return {'error': e.toString()};
  }
}

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
        backgroundColor: Colors.black,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleUI(),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Text(
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
        ],
      ),
    );
  }
}

class SearchBarUI extends StatefulWidget {
  final Function(String) onSearch;
  
  const SearchBarUI({
    super.key,
    required this.onSearch,
  });

  @override
  State<SearchBarUI> createState() => _SearchBarUIState();
}

class _SearchBarUIState extends State<SearchBarUI> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  Future<List<dynamic>> _fetchTracks(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return [];
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
        final tracks = data['tracks']['items'] ?? [];
        setState(() => _searchResults = tracks);
        return tracks;
      }
      throw Exception('Failed to load tracks: ${response.statusCode}');
    } catch (e) {
      setState(() => _searchResults = []);
      rethrow;
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              hintText: "Search songs, artists...",
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: IconButton(
                icon: const Icon(Icons.search, color: Colors.white54),
                onPressed: _performSearch, // Add this line
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            style: const TextStyle(color: Colors.white),
            onSubmitted: (_) => _performSearch(),
          ),
        ),
        Expanded(
          child: _searchResults.isEmpty
              ? const Center(
                  child: Text(
                    'Search for songs',
                    style: TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final track = _searchResults[index];
                    final artists = (track['artists'] as List)
                        .map((a) => a['name'])
                        .join(', ');
                    final duration = Duration(
                        milliseconds: track['duration_ms'] as int);
                    final durationText =
                        '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          track['album']['images'][0]['url'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        track['name'],
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        artists,
                        style: const TextStyle(color: Colors.white54),
                      ),
                      trailing: Text(
                        durationText,
                        style: const TextStyle(color: Colors.white54),
                      ),
                      onTap: () => print('Selected: ${track['name']}'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

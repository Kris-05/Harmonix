import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotify_ui/services/emotion_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:spotify_ui/services/spotify_services.dart';
// Top-level function for isolate processing
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

  void _onSearch(String query) {
    final searchBarState = _searchBarKey.currentState;
    searchBarState?._searchController.text = query;
    searchBarState?._fetchTracks(query);
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

      final result = await compute(_processEmotionInIsolate, image.path);
      
      // Clean up the temporary image file
      final file = File(image.path);
      if (await file.exists()) await file.delete();

      if (!mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No emotion detected')),
        );
      } else if (result.containsKey('error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${result['error']}')),
        );
      } else {
        final emotion = result['dominant_emotion']?.toString().toLowerCase() ?? 'unknown';
        _onSearch(emotion);
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
            _buildTitleUI(context),
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

  Widget _buildTitleUI(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 10.0),
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
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.camera_enhance_outlined, size: 30, color: Colors.white),
            onPressed: _handleCameraPress,
          ),
        ],
      ),
    );
  }
}

class SearchBarUI extends StatefulWidget {
  final Function(String)? onSearch;
  
  const SearchBarUI({super.key, required this.onSearch});

  @override
  State<SearchBarUI> createState() => _SearchBarUIState();
}

class _SearchBarUIState extends State<SearchBarUI> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      widget.onSearch?.call(query);
    }
  }

  Future<void> _fetchTracks(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    try {
      String accessToken = await SpotifyService.getAccessToken();
      final response = await http.get(
        Uri.parse("https://api.spotify.com/v1/search?q=${Uri.encodeQueryComponent(query)}&type=track&limit=10"),
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _searchResults = data['tracks']['items'] ?? []);
      } else {
        throw Exception('Failed to load tracks: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: ${e.toString()}')),
        );
      }
      setState(() => _searchResults = []);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _searchController,
               textAlignVertical: TextAlignVertical.center, // Centers the text
              decoration: InputDecoration(
                hintText: "Search songs, artists...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white54),
                  onPressed: _performSearch,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) => _performSearch(),
            ),

          ),
        ),
        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        'Search for songs',
                        style: TextStyle(color: Colors.white54, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 16),
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
                          onTap: () {
                            print('Selected track: ${track['name']} (ID: ${track['id']})');
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

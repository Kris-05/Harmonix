import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:spotify_ui/services/spotify_services.dart';
// import 'package:spotify_ui/ui/dashboard/songs/widgets/music_player.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.blackColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            mSpacer(),
            titleUI(),
            mSpacer(mHeight: 14),
            const Expanded(
              child: SearchBarUI()
            ), // Wrap with Expanded
          ],
        ),
      ),
    );
  }

  // Search + camera 
  Widget titleUI() {
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
          // for emotion detection
          Icon(Icons.camera_enhance_outlined, size: 30, color: Colors.white),
          mSpacer(mWidth: 20),
        ],
      ),
    );
  }
}

// search bar 
// The UI changes dynamically when searching (loading, results update)
class SearchBarUI extends ConsumerStatefulWidget {
  const SearchBarUI({super.key});

  @override
  _SearchBarUIState createState() => _SearchBarUIState();
}

class _SearchBarUIState extends ConsumerState<SearchBarUI> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  // for fetching song
  Future<void> _fetchTracks(String query) async {
    // check if query is empty
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      String accessToken = await SpotifyService.getAccessToken();
      
      final url = Uri.parse("https://api.spotify.com/v1/search?q=${Uri.encodeQueryComponent(query)}&type=track&limit=10");
      
      // Sends request with the access token for authentication.
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $accessToken",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['tracks']['items'] ?? [];
        });
      } else {
        print("Error fetching tracks: ${response.statusCode}");
        setState(() {
          _searchResults = [];
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _searchResults = [];
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  // Removes extra spaces and calls fn
  void _onSearch() {
    String searchText = _searchController.text.trim();
    _fetchTracks(searchText); // query
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
              onSubmitted: (value) => _onSearch(),
              decoration: InputDecoration(
                hintText: "Search songs, artists...",
                hintStyle: const TextStyle(color: Colors.black),
                border: InputBorder.none,
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search, size: 30),
                  onPressed: _onSearch,
                ),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15), // Adjusts text alignment
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
    // Converts list of artists into a single string.
    String artists = (track['artists'] as List<dynamic>?)
        ?.map<String>((artist) => artist['name'].toString())
        .join(', ') ?? 'Unknown Artist';

    // Formats Song Duration (e.g., "3:45")
    String durationText = '0:00';
    if (track['duration_ms'] != null) {
      Duration duration = Duration(milliseconds: track['duration_ms'] as int);
      durationText = '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }

    // Displays song info & prints track name on tap.
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
        Navigator.pushNamed(
          context, 
          AppRoutes.songsPage, 
          arguments: {'trackId': track['id'] } , // Replace with actual track ID
        );
      },
    );
  }
}
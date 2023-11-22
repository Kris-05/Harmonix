import 'package:flutter/material.dart';
import 'package:spotify_ui/api/playlistApi.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:spotify_ui/services/ spotify_services.dart';

class SearchPageLib extends StatefulWidget {
  void Function() onSearched;
  final String id;
  SearchPageLib({super.key, required this.onSearched,required this.id, });

  @override
  State<SearchPageLib> createState() => _SearchPageLibState();
}

class _SearchPageLibState extends State<SearchPageLib> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blackColor,
      child: SearchBarUI(onSearched:widget.onSearched,id:widget.id),
    );
  }
}

class SearchBarUI extends StatefulWidget {
  void Function() onSearched;
  late String id;
 SearchBarUI({super.key,required this.onSearched,required this.id});

  @override
  _SearchBarUIState createState() => _SearchBarUIState();
}

class _SearchBarUIState extends State<SearchBarUI> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  List<Map<String, dynamic>> _selectedSongs = [];

  Future<void> _fetchTracks(String query) async {
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

      final url = Uri.parse(
          "https://api.spotify.com/v1/search?q=${Uri.encodeQueryComponent(query)}&type=track&limit=10");

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

  
  void _onSearch() {
    String searchText = _searchController.text.trim();
    _fetchTracks(searchText);
  }

  void _toggleSong(Map<String, dynamic> track) {
    bool isAlreadyAdded =
        _selectedSongs.any((song) => song['id'] == track['id']);

    setState(() {
      if (isAlreadyAdded) {
        _selectedSongs.removeWhere((song) => song['id'] == track['id']);
      } else {
        _selectedSongs.add(track);
      }
    });
  }

  void _onDonePressed() async {
    print("Selected Songs:");
    
    List<dynamic> songs=[];
    for (var song in _selectedSongs) {
      print("${song['name']} - ${song['id']} ");

      songs.add({
        'id':song['id'],
        'name':song['name']
      });
    
    }

    try{
      print(songs);
      final res=await Playlistapi.addToPlaylist(id: widget.id,songs:songs,email:"sakthi@gmail.com");
      print("added to the PlayList!!");
      widget.onSearched();
  
    }
    catch(err){
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11.0, vertical: 10.0),
          child: Container(
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
                  icon: const Icon(Icons.search, size: 20),
                  onPressed: _onSearch,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12), // Center text vertically
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
          ),
        ),

        Expanded(
          child: _isSearching
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        'Colour Your Playlist',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 10),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final track = _searchResults[index];
                        return _buildTrackItem(track);
                      },
                    ),
        ),


        if (_selectedSongs.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              children: [
                ElevatedButton(
              onPressed: _onDonePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text(
                "Done",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            mSpacer(
              mHeight: 50.0
            )
              ],
            )
          ),
      ],
    );
  }

  Widget _buildTrackItem(Map<String, dynamic> track) {
    String artists = (track['artists'] as List<dynamic>?)
            ?.map<String>((artist) => artist['name'].toString())
            .join(', ') ??
        'Unknown Artist';

    bool isAdded = _selectedSongs.any((song) => song['id'] == track['id']);

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
                errorBuilder: (context, error, stackTrace) {
                  return _defaultImage(); 
                },
              ),
            )
          : _defaultImage(),
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
      trailing: IconButton(
        icon: Icon(
          isAdded ? Icons.remove_circle_outline : Icons.add_circle_outline,
          color: isAdded ? Colors.red : Colors.green,
          size: 28,
        ),
        onPressed: () => _toggleSong(track),
      ),
    );
  }

  Widget _defaultImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(
        'assets/images/MGK.png', 
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
    );
  }
}

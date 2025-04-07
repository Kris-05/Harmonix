import 'package:flutter/material.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/api/playlistApi.dart';

class CreatePlaylist extends StatefulWidget {
  const CreatePlaylist({super.key, required this.fetchPl});
  final VoidCallback fetchPl;
  @override
  State<CreatePlaylist> createState() => _CreatePlaylistState();
}

class _CreatePlaylistState extends State<CreatePlaylist> {
  TextEditingController _playlistNameController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _playlistNameController.text = "Playlist Name";
    _focusNode.requestFocus();
    _playlistNameController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _playlistNameController.text.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title Text
                const Text(
                  "Give your playlist a name",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                mSpacer(mHeight: 25),

                // TextField with Error Handling
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _playlistNameController,
                    focusNode: _focusNode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 30),
                    decoration: InputDecoration(
                      //  Show error below the line
                      errorText: _errorText,
                      errorStyle: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                mSpacer(mHeight: 40),

                // Button Row (Cancel and Create)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel Button
                    OutlinedButton(
                      onPressed: ()async {
                        
                        FocusScope.of(context).unfocus();
                        await Future.delayed(Duration(milliseconds: 100));
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),

                    // Create Button
                    ElevatedButton(
                      onPressed: ()async{
                          String playlistName = _playlistNameController.text.trim();
                                if (playlistName.isEmpty) {
                                  setState(() {
                                    _errorText = "Playlist name cannot be empty"; 
                                  });
                                } else {
                                  setState(() {
                                    _errorText = null; 
                                  });
                                  try{
                                    
                                    await Playlistapi.createPlaylistApi(playListName:playlistName,email:"sakthi@gmail.com");
                                    print("playlist Created With Name!!!");
                                    widget.fetchPl();
                                    FocusScope.of(context).unfocus();
                                    await Future.delayed(Duration(milliseconds: 100));
                                    Navigator.pop(context);

                                  }
                                  catch(err){
                                    print("Err:${err.toString()}");
                                  }
                                }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1DB954),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        "Create",
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

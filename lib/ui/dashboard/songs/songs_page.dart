import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/ui/dashboard/songs/widgets/music_slab.dart';

class SongsPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onSongSelected;

  const SongsPage({super.key, required this.onSongSelected});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _recognizedText = "";
  bool _speechAvailable = false;

  final List<Map<String, dynamic>> mRecentPlayedList = [
    {
      "imgPath": "assets/images/Afterburner.png",
      "name": "One - Metallica",
      "artist": "1(Remastered)"
    },
    {
      "imgPath": "assets/images/Anthem.png",
      "name": "Summertime Sadness",
      "artist": "Lana Del Rey"
    },
    {
      "imgPath": "assets/images/Artists.png",
      "name": "Let's Get It On",
      "artist": "Marvin Gaye"
    },
    {
      "imgPath": "assets/images/Bryce_Vine.png",
      "name": "Drew Barrymore",
      "artist": "Indie Pop"
    },
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) => print('Status: $status'),
        onError: (error) => print('Error: $error'),
      );
      setState(() {});
    } catch (e) {
      print("Error initializing speech: $e");
    }
  }

  Future<void> _toggleRecording() async {
    try {
      // Request microphone permission
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        print("Microphone permission denied");
        return;
      }

      if (_isListening) {
        await _speech.stop();
        setState(() => _isListening = false);
        print("Final Recognized Text: $_recognizedText");
        
        // Here you could add logic to search songs based on recognized text
        if (_recognizedText.isNotEmpty) {
          _searchSongs(_recognizedText);
        }
      } else {
        if (_speechAvailable) {
          setState(() {
            _isListening = true;
            _recognizedText = "";
          });
          
          _speech.listen(
            onResult: (result) {
              setState(() {
                _recognizedText = result.recognizedWords;
              });
            },
            listenFor: const Duration(seconds: 30),
            pauseFor: const Duration(seconds: 5),
            localeId: "en_US", // Set your preferred language
          );
        } else {
          print("Speech recognition not available");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Speech recognition not available")),
          );
        }
      }
    } catch (e) {
      print("Error in speech recognition: $e");
      setState(() => _isListening = false);
    }
  }

  void _searchSongs(String query) {
    // Implement your song search logic here
    print("Searching for songs with query: $query");
    // You could filter mRecentPlayedList based on the query
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.blackColor,
        body: Column(
          children: [
            mSpacer(),
            recentlyPlayedUI(),
            if (_recognizedText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  "You said: $_recognizedText",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            mSpacer(),
            recentlyPlayedList(),
            playListUI(),
            mSpacer(mHeight: 20),
          ],
        ),
        floatingActionButton: _isListening
            ? FloatingActionButton(
                onPressed: _toggleRecording,
                backgroundColor: Colors.red,
                child: const Icon(Icons.mic, color: Colors.white),
              )
            : null,
      ),
    );
  }

  Widget recentlyPlayedUI() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const Text(
                "Recently Played",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(Icons.camera_alt, size: 25, color: Colors.white),
              mSpacer(),
              GestureDetector(
                onTap: _toggleRecording,
                child: Icon(
                  _isListening ? Icons.mic_off : Icons.mic,
                  size: 25,
                  color: _isListening ? Colors.red : Colors.white,
                ),
              ),
              mSpacer(),
              SvgPicture.asset("assets/svg/Settings.svg", color: Colors.white),
            ],
          ),
        )
      ],
    );
  }

  Widget recentlyPlayedList() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mRecentPlayedList.length,
        itemBuilder: (_, i) {
          return GestureDetector(
            onTap: () {
              widget.onSongSelected(mRecentPlayedList[i]);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                children: [
                  Image.asset(
                    mRecentPlayedList[i]['imgPath'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  mSpacer(),
                  SizedBox(
                    width: 100,
                    child: Text(
                      mRecentPlayedList[i]['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget playListUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Playlist",
            style: TextStyle(color: Colors.white, fontSize: 22),
          ),
          mSpacer(),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: Icon(Icons.add, color: Colors.white, size: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}
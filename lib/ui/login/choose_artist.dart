import 'dart:math';
import 'package:flutter/material.dart';
import 'package:spotify_ui/api/auth.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/ui/custom_widgets/circular_img.dart';
import 'package:spotify_ui/ui/custom_widgets/custom_button.dart';
import 'package:spotify_ui/ui/dashboard/home_page.dart';
import '../../services/spotify_services.dart';

// ignore: must_be_immutable
class ChooseArtist extends StatefulWidget {
  const ChooseArtist({super.key});

  @override
  State<ChooseArtist> createState() => _ChooseArtistState();
}

class _ChooseArtistState extends State<ChooseArtist> {
  late String email;
  late String password;
  late String gender;
  late List<String> languages;
  late String name;

  List<int> selectedArtist = [];
  List<Map<String, dynamic>> mArtist = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get arguments passed from the previous page
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Assign arguments to variables safely with fallback values
    email = args?['email'] ?? 'N/A';
    password = args?['password'] ?? 'N/A';
    gender = args?['gender'] ?? 'N/A';
    languages = args?['languages'] ?? [];
    name = args?['name'] ?? [];

    // fetchartists from spotify
    fetchArtists();
  }

  Future<void> fetchArtists() async {
    try {
      List<Map<String, dynamic>> fetchedArtists =
          await SpotifyService.getTopArtists();
      setState(() {
        mArtist = _getRandomArtists(fetchedArtists, 15);
      });
    } catch (e) {
      print("Error fetching artists: $e");
    }
  }

  List<Map<String, dynamic>> _getRandomArtists(
    List<Map<String, dynamic>> artists,
    int count,
  ) {
    final random = Random();
    List<Map<String, dynamic>> shuffled = List.from(artists)..shuffle(random);
    return shuffled.take(count).toList();
  }

  List mapArtist(List<int> indices) {
    return indices.map((index) => mArtist[index]["name"]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.blackColor,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Choose 3 or more artists you like",
                style: TextStyle(
                  fontSize: 25,
                  // fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              mSpacer(),
              SizedBox(
                height: 50,
                child: TextField(decoration: getTextDecoration()),
              ),
              mSpacer(mHeight: 20),
              Expanded(
                child: Stack(
                  children: [
                    mArtist.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : GridView.builder(
                          itemCount: mArtist.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 12,
                                childAspectRatio: 6 / 8,
                                crossAxisSpacing: 12,
                              ),
                          itemBuilder: (_, index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedArtist.contains(index)
                                      ? selectedArtist.remove(index)
                                      : selectedArtist.add(index);
                                });
                              },
                              child: Column(
                                children: [
                                  CircularImage(
                                    imgPath: mArtist[index]['imgPath'],
                                    isSelected: selectedArtist.contains(index),
                                  ),
                                  mSpacer(),
                                  Text(
                                    mArtist[index]['name'],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.blackColor.withOpacity(0.4),
                              AppColors.blackColor.withOpacity(0.7),
                            ],
                          ),
                        ),
                        child:
                            selectedArtist.length >= 3
                                ? nxtButton(context)
                                : Container(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget nxtButton(BuildContext context) => Center(
    child: CustomButton(
      onTap: () async {
        print("Saving the Uer With The Artist");
        print(selectedArtist);
        dynamic artists = mapArtist(selectedArtist);
        print(artists);
        try {
          final res = await Auth.createAccountApi(
            email: email,
            password: password,
            gender: gender,
            name: name,
            languages: languages,
            arts: artists,
          );
          if (res != null) {
            print("inside parent if"); // Ensure API response is valid before navigating
            if (mounted) { // Check if widget is still in the tree
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }
          } else {
            print("Error: API response is null.");
          }

          print(res);
        } catch (err) {
          print(err);
        }
      },
      text: "Next",
      bgColor: AppColors.whiteColor,
      mWidth: 100,
    ),
  );
}

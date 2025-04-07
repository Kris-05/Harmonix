import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_ui/api/auth.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/ui_helper.dart';// update this path
import 'package:spotify_ui/providers/user_provider.dart';
import 'package:spotify_ui/services/spotify_service.dart';
import 'package:spotify_ui/ui/custom_widgets/circular_img.dart';
import 'package:spotify_ui/ui/custom_widgets/custom_button.dart';
import 'package:spotify_ui/ui/dashboard/home_page.dart';

// ignore: must_be_immutable
class ChooseArtist extends ConsumerStatefulWidget {
  const ChooseArtist({super.key});

  @override
  ConsumerState<ChooseArtist> createState() => _ChooseArtistState();
}

class _ChooseArtistState extends ConsumerState<ChooseArtist> {
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
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    email = args?['email'] ?? 'N/A';
    password = args?['password'] ?? 'N/A';
    gender = args?['gender'] ?? 'N/A';
    languages = args?['languages'] ?? [];
    name = args?['name'] ?? 'User';

    fetchArtists();
  }

  Future<void> fetchArtists() async {
    try {
      List<Map<String, dynamic>> fetchedArtists = await SpotifyService.getTopArtists();
      setState(() {
        mArtist = _getRandomArtists(fetchedArtists, 15);
      });
    } catch (e) {
      print("Error fetching artists: $e");
    }
  }

  List<Map<String, dynamic>> _getRandomArtists(List<Map<String, dynamic>> artists, int count) {
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
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                        child: selectedArtist.length >= 3
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
            dynamic artists = mapArtist(selectedArtist);
            try {
              final res = await Auth.createAccountApi(
                email: email,
                password: password,
                gender: gender,
                name: name,
                languages: languages,
                arts: artists,
              );
              ref.read(loginProvider.notifier).login(name, email);
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              }
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

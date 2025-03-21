import 'package:flutter/material.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/ui/custom_widgets/circular_img.dart';
import 'package:spotify_ui/ui/custom_widgets/custom_button.dart';

// ignore: must_be_immutable
class ChooseArtist extends StatefulWidget {
  const ChooseArtist({super.key});

  @override
  State<ChooseArtist> createState() => _ChooseArtistState();
}

class _ChooseArtistState extends State<ChooseArtist> {
  List<int> selectedArtist = [];
  List<Map<String, dynamic>> mArtist = [
    {
      "imgPath": "assets/images/Members.png",
      "name": "Members",
    },
    {
      "imgPath": "assets/images/Afterburner.png",
      "name": "After Burner",
    },
    {
      "imgPath": "assets/images/Anthem.png",
      "name": "Anthem",
    },
    {
      "imgPath": "assets/images/Artists.png",
      "name": "Artists",
    },
    {
      "imgPath": "assets/images/bg.png",
      "name": "bg",
    },
    {
      "imgPath": "assets/images/Bryce_Vine.png",
      "name": "Bryce Vine",
    },
    {
      "imgPath": "assets/images/Chon.png",
      "name": "Chon",
    },
    {
      "imgPath": "assets/images/Coastin.png",
      "name": "Coastin",
    },
    {
      "imgPath": "assets/images/Default.png",
      "name": "Default",
    },
    {
      "imgPath": "assets/images/From_the_Fires.png",
      "name": "From the fires",
    },
    {
      "imgPath": "assets/images/Iconic.png",
      "name": "Iconic",
    },
    {
      "imgPath": "assets/images/MGK.png",
      "name": "MGK",
    },
    {
      "imgPath": "assets/images/Mothership.png",
      "name": "Mothership",
    },
    {
      "imgPath": "assets/images/Tycho.png",
      "name": "Tycho",
    },
    {
      "imgPath": "assets/images/Members.png",
      "name": "Members",
    },
    {
      "imgPath": "assets/images/Afterburner.png",
      "name": "After Burner",
    },
    {
      "imgPath": "assets/images/Anthem.png",
      "name": "Anthem",
    },
    {
      "imgPath": "assets/images/Artists.png",
      "name": "Artists",
    },
    {
      "imgPath": "assets/images/bg.png",
      "name": "bg",
    },
    {
      "imgPath": "assets/images/Bryce_Vine.png",
      "name": "Bryce Vine",
    },
    {
      "imgPath": "assets/images/Chon.png",
      "name": "Chon",
    },
    {
      "imgPath": "assets/images/Coastin.png",
      "name": "Coastin",
    },
    {
      "imgPath": "assets/images/Default.png",
      "name": "Default",
    },
    {
      "imgPath": "assets/images/From_the_Fires.png",
      "name": "From the fires",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.blackColor,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("Choose 3 or more artists you like",
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
                child: TextField(
                  decoration: getTextDecoration(),
                ),
              ),
              mSpacer(mHeight: 20),
              Expanded(
                child: Stack(
                  children: [
                    GridView.builder(
                      itemCount: mArtist.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12,
                        childAspectRatio: 6/8,
                        crossAxisSpacing: 12,
                      ),
                      itemBuilder: (_, index){
                        return InkWell(
                          onTap: (){
                            if(!selectedArtist.contains(index)){
                              setState(() {
                                selectedArtist.add(index);
                              });
                            } else {
                              setState(() {
                                selectedArtist.remove(index);
                              });
                            }
                          },
                          child: Column(
                            children: [
                              CircularImage(imgPath: mArtist[index]['imgPath'], isSelected: selectedArtist.contains(index)),
                              mSpacer(),
                              Text(mArtist[index]['name'], style: TextStyle(color: Colors.white, fontSize: 12),)
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
                            ]
                          )
                        ),
                        child: selectedArtist.length >= 3 ? nxtButton() : Container(),
                      ),
                    )
                  ],      
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget nxtButton() => Center(
    child: CustomButton(
      onTap: (){
        Navigator.pushNamed(context, AppRoutes.homePage);
      }, 
      text: "Next",
      bgColor: AppColors.whiteColor,
      mWidth: 100,
    ),
  );
}
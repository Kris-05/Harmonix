import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/ui/custom_widgets/type_button_chip.dart';
import 'package:spotify_ui/ui/custom_widgets/liked_songs_lib.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: SafeArea(child: Scaffold(
        backgroundColor: AppColors.blackColor,
        body:SingleChildScrollView(
          child: Column(
          children: [
            mSpacer(),
            libraryHeader(),
            mSpacer(),
            libraryButtons(),
            mSpacer(
              mHeight: 14
            ),
            libRecent(),
            mSpacer(
              mHeight: 14
            ),
            LikedSongsLib(likedCount: 10,title: "Liked Songs",subTitle: "Playlist",),
          ],
        ),
        )
      ))
    );
  }
}


Widget libraryHeader(){
    return 
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(),
                mSpacer(),
                Text("Your Library",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Spacer(),
                Icon(Icons.add,size: 35,color: Colors.grey),
              ],
            ),
          );
  }

Widget libraryButtons(){
  List<String> libNavi=["Playlists","Artists","Albums","Podcasts & shows"];
  return(
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 11.0,vertical: 5.0),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: libNavi.length,
          itemBuilder: (_,ind){
            return TypeButtonChip(name:libNavi[ind]);
          }
          
          ),
      )
      )
  );
}


Widget libRecent(){
  return  Padding(    
    padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 7.0),
    child: Row(
      children: [
        RotatedBox(
        quarterTurns: 1,
        child: Icon(Icons.compare_arrows_rounded,color: Colors.white,size: 16,),
        ),
        
        Text("Recently played",style: TextStyle(color: Colors.white,fontSize:13,fontWeight:FontWeight.bold ),),
        Spacer(),
        SvgPicture.asset("assets/svg/menuLib.svg",color: Colors.white,),
      ],
  )
  );
}
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/ui_helper.dart';

class LikedSongsLib extends StatefulWidget {
  final String title;
  final String subTitle;
  final int likedCount;
  bool isPinned;

  LikedSongsLib({super.key,required this.title,required this.subTitle,required this.likedCount, this.isPinned=true});

  @override
  State<LikedSongsLib> createState() => _LikedSongsLibState();
}

class _LikedSongsLibState extends State<LikedSongsLib> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){
        print("Tap Clicked!!!");
      },
      leading: Container(
        width:60,
        height: 60,
        
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          gradient:LinearGradient(colors: [
            Color(0xff4A39EA),
            Color(0xff868AE1),
            Color(0xffB9D4DB)
          ],
          begin: Alignment.topLeft,
          end:Alignment.bottomRight)
        ),
        child: Center(
          child: Icon(Icons.favorite,color: Colors.white,),
        ),
      ),
      title: Text(widget.title),
      titleTextStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),
      subtitle: Row(
        children: [
          if(widget.isPinned)
            SvgPicture.asset("assets/svg/Pin.svg",color: Color(0xff1ED760),height: 14,width: 8),
          if(widget.isPinned)
            mSpacer(
              mWidth:3,
            ),

          Text("${widget.subTitle} . ${widget.likedCount} songs",style: TextStyle(color: Color(0xffB3B3B3))),
        ],
      ),
    );
  }
}
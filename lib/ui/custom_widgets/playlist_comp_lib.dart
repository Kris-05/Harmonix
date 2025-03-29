import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/ui_helper.dart';

class PlaylistComp extends StatefulWidget {
  final String title;
  final String subTitle;
  final int likedCount;
  bool isPinned=false;

  PlaylistComp({super.key,required this.title,required this.subTitle,required this.likedCount, this.isPinned=false});

  @override
  State<PlaylistComp> createState() => _PlaylistCompState();
}

class _PlaylistCompState extends State<PlaylistComp> {
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
          SvgPicture.asset("assets/svg/Pin.svg",color: Color(0xff1ED760),height: 14,width: 8,),
          mSpacer(
            mWidth:3,
          ),
          Text("${widget.subTitle} . ${widget.likedCount} songs",style: TextStyle(color: Color(0xffB3B3B3))),
        ],
      ),
    );
  }
}
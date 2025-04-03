import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/ui_helper.dart';

class ArtistComp extends StatefulWidget {

  final String ArtistName;
  bool isPinned=false;

  ArtistComp({super.key,required this.ArtistName, this.isPinned=false});

  @override
  State<ArtistComp> createState() => _ArtistCompState();
}

class _ArtistCompState extends State<ArtistComp> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){
        print("Tap Clicked!!!");
      },
      leading:
      ClipOval(child: Image.asset("assets/images/Members.png",height: 60,width: 60)),
      title: Text(widget.ArtistName),
      titleTextStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),
      subtitle: Row(
        children: [
          if(widget.isPinned)
            SvgPicture.asset("assets/svg/Pin.svg",color: Color(0xff1ED760),height: 14,width: 8),
          if(widget.isPinned)
            mSpacer(
              mWidth:3,
            ),

          Text("Artist",style: TextStyle(color: Color(0xffB3B3B3))),
        ],
      ),
    );
  }
}
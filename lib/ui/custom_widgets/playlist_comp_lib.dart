import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/ui_helper.dart';

class PlaylistComp extends StatefulWidget {
  final String title;
  final String subTitle;
  final String Owner;
  bool isPinned=false;
  final String  id;
  final VoidCallback onUpdate;

  PlaylistComp({super.key,required this.title,this.subTitle="Playlist",required this.Owner, this.isPinned=false,required this.id, required this.onUpdate});

  @override
  State<PlaylistComp> createState() => _PlaylistCompState();
}

class _PlaylistCompState extends State<PlaylistComp> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      
      onTap: ()async {
        Navigator.pushNamed(context, AppRoutes.playListSpecific,arguments: {
          'isLiked':false,
          'BgColor':await getColorPlate('assets/images/MGK.png'),
          'id':widget.id,
          'playListName':widget.title,
          'onUpdate':widget.onUpdate
        });
      },

      leading: ClipRRect( borderRadius: BorderRadius.circular(12),child: Image.asset("assets/images/Members.png",height: 60,width: 60)),
      title: Text(widget.title),
      titleTextStyle: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16),
      // subtitleTextStyle: TextStyle(color: Color(0xffB3B3B3),fontWeight: FontWeight.bold,fontSize: 13),
      subtitle: Row(
        children: [
          if(widget.isPinned)
            SvgPicture.asset("assets/svg/Pin.svg",color: Color(0xff1ED760),height: 14,width: 8),
          if(widget.isPinned)
            mSpacer(
              mWidth:3,
            ),

          Text("${widget.subTitle} . ${widget.Owner}",style: TextStyle(color: Color(0xffB3B3B3))),
        ],
      ),
    );
  }
}
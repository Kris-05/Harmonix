import 'package:flutter/material.dart';
import 'package:spotify_ui/api/spotify.dart';


class SongIndiComp extends StatefulWidget {
  final String title;
  final String id;
  final String? imageUrl;
  late String owner;
  late dynamic notifier;
  late String pre;
  late String nxt;
  late List<dynamic>pl;
  
  SongIndiComp({
    super.key,
    required this.title,
    required this.id, 
    this.imageUrl,
    required this.notifier,
    required this.pre,
    required this.nxt,
    required this.pl,
  });

  @override
  State<SongIndiComp> createState() => _SongIndiCompState();
}

class _SongIndiCompState extends State<SongIndiComp> {
   String? artistName;
   String? albumImageUrl;

  @override
  void initState() {
    super.initState();
    fetchSongDetails();
  }

   Future<void> fetchSongDetails() async {
    var songData = await Spotify.getSongInfo(widget.id);
    
    if (songData != null) {
      setState(() {
        artistName = songData["artists"][0]["name"];
        albumImageUrl = songData["album"]["images"][0]["url"];
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
       if(artistName !=null && albumImageUrl !=null){
        print("Setting the Notifier!!! ${widget.pl}");
        widget.notifier.setQueue(plQueue:widget.pl);
        widget.notifier.setSong(name:widget.title, artist:artistName , image:albumImageUrl,trackId:widget.id,pre:widget.pre,nxt:widget.nxt);
       }
      },
      child:  Padding(
      padding: const EdgeInsets.symmetric( vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: albumImageUrl != null
                ? Image.network(
                    albumImageUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "assets/images/Members.png",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  artistName != null? artistName!:"Naa Thaa...",
                  style: const TextStyle(
                    color: Color(0xffB3B3B3),
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

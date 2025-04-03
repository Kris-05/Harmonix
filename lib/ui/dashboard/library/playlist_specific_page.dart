import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/ui/dashboard/library/song_individual_widget.dart';
import 'package:spotify_ui/api/playlistApi.dart';
import 'package:spotify_ui/ui/dashboard/library/search_page_for_playlist.dart';

class PlaylistSpecificPage extends StatefulWidget {
  final bool isLiked;
  final PaletteGenerator bgColor;
  final String playListName;
  final String id;
  VoidCallback onUpdate;

  PlaylistSpecificPage({
    super.key,
    required this.isLiked,
    required this.bgColor,
    required this.playListName,
    required this.id, required this.onUpdate,
  });

  @override
  State<PlaylistSpecificPage> createState() => _PlaylistSpecificPageState();
}

class _PlaylistSpecificPageState extends State<PlaylistSpecificPage> {
  late PaletteGenerator _dynamicGradient;
  ScrollController _scrollController = ScrollController();
  bool showTitleInAppBar = false;
  bool isAddingSongs = false;
  bool isLiked=false;

  // Fetch playlist using Future to reload on every build
  late Future<List<dynamic>> _playlistFuture;

  @override
  void initState() {
    super.initState();
    _fetchPlaylist();
    _fetchLike();
    _dynamicGradient = widget.bgColor;

    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !showTitleInAppBar) {
        setState(() {
          showTitleInAppBar = true;
        });
      } else if (_scrollController.offset <= 200 && showTitleInAppBar) {
        setState(() {
          showTitleInAppBar = false;
        });
      }
    });
  }

  
  void _fetchPlaylist(){
    setState(()  {
      _playlistFuture =  Playlistapi.getPlayListSongs(
        id: widget.id.toString(),
        email: "sakthi@gmail.com",
      );
    });
  }

  void _fetchLike()async{
    isLiked=await Playlistapi.isPlaylistLiked(id: widget.id.toString(),
        email: "sakthi@gmail.com",);
    print("\n\n\nisLIked::$isLiked\n\n\n\n");

    setState(() {
    isLiked = isLiked;
    });
  }

  void _onSongsAdded() {
    setState(() {
      isAddingSongs = false;
      _fetchPlaylist();
    });
  }

  void changeLike()async {
    await Playlistapi.ChangeLike(id: widget.id.toString(),
        email: "sakthi@gmail.com",);
    print("Like Changed");

    setState(() {
      isLiked=!isLiked;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color dominantColor = widget.bgColor.dominantColor?.color ?? Colors.grey;
    bool isBrightColor = dominantColor.computeLuminance() > 0.6;

    Color adjustedColor =
        isBrightColor
            ? Color.alphaBlend(Colors.black.withOpacity(0.2), dominantColor)
            : dominantColor;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [adjustedColor, Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          
          isAddingSongs
              ? Column(
                children: [
                  AppBar(
                    backgroundColor: Colors.black,
                    elevation: 0,
                    leading: InkWell(
                      onTap: () {
                        setState(() {
                          isAddingSongs = false;
                        });
                      },
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    title: const Text(
                      "Add Songs to Playlist",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: SearchPageLib(
                      onSearched:
                          _onSongsAdded,
                      id: widget.id// Callback to refresh after adding
                    ),
                  ),
                ],
              )
              : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 300,
                    elevation: 0,
                    flexibleSpace: LayoutBuilder(
                      builder: (context, constraints) {
                        double percent =
                            (constraints.maxHeight - kToolbarHeight) /
                            (300 - kToolbarHeight);

                        double imageSize = 180 * percent.clamp(0.4, 1.0);
                        double imageOpacity = percent.clamp(0.0, 1.0);

                        return FlexibleSpaceBar(
                          background: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 80),
                              Center(
                                child: Opacity(
                                  opacity: imageOpacity,
                                  child: playlistPic(
                                    'assets/images/MGK.png',
                                    height: imageSize,
                                    width: imageSize,
                                  ),
                                ),
                              ),
                              mSpacer(mHeight: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                child: Opacity(
                                  opacity: imageOpacity,
                                  child: Text(
                                    widget.playListName,
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    backgroundColor:
                        showTitleInAppBar
                            ? adjustedColor.withOpacity(1)
                            : Colors.transparent,
                    leading: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: SvgPicture.asset(
                          "assets/svg/Left.svg",
                          color: Colors.white,
                        ),
                      ),
                    ),
                    title:
                        showTitleInAppBar
                            ? Text(
                              widget.playListName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                            : null,
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          mSpacer(mHeight: 6),

                          ownerRow("SakthiPriyan"),
                          mSpacer(mHeight: 7),

                          Row(
                            children: [
                              iconWidget(
                                context,
                                isLiked,
                                widget.playListName,
                                "email",
                                widget.id,
                                (){
                                  setState(() {
                                    isAddingSongs=true;
                                  });
                                },
                                changeLike,
                                widget.onUpdate,
                              
                              ),
                              const Spacer(),
                              const CircleAvatar(),
                            ],
                          ),
                          mSpacer(),
                 FutureBuilder<List<dynamic>>(
                            future: _playlistFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return const Center(
                                  child: Text(
                                    "Error loading songs! Try again.",
                                  ),
                                );
                              }
                              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return noSongsComp(context);
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.symmetric(vertical: 0),
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  final song = snapshot.data![index];
                                  return songComp(
                                    owner: song['artist'] ?? "Unknown",
                                    title: song['name'] ?? "Unknown Song",
                                    isAdd: false,
                                  );
                                },
                              );
                            },
                          ),
                        
                        mSpacer(mHeight: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }

  void showAddSongsPage() {
    setState(() {
      isAddingSongs = true;
    });
  }

  Widget noSongsComp(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        mSpacer(mHeight: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Start Building Your Playlist",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                mSpacer(mHeight: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    showAddSongsPage();
                  },
                  icon: const Icon(Icons.add, color: Colors.black, size: 25),
                  label: const Text(
                    "Add to this Playlist",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
        mSpacer(mHeight: 32),
        const Text(
          "Recommended Songs",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        const Text(
          "Based on your listening!",
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        mSpacer(mHeight: 5),

        ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 2),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 5, // Dummy Recommended Songs
          itemBuilder: (_, ind) {
            return songComp(
              owner: "Owner ${ind + 1}",
              title: "Song ${ind + 1}",
            );
          },
        ),
      ],
    );
  }
}

// Playlist Picture with Animation
Widget playlistPic(String imgPath, {double height = 180, double width = 180}) {
  return Container(
    height: height,
    width: width,
    child: Image.asset(imgPath, fit: BoxFit.cover),
  );
}

// Owner Info Row
Widget ownerRow(String owner) {
  return Row(
    children: [
      const CircleAvatar(),
      mSpacer(mWidth: 5),
      Text(
        owner,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

// Playlist Actions (Add/Delete)
Widget iconWidget(context,bool isLik,plname, email, id,func,changeLike,VoidCallback onUp) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "Album . 2024",
        style: TextStyle(fontSize: 13, color: Color(0xffB3B3B3)),
      ),
      mSpacer(mHeight: 6),
      Row(
        children: [
          InkWell(
            onTap: () {
              changeLike();
            },
            child: Icon(
              Icons.favorite,
              color: isLik?Color(0xff1ED760):Color(0xffB3B3B3),
              size: 25,
            ),
          ),
          mSpacer(mWidth: 40),
          InkWell(
            onTap: () {
              func();
            },
            child: const Icon(Icons.add, color: Color(0xffB3B3B3), size: 25),
          ),
          mSpacer(mWidth: 40),
          InkWell(
            onTap: ()async {
              print("Del Clicked!!");
              try {
                await Playlistapi.deletePlaylist(playListName: plname, id: id);
                onUp();
                Navigator.pop(context);
                print("Playlist Deleted!!!");
              } catch (err) {
                print(err.toString());
              }
            },
            child: const Icon(Icons.delete, color: Color(0xffB3B3B3), size: 25),
          ),
        ],
      ),
    ],
  );
}

// Song Component
Widget songComp({
  required String owner,
  required String title,
  bool isAdd = true,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 0.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(child: SongIndiComp(title: title, owner: owner)),
        const SizedBox(width: 8),
        if (!isAdd)
          const Icon(
            Icons.more_vert_outlined,
            color: Color(0xffABA4A3),
            size: 25,
          ),
        if (isAdd)
          const Icon(Icons.add_circle_outline, color: Colors.green, size: 28),
      ],
    ),
  );
}

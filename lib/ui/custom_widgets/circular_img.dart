import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CircularImage extends StatelessWidget {
  double mWidth;
  double mHeight;
  String imgPath;
  bool isSelected;

  CircularImage({super.key,required this.imgPath,this.isSelected = true ,this.mWidth = 100, this.mHeight = 100});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: mWidth,
      height: mHeight,
      decoration: BoxDecoration(
        border: Border.all(
          strokeAlign: BorderSide.strokeAlignCenter,
          color: isSelected ? Colors.white : Colors.transparent,
          width: isSelected ? 2: 0,
        ),
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage(imgPath),
        ),
      ),
      child: isSelected ? Center(
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.5),
          radius: mWidth/2,
          child: Icon(Icons.done, color: Colors.white)
        ),
      ) : Container(),
    );
  }
}
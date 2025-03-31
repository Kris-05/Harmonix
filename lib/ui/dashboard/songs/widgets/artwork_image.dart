import 'package:flutter/material.dart';

class ArtworkImage extends StatelessWidget {
  final String image;

  const ArtworkImage({ super.key, required this.image });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      height: MediaQuery.of(context).size.height * .4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(image),
        ),
      ),
    );
  }
}
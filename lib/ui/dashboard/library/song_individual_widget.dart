import 'package:flutter/material.dart';


class SongIndiComp extends StatefulWidget {
  final String title;
  final String owner;
  final String? imageUrl;

  const SongIndiComp({
    super.key,
    required this.title,
    required this.owner,
    this.imageUrl,
  });

  @override
  State<SongIndiComp> createState() => _SongIndiCompState();
}

class _SongIndiCompState extends State<SongIndiComp> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric( vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                ? Image.network(
                    widget.imageUrl!,
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
                  widget.owner,
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
    );
  }
}

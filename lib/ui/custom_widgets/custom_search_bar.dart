import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

Widget Searchbar(TextEditingController controller, String placeHolderText,PaletteGenerator pl) {
  // Use constant light grey for background and slightly darker for border
  Color bgColor = Colors.grey[300]!.withOpacity(0.3); // Light grey with transparency
  Color borderColor = Colors.grey[400]!.withOpacity(0.5); // Slightly darker border

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: borderColor,
        width: 1,
      ),
    ),
    child: Row(
      children: [
        // Search Icon
        const Icon(
          Icons.search,
          color: Colors.white,
          size: 18,
        ),
        const SizedBox(width: 8),

        // TextField for search input
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.white, // Text color
              fontSize: 16,
            ),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: placeHolderText,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.6), // Slightly transparent placeholder
                fontSize: 16,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    ),
  );
}

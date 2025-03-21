import 'package:flutter/material.dart';
import 'package:spotify_ui/domain/app_colors.dart';

Widget mSpacer({
  double mWidth = 11,
  double mHeight = 11,
}) => SizedBox(
  height: mHeight,
  width: mHeight,
);

InputDecoration getAccountField() => InputDecoration(
  filled: true,
  fillColor: AppColors.greyColor,
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12)
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: AppColors.primaryColor,
      width: 1,
    )
  ),
);

InputDecoration getTextDecoration({
  IconData mIcon = Icons.search,
  String mText = "Search",
}) => InputDecoration(
  filled: true,
  fillColor: Colors.white,
  contentPadding: EdgeInsets.zero,
  prefixIcon: Icon(mIcon),
  hintText: mText,
  hintStyle: TextStyle(color: AppColors.greyColor),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12)
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(
      color: AppColors.primaryColor,
      width: 1,
    )
  ),
);
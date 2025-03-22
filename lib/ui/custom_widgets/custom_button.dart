import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/app_colors.dart';

// ignore: must_be_immutable
class CustomButton extends StatelessWidget {
  VoidCallback? onTap; // Allow null for disabled state
  double mWidth;
  double mHeight;
  Color bgColor;
  String text;
  Color textColor;
  String? mIconPath;
  String? rightIconPath; // New: Optional right-side icon
  bool isOutlined;
  bool isSelected;
  bool isDisabled; // New: Disable button if true
  double borderWidth; // New: Border width customization
  Gradient? gradient; // New: Optional gradient background

  CustomButton({
    super.key,
    required this.onTap,
    required this.text,
    this.textColor = Colors.black,
    this.mIconPath,
    this.rightIconPath,
    this.mWidth = 300,
    this.mHeight = 50,
    this.bgColor = Colors.white,
    this.isOutlined = false,
    this.isSelected = false,
    this.isDisabled = false,
    this.borderWidth = 1, // Default border width
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap, // Disable if isDisabled is true
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0, // Reduce opacity when disabled
        child: Container(
          width: mWidth,
          height: mHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: gradient, // Apply gradient if provided
            color: gradient == null
                ? (isSelected ? AppColors.primaryColor : (isOutlined ? Colors.transparent : bgColor))
                : null,
            border: isOutlined
                ? Border.all(
                    width: borderWidth, // Dynamic border width
                    color: isSelected ? AppColors.primaryColor : Colors.white,
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left icon if available
              if (mIconPath != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SvgPicture.asset(
                    mIconPath!,
                    width: 20,
                    height: 25,
                  ),
                ),
              // Text in center
              Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Right icon if available
              if (rightIconPath != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SvgPicture.asset(
                    rightIconPath!,
                    width: 20,
                    height: 25,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

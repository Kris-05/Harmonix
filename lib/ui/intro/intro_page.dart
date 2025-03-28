import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/ui/custom_widgets/custom_button.dart';
import 'package:spotify_ui/cameraCapture.dart';

class IntroPage extends StatefulWidget {
  final VideoService videoService;
  const IntroPage({super.key, required this.videoService});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            Image.asset("assets/images/bg.png", fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.blackColor.withOpacity(0.3),
                    AppColors.blackColor,
                  ],
                ),
              ),
            ),
            bottomLogin(context),
          ],
        ),
      ),
    );
  }

  Widget bottomLogin(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/logo/Logo.svg", width: 50, height: 50),
            mSpacer(),
            const Text(
              "Millions of Songs \n Free on Spotify",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 25,
              ),
              textAlign: TextAlign.center,
            ),
            mSpacer(),
            CustomButton(
              text: "Sign Up Free",
              bgColor: AppColors.primaryColor,
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.createAccountPage);
              },
            ),
            mSpacer(),
            CustomButton(
              isOutlined: true,
              mIconPath: "assets/logo/google.svg",
              text: "Continue with Google",
              textColor: Colors.white,
              bgColor: AppColors.primaryColor,
              onTap: () {},
            ),
            mSpacer(),
            CustomButton(
              isOutlined: true,
              mIconPath: "assets/logo/facebook.svg",
              text: "Continue with Facebook",
              textColor: Colors.white,
              bgColor: AppColors.primaryColor,
              onTap: () {},
            ),
            mSpacer(),
            //  Trigger Camera with Apple Button
            CustomButton(
              isOutlined: true,
              mIconPath: "assets/logo/apple.svg",
              text: isRecording ? "Stop Recording" : "Continue with Apple",
              textColor: Colors.white,
              bgColor: AppColors.primaryColor,
              onTap: () async {
                          if (isRecording) {
                            await widget.videoService.stopSendingFrames();
                            setState(() {
                              isRecording = false;
                            });
                          } else {
                            await widget.videoService.startSendingFrames();
                            setState(() {
                              isRecording = true;
                            });
                          }
                        },
            ),
            mSpacer(),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.loginPage);
              },
              child: const Text(
                "Login",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/ui/custom_widgets/custom_button.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: SizedBox(
        height: double.infinity,
        child: Stack(
          children: [
            Image.asset("assets/images/bg.png"),
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
                  ]
                )
              ),
            ),
            bottomLogin(context),
          ],
        ),
      )
    );
  }

  Widget bottomLogin(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.only(bottom: 60),
    child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center, 
        children: [
      
          SvgPicture.asset("assets/logo/Logo.svg", width: 50, height: 50),
          mSpacer(),
          Text("Millions of Songs \n Free on Spotify", style: TextStyle(
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
            onTap: (){
              Navigator.pushNamed(context, AppRoutes.createAccountPage);
            }
          ),
          mSpacer(),
          CustomButton(
            isOutlined: true,
            mIconPath: "assets/logo/google.svg",
            text: "Continue with Google",
            textColor: Colors.white,
            bgColor: AppColors.primaryColor,
            onTap: (){}
          ),
          mSpacer(),
          CustomButton(
            isOutlined: true,
            mIconPath: "assets/logo/facebook.svg",
            text: "Continue with Facebook",
            textColor: Colors.white,
            bgColor: AppColors.primaryColor,
            onTap: (){}
          ),
          mSpacer(),
          CustomButton(
            isOutlined: true,
            mIconPath: "assets/logo/apple.svg",
            text: "Continue with Apple",
            textColor: Colors.white,
            bgColor: AppColors.primaryColor,
            onTap: (){}
          ),
          mSpacer(),
          TextButton(
            onPressed: (){
              Navigator.pushNamed(context, AppRoutes.homePage);
            }, 
            child: Text("Login", style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          )))
        ],
      ),
  );
}
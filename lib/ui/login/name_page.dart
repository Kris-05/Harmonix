import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/ui/custom_widgets/custom_button.dart';

class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {

  bool isOneSelected  = false;
  bool isTwoSelected  = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        backgroundColor: AppColors.blackColor,
        centerTitle: true,
        title: Text("Create Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: SvgPicture.asset("assets/svg/Left.svg",  color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            nameUI(),
            mSpacer(mHeight: 25),
            CustomButton(
              onTap: (){
                
              }, 
              text: "Create Account",
              bgColor: AppColors.whiteColor,
              mWidth: 200,
            )
          ],
        ),
      ),
    );
  }

  Widget nameUI() => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(" What's your name", style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 25,
        )),
        mSpacer(mHeight: 4, mWidth: 8),
        TextField(
          style: TextStyle(color: Colors.white),
          cursorColor: Colors.white,
          decoration: getAccountField(),
        ),
        mSpacer(mHeight: 4, mWidth: 8),
        Text(" This will appear on your profile", style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        )),
        mSpacer(),
        Divider(color: AppColors.greyColor, height: 1,),
        mSpacer(mHeight: 21),
        Text("By tapping on “Create account”, you agree to the Harmonix Terms of Use.", style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        )),
        mSpacer(mHeight: 21),
        Text("Terms of Use.", style: TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        )),
        mSpacer(mHeight: 21),
        Text("To learn more about how Harmonix collect, uses, shares and protects your personal data, Please see the Harmonix Privacy Policy.", style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        )),
        mSpacer(mHeight: 21),
        Text("Privacy Policy", style: TextStyle(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        )),
        mSpacer(mHeight: 21),
        Material(
          color: Colors.transparent,
          child: CheckboxListTile(
            controlAffinity: ListTileControlAffinity.trailing,
            title: Text(
              "Please send me news and offers from Spotify.",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
            value: isOneSelected, 
            onChanged: (val) {
              setState(() {
                isOneSelected = val!;
              });
            },
            activeColor: AppColors.primaryColor,
          ),
        ),
        Material(
          color: Colors.transparent,
          child: CheckboxListTile(
            controlAffinity: ListTileControlAffinity.trailing,
            title: Text(
              "Share my registration data with Harmonix's content providers for marketing purposes.",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
            value: isTwoSelected,
            onChanged: (val) {
              setState(() {
                isTwoSelected = val!;
              });
            },
            activeColor: AppColors.primaryColor,
          ),
        ),
      ],
    ),
  );
}
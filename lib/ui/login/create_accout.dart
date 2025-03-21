import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
// import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/ui/custom_widgets/custom_button.dart';

class CreateAccout extends StatefulWidget {
  const CreateAccout({super.key});

  @override
  State<CreateAccout> createState() => _CreateAccoutState();
}

class _CreateAccoutState extends State<CreateAccout> {

  List<Widget> allPages = [];
  bool isOneSelected  = false;
  bool isTwoSelected  = false;
  int selectedIndex = 0;
  int? selectedGender;

  @override
  void initState() {
    super.initState();
    allPages = [
      wholeUI(
        title: " What's your email", 
        desc: " You'll need to confirm this email later"
      ),
      wholeUI(
        title: " Create a password", 
        desc: " Use atleast 8 characters"
      ),
      genderUI(),
    ];
  }

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
            if(selectedIndex > 0){
              setState(() {
                selectedIndex--;
              });
            } else {
              Navigator.pop(context);
            }
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
            allPages[selectedIndex],
            // genderUI(),
            mSpacer(mHeight: 25),
            CustomButton(
              onTap: (){
                if(selectedIndex < 2){
                  setState(() {
                    selectedIndex++;  
                  });
                } else {
                  Navigator.pushNamed(context, AppRoutes.namePage);
                }
              }, 
              text: "Next",
              bgColor: AppColors.whiteColor,
              mWidth: 100 ,
            )
          ],
        ),
      ),
    );
  }

  Widget wholeUI({required String title, required String desc}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: TextStyle(
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
      Text(desc, style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 10,
      )),
    ],
  );

  Widget genderUI() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(" What's your gender", style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 25,
      )),
      mSpacer(),
      Wrap(
        runAlignment: WrapAlignment.spaceBetween,
        runSpacing: 15,
        spacing: 28,
        children: [
          _buildGenderButton(1, "Male"),
          _buildGenderButton(2, "Female"),
          _buildGenderButton(3, "Others"),
          _buildGenderButton(4, "Not prefer to say"),
      ],
      ),
    ],
  );

  Widget _buildGenderButton(int value, String text) {
    return CustomButton(
      mWidth: value == 4 ? 150 : 100, 
      mHeight: 36, 
      onTap: () {
        setState(() {
          selectedGender = value;
        });
      }, 
      text: text, 
      textColor: Colors.white,
      bgColor: AppColors.primaryColor,
      isOutlined: true,
      isSelected: selectedGender == value,
    );
  }
}

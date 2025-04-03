

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/ui/custom_widgets/custom_button.dart';
import 'package:spotify_ui/api/auth.dart';


class NamePage extends StatefulWidget {
  const NamePage({super.key});

  @override
  State<NamePage> createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {


  // Variables to store arguments from the Gender
  // We can call Backend from thiss PAge...
  // late=> not Null but Later Check..
  late String email;
  late String password;
  late String gender;
  late List<String> languages;

  TextEditingController name=TextEditingController();
  // Checkbox selection
  bool isOneSelected = false;
  bool isTwoSelected = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get arguments passed from the previous page
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Assign arguments to variables safely with fallback values
    email = args?['email'] ?? 'N/A';
    password = args?['password'] ?? 'N/A';
    gender = args?['gender'] ?? 'N/A';
    languages=args?['languages'] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        backgroundColor: AppColors.blackColor,
        centerTitle: true,
        title: const Text(
          "Create Account",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: SvgPicture.asset("assets/svg/Left.svg", color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Wrap nameUI in Expanded to avoid overflow
            Expanded(child: nameUI()),
            mSpacer(mHeight: 25),
            // Button to Create Account
            CustomButton(
              onTap: () async {

                // Summa Priting...
                print("Email: $email");
                print("Password: $password");
                print("Gender: $gender");
                print("Send News: $isOneSelected");
                print("Share Data: $isTwoSelected");

                if(isOneSelected && isTwoSelected){
                  // Calling the Create Account function.. 
                  try{
                    Navigator.pushNamed(context, AppRoutes.artistPage,arguments: {
                      'email': email,
                      'password': password,
                      'gender': gender,
                      'languages': languages,
                      'name':name.text
                    }, );

                    print("REdirect to the Artist Pagee..");
                    
                    // final res=await Auth.createAccountApi(email:email, password:password, gender:gender, name:name.text,languages:languages);
                    // print(res);
                  }
                  catch(err){
                    print(err);
                  }
                }
                // Navigate or perform actions after account creation

              },
              text: "Create Account",
              bgColor: AppColors.whiteColor,
              mWidth: 200,
            ),
          ],
        ),
      ),
    );
  }

  // Name Input UI
  Widget nameUI() => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What's your name",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 25,
              ),
            ),
            mSpacer(mHeight: 4, mWidth: 8),
            // Name Input Field
            TextField(
              controller: name,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: getAccountField(),
            ),
            mSpacer(mHeight: 4, mWidth: 8),
            const Text(
              "This will appear on your profile",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
            mSpacer(),
            const Divider(color: AppColors.greyColor, height: 1),
            mSpacer(mHeight: 21),
            const Text(
              "By tapping on “Create account”, you agree to the Harmonix Terms of Use.",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            mSpacer(mHeight: 21),
            const Text(
              "Terms of Use.",
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            mSpacer(mHeight: 21),
            const Text(
              "To learn more about how Harmonix collects, uses, shares and protects your personal data, please see the Harmonix Privacy Policy.",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
            mSpacer(mHeight: 21),
            const Text(
              "Privacy Policy",
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            mSpacer(mHeight: 21),
            // Checkbox for News and Offers
            Material(
              color: Colors.transparent,
              child: CheckboxListTile(
                controlAffinity: ListTileControlAffinity.trailing,
                title: const Text(
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
            // Checkbox for Sharing Registration Data
            Material(
              color: Colors.transparent,
              child: CheckboxListTile(
                controlAffinity: ListTileControlAffinity.trailing,
                title: const Text(
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

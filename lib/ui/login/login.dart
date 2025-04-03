import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/api/auth.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/ui/custom_widgets/custom_button.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {


  // Controllers for text fields
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  // Error handling for email and password
  String? emailError;
  String? passwordError;

  // this is For Login Page..
  // Consisit of Email Page and PassWord Page..

  // This Is for the Index Mapping...
  int selectedIndex=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        title: const Text("Login",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: AppColors.blackColor,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            // Go to the previous page if possible
            if (selectedIndex > 0) {
              setState(() {
                selectedIndex--;
              });
            } else {
              Navigator.pop(context);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: SvgPicture.asset(
              "assets/svg/Left.svg",
              color: Colors.white,
            ),
          ),
        )
      ),
      body: Padding(padding:  const EdgeInsets.all(14),  //Body Of the login Page...
      child: Column(
        children: [
          // Get the current page dynamically
            getPage(),
            mSpacer(mHeight: 25),

            // Next button to navigate through pages
            CustomButton(
              onTap: () async {
                // Validate email on the first page
                if (selectedIndex == 0) {
                  if (!_isValidEmail(emailController.text)) {
                    setState(() {
                      emailError = "Please enter a valid email";
                    });
                    return;
                  } 
                  }else {

                    if(passController.text.length<8){
                      setState(() {
                        passwordError="It Must Be Atleast 8 Chars";
                        return;
                      });
                    }


                    print("Pressed Submit ,, Gonna Call Api");
                    try{
                    final res=await Auth.loginApi(email:emailController.text, password:passController.text );
                    print("Login Successs");
                    Navigator.pushNamed(context, AppRoutes.homePage);
                  }
                  catch(err){
                    setState(() {
                      passwordError="Error in Logging In";
                    });
                  }


                 }
                

                // Validate password on the second page
                if (selectedIndex == 1) {
                  if (!_isValidPassword(passController.text)) {
                    setState(() {
                      passwordError = "UR Password is at least 8 characters";
                    });
                    return;
                  } 
                }
              

                // Move to the next page if validation passes
                if (selectedIndex < 2) {
                  setState(() {
                    selectedIndex++;
                  });
                } 
              },
              text: "Next",
              bgColor: AppColors.whiteColor,
              mWidth: 100,
            )
          ],
        ),
      ),
    );
  }

  // Returns the correct page based on selectedIndex
  Widget getPage(){
    if (selectedIndex == 0) {
      return wholeUI(
        title: "Enter your email",
        desc: "You'll need to confirm this email later",
        controller: emailController,
        isPass: false,
        err: emailError,
      );
    } else  {
      return wholeUI(
        title: "Enter password",
        desc: "Use Your PassWord",
        controller: passController,
        isPass: true,
        err: passwordError,
      );
    } 
  }

  // UI for Email and Password fields with error handling
  Widget wholeUI({
    required String title,
    required String desc,
    required TextEditingController controller,
    required bool isPass,
    String? err,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 25,
            ),
          ),
          mSpacer(mHeight: 4, mWidth: 8),

          // TextField with border changes based on error
          TextField(
            controller: controller,
            obscureText: isPass,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: getAccountField(
              hasError: err != null, // Red border if error
            ),
          ),
          mSpacer(mHeight: 4, mWidth: 8),

          // Error message display if any
          if (err != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                err,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),

          mSpacer(mHeight: 4, mWidth: 8),
    
    
          
          Text(
            desc,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      );

}


// Validate email format using regex
bool _isValidEmail(String email) {
  final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-z]{2,}$');
  return regex.hasMatch(email);
}

// Validate password (at least 8 characters)
bool _isValidPassword(String password) {
  return password.length >= 8;
}


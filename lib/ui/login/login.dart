import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_ui/api/auth.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/ui_helper.dart';

import 'package:spotify_ui/providers/user_provider.dart';
import 'package:spotify_ui/ui/custom_widgets/custom_button.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

  @override
  ConsumerState<Login> createState() => _LoginState();
}

class _LoginState extends ConsumerState<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  String? emailError;
  String? passwordError;

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      appBar: AppBar(
        title: const Text(
          "Login",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.blackColor,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
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
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            getPage(),
            mSpacer(mHeight: 25),
            CustomButton(
              onTap: handleNext,
              text: selectedIndex == 1 ? "Login" : "Next",
              bgColor: AppColors.whiteColor,
              mWidth: 100,
            ),
          ],
        ),
      ),
    );
  }

  void handleNext() async {
    setState(() {
      emailError = null;
      passwordError = null;
    });

    if (selectedIndex == 0) {
      if (!_isValidEmail(emailController.text)) {
        setState(() {
          emailError = "Please enter a valid email";
        });
        return;
      } else {
        setState(() {
          selectedIndex++;
        });
      }
    } else if (selectedIndex == 1) {
      if (!_isValidPassword(passController.text)) {
        setState(() {
          passwordError = "Password must be at least 8 characters";
        });
        return;
      }

      try {
        final res = await Auth.loginApi(
          email: emailController.text,
          password: passController.text,
        );
        final user=res['user'];
        ref.read(loginProvider.notifier).login(user['name'], user['email']);
        print(user);
       if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.homePage,
            (route) => false,
          );
        }
        } catch (err) {
          print(err);
        setState(() {
          passwordError = "Login failed. Please try again.";
        });
      }
    }
  }

  Widget getPage() {
    if (selectedIndex == 0) {
      return wholeUI(
        title: "Enter your email",
        desc: "You'll need to confirm this email later",
        controller: emailController,
        isPass: false,
        err: emailError,
      );
    } else {
      return wholeUI(
        title: "Enter password",
        desc: "Use your password",
        controller: passController,
        isPass: true,
        err: passwordError,
      );
    }
  }

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
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 25,
            ),
          ),
          mSpacer(mHeight: 4, mWidth: 8),
          TextField(
            controller: controller,
            obscureText: isPass,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: getAccountField(hasError: err != null),
          ),
          mSpacer(mHeight: 4, mWidth: 8),
          if (err != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                err,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          mSpacer(mHeight: 8, mWidth: 8),
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

// Validator functions
bool _isValidEmail(String email) {
  final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-z]{2,}$');
  return regex.hasMatch(email);
}

bool _isValidPassword(String password) {
  return password.length >= 8;
}

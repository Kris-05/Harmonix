import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:spotify_ui/domain/ui_helper.dart';
import 'package:spotify_ui/ui/custom_widgets/custom_button.dart';

// Yov Krisnaa Olungaa Comment pannu daaa
// Oru Mairum Purila....

class CreateAccout extends StatefulWidget {
  const CreateAccout({super.key});

  @override
  State<CreateAccout> createState() => _CreateAccoutState();
}

class _CreateAccoutState extends State<CreateAccout> {
  // Track the current page (email, password, gender + language combined)
  int selectedIndex = 0;

  // Selected gender and languages
  int? selectedGender;
  List<int> selectedLanguages = [];

  // Controllers for text fields
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  // Error handling for email and password
  String? emailError;
  String? passwordError;

  @override
  Widget build(BuildContext context) {
    return SafeArea(child:Scaffold(
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
        ),
      ),
      body:  SingleChildScrollView(child:  Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Get the current page dynamically
            getPage(),
            mSpacer(mHeight: 25),

            // Next button to navigate through pages
            CustomButton(
              onTap: () {
                // Validate email on the first page
                if (selectedIndex == 0) {
                  if (!_isValidEmail(emailController.text)) {
                    setState(() {
                      emailError = "Please enter a valid email";
                    });
                    return;
                  } else {
                    setState(() {
                      emailError = null; // Clear error if valid
                    });
                  }
                }

                // Validate password on the second page
                if (selectedIndex == 1) {
                  if (!_isValidPassword(passController.text)) {
                    setState(() {
                      passwordError = "Password must be at least 8 characters";
                    });
                    return;
                  } else {
                    setState(() {
                      passwordError = null; // Clear error if valid
                    });
                  }
                }

                // Move to the next page if validation passes
                if (selectedIndex < 2) {
                  setState(() {
                    selectedIndex++;
                  });
                } else {
                  // Collect final data and proceed to the next page
                  String email = emailController.text;
                  String password = passController.text;
                  String gender = getGenderText(selectedGender);
                  List<String> languages = getSelectedLanguages(selectedLanguages);

                  // Debug print to verify data
                  print("Final Email: $email");
                  print("Final Password: $password");
                  print("Selected Gender: $gender");
                  print("Selected Languages: $languages");

                  // Navigate to the Name Page with collected data
                  Navigator.pushNamed(
                    context,
                    AppRoutes.namePage,
                    arguments: {
                      'email': email,
                      'password': password,
                      'gender': gender,
                      'languages': languages,
                    },
                  );
                }
              },
              text: selectedIndex == 2 ? "Create Account" : "Next",
              bgColor: AppColors.whiteColor,
              mWidth: selectedIndex == 2 ? 200 : 100,
            )
          ],
        ),
      ),
      
    ),
    )
    );
  }

  // Returns the correct page based on selectedIndex
  Widget getPage() {
    if (selectedIndex == 0) {
      return wholeUI(
        title: "What's your email?",
        desc: "You'll need to confirm this email later",
        controller: emailController,
        isPass: false,
        err: emailError,
      );
    } else if (selectedIndex == 1) {
      return wholeUI(
        title: "Create a password",
        desc: "Use at least 8 characters",
        controller: passController,
        isPass: true,
        err: passwordError,
      );
    } else {
      // Combined Gender + Language UI
      return combinedGenderAndLanguageUI();
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

          // Description below the field
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

  // Combined UI for Gender and Language Selection
  Widget combinedGenderAndLanguageUI() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's your gender?",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 25,
            ),
          ),
          mSpacer(),
          Wrap(
            runSpacing: 15,
            spacing: 20,
            children: [
              _buildGenderButton(1, "Male"),
              _buildGenderButton(2, "Female"),
              _buildGenderButton(3, "Other"),
              _buildGenderButton(4, "Rather Not Say"),
            ],
          ),
          mSpacer(mHeight: 20),

          const Text(
            "Select preferred languages",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 25,
            ),
          ),
          mSpacer(),
          Wrap(
            alignment: WrapAlignment.start, // Align items to the start to avoid overflow
            runSpacing: 10,
            spacing: 12, 
            children: [
              _buildLanguageButton(1, "Tamil"),
              _buildLanguageButton(2, "English"),
              _buildLanguageButton(3, "Malayalam"),
              _buildLanguageButton(4, "Telugu"),
            ],
          ),
        ],
      );

  // Create buttons for gender selection
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

  // Create buttons for multiple language selection
  Widget _buildLanguageButton(int value, String text) {
    return CustomButton(
      mWidth: 100,
      mHeight: 36,
      onTap: () {
        setState(() {
          if (selectedLanguages.contains(value)) {
            selectedLanguages.remove(value);
          } else {
            selectedLanguages.add(value);
          }
        });
      },
      text: text,
      textColor: Colors.white,
      bgColor: AppColors.primaryColor,
      isOutlined: true,
      isSelected: selectedLanguages.contains(value),
    );
  }
}

// Get gender as text based on selected value
String getGenderText(int? value) {
  switch (value) {
    case 1:
      return "Male";
    case 2:
      return "Female";
    case 3:
      return "Others";
    case 4:
      return "Rather Not Say";
    default:
      return "Not selected";
  }
}

// Get selected languages as a list of text
List<String> getSelectedLanguages(List<int> selectedLanguages) {
  Map<int, String> languageMap = {
    1: "Tamil",
    2: "English",
    3: "Malayalam",
    4: "Telugu",
  };

  return selectedLanguages.map((e) => languageMap[e] ?? "").toList();
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

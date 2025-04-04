import 'package:flutter/material.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:spotify_ui/domain/ui_helper.dart';

class SettingNavPage extends StatelessWidget {
  List<String> mSettingList = [
    "Account",
    "Data Saver",
    "Languages",
    "Playback",
    "Explicit Content",
    "Devices",
    "Car",
    "Social",
    "Voice Assistant & Apps",
    "Audio Quality",
    "Storage"
    ];
  // const SettingNavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blackColor,
      body: Column(
        children: [
          mSpacer(mHeight: 70),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  child: Icon(
                    Icons.arrow_back_ios_new_sharp,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InkWell(
                  child: Icon(
                    Icons.arrow_back_ios_new_sharp,
                    color: Colors.black,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          mSpacer(),
          ListTile(
            leading: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage("assets/images/Members.png"),
                ),
              ),
            ),
            contentPadding: EdgeInsets.zero,
            title: Text(
              "maya",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "View profile",
              style: TextStyle(color: Colors.white70),
            ),
            trailing: Icon(
              Icons.chevron_right_sharp,
              color: Colors.grey,
              size: 30,
            ),
          ),
         
          Expanded(
            child: ListView.builder(
              
              itemCount: mSettingList.length,
              itemBuilder: (_, index) {
                return ListTile(
                  // contentPadding: EdgeInsets.zero,
                  title: Text(
                    mSettingList[index],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  trailing: Icon(
                    Icons.chevron_right_sharp,
                    color: Colors.grey,
                    size: 30,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:spotify_ui/cameraCapture.dart';
import 'package:spotify_ui/domain/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spotify_ui/domain/app_routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';

// Yov Krishnaa Olungaa Comment pannu daaa 
// Oru Mairum Purila.... 

// OK da SeeOneLight

void main() async {
  await dotenv.load(fileName: "lib/.env");
  WidgetsFlutterBinding.ensureInitialized();

  VideoService videoService = VideoService();
  // await videoService.initializeCamera();
  
  
  // Initialize before running app
  //  videoService.connectSocket(); // Connect socket
  // await videoService.startSendingFrames(); // Start sending frames
  // final container = ProviderContainer();
  // _listenToGestureStream(videoService, container);

  

  runApp(ProviderScope(child:MyApp(videoService: videoService)));
}



class MyApp extends StatelessWidget {
  final VideoService videoService;
      
// Pass videoService here
  const MyApp({super.key, required this.videoService});
  

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Harmonix',
      debugShowCheckedModeBanner: false, // to remove debug banner
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.blackColor,
          selectedItemColor: Colors.green, // Active tab color
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), // Active text style
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      // Pass videoService to routes
      routes: AppRoutes.getRoutes(videoService),
      onGenerateRoute: AppRoutes.onGenerateRoute, 
      initialRoute: AppRoutes.splashPage,
    );
  }
}

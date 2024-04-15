import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/features/user_auth/presentation/admin/admin_page.dart';
import 'package:healthapp/features/user_auth/presentation/pages/screens/booking_page.dart';
import 'package:healthapp/features/user_auth/presentation/pages/screens/home_page.dart';
import 'package:healthapp/features/user_auth/presentation/pages/screens/login_page.dart';
import 'package:healthapp/features/user_auth/presentation/pages/screens/signup_page.dart';
import 'package:healthapp/features/user_auth/presentation/pages/utils/config.dart';
import 'package:healthapp/main_layout.dart';

import 'features/app/splash_screen/splash_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthMate',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          focusColor: Config.primaryColor,
          border: Config.outlinedBorder,
          focusedBorder: Config.focusBorder,
          errorBorder: Config.errorBorder,
          enabledBorder: Config.outlinedBorder,
          floatingLabelStyle: TextStyle(color: Config.primaryColor),
          prefixIconColor: Colors.black38,
        ),
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Config.primaryColor,
          selectedItemColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          unselectedItemColor: Colors.grey.shade700,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/login': (context) => LoginPage(),
        'main':(context) => const MainLayout(),
        '/admin': (context) => AdminPage(),
        '/home': (context) => HomePage(),
        'booking_page': (context) => BookingPage(),
        '/signup': (context) => SignUpPage(),
        '/': (context) => SplashScreen(
            child: LoginPage(),
        ),
      },
    );
  }
}
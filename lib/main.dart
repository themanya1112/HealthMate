import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:healthapp/features/user_auth/presentation/admin/admin_page.dart';
import 'package:healthapp/features/user_auth/presentation/pages/screens/booking_page.dart';
import 'package:healthapp/features/user_auth/presentation/pages/screens/home_page.dart';
import 'package:healthapp/features/user_auth/presentation/pages/screens/login_page.dart';
import 'package:healthapp/features/user_auth/presentation/pages/screens/delete.dart';
import 'package:healthapp/features/user_auth/presentation/pages/screens/qr_gen.dart';
import 'package:healthapp/features/user_auth/presentation/pages/screens/signup_page.dart';
import 'package:healthapp/features/user_auth/presentation/pages/screens/appointment_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      navigatorKey: navigatorKey, // Assigning the navigatorKey to the MaterialApp
      theme: ThemeData(
        //pre-define input decoration
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
      initialRoute: '/', // Initial route is SignUpPage
      routes: {
        '/login': (context) => LoginPage(),
        'main':(context) => const MainLayout(),
        '/admin': (context) => AdminPage(),
        '/home': (context) => HomePage(),
        '/delete': (context) => DeleteAccount(),
        // '/booking_page': (context) => BookingPage(user: ModalRoute.of(context)!.settings.arguments as User),
        // '/booking_page': (context) {
        //   final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        //   // final user= ModalRoute.of(context)!.settings.arguments as User;
        //   final doctorId = args['doctor_id'];
        //   final user =args['user'];
        //   print("User: $user");
        //   print("Doctor ID: $doctorId");
        //   // final doctorId = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        //   return BookingPage(user: user, doctorId: doctorId );
        // },
        'booking_page': (context) => BookingPage(),
        '/signup': (context) => SignUpPage(), // Default route is SignUpPage
        '/': (context) => SplashScreen(
          // Here, you can decide whether to show the LoginPage or HomePage based on user authentication
            child: LoginPage(),
        ),
      },
      // onGenerateRoute: (settings) {
      //   // If the route is a booking page route...
      //   if (settings.name!.startsWith('/booking_page')) {
      //     final args = settings.arguments as Map<String, dynamic>;
      //     final user = args['user'];
      //     final doctorId = args['doctor_id'];
      //     // Return the BookingPage for this doctor.
      //     return MaterialPageRoute(
      //       builder: (context) {
      //         return BookingPage(user: user, doctorId: doctorId);
      //       },
      //     );
      //   }
      //   // Handle other routes...
      //   return null;
      // },
    );
  }
}
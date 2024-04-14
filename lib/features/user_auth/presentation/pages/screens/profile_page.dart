import "package:healthapp/main.dart";
import "package:healthapp/features/user_auth/presentation/pages/utils/config.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:firebase_auth/firebase_auth.dart';
// import "../providers/dio_provider.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:healthapp/features/user_auth/presentation/pages/screens/appointment_page.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String username;

  @override
  void initState() {
    super.initState();
    // Call a method to fetch the username when the widget initializes
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    // Get the current user from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get the user's document from Firestore
      DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      // Extract the username from the user's document
      setState(() {
        username = userData['username'] ??
            'idk'; // Replace 'username' with the actual field name in your Firestore document
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Config.primaryColor,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 110,
                  ),
                  CircleAvatar(
                    radius: 65.0,
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'manya',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    '23 Years Old | Female',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.grey[200],
              child: Center(
                child: Card(
                  margin: const EdgeInsets.fromLTRB(0, 45, 0, 0),
                  child: Container(
                    width: 300,
                    height: 250,
                    child: SingleChildScrollView( // Wrap the Column with SingleChildScrollView
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            const Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Divider(
                              color: Colors.grey[300],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.person,
                                  color: Colors.blueAccent[400],
                                  size: 35,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: const Text(
                                    "Profile",
                                    style: TextStyle(
                                      color: Config.primaryColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Config.spaceSmall,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.history,
                                  color: Colors.yellowAccent[400],
                                  size: 35,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => AppointmentPage()),
                                    );
                                  },
                                  child: const Text(
                                    "History",
                                    style: TextStyle(
                                      color: Config.primaryColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Config.spaceSmall,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.logout_outlined,
                                  color: Colors.lightGreen[400],
                                  size: 35,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      // Sign out the user from Firebase Authentication
                                      await FirebaseAuth.instance.signOut();

                                      // Redirect to the login page or any other page as needed
                                      Navigator.of(context).pushReplacementNamed(
                                          '/login'); // Replace '/login' with your actual login page route
                                    } catch (e) {
                                      // Handle sign out errors
                                      print('Sign out error: $e');
                                    }
                                  },
                                  child: const Text(
                                    "Logout",
                                    style: TextStyle(
                                      color: Config.primaryColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              ),
            ),
          ],
        ),
      ),
    );
  }
}
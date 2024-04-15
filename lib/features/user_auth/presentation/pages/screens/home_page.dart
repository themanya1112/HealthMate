import 'package:flutter/material.dart';
import 'package:healthapp/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthapp/features/user_auth/presentation/pages/components/appointment_card.dart';
import 'package:healthapp/features/user_auth/presentation/pages/components/doctor_card.dart';
import 'package:healthapp/features/user_auth/presentation/pages/utils/config.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

enum FilterStatus { upcoming, complete, cancel }

class _HomePageState extends State<HomePage> {
  final FirebaseAuthServices _authServices = FirebaseAuthServices();

  Map<String, dynamic> user = {};
  Map<String, dynamic> doctor = {};
  List<dynamic> favList = [];
  List<Map<String, dynamic>> medCat = [
    {
      "icon": FontAwesomeIcons.userDoctor,
      "category": "General",
    },
    {
      "icon": FontAwesomeIcons.heartPulse,
      "category": "Cardiology",
    },
    {
      "icon": FontAwesomeIcons.lungs,
      "category": "Respirations",
    },
    {
      "icon": FontAwesomeIcons.hand,
      "category": "Dermatology",
    },
    {
      "icon": FontAwesomeIcons.personPregnant,
      "category": "Gynecology",
    },
    {
      "icon": FontAwesomeIcons.teeth,
      "category": "Dental",
    },
  ];


  FilterStatus status = FilterStatus.upcoming;
  Alignment _alignment = Alignment.centerLeft;
  List<dynamic> schedules = [];
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> getAppointments() async {
    // Get current user
    final User? user = _auth.currentUser;
    if (user != null) {
      // Fetch appointments for the user from Firestore
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('userId', isEqualTo: user.uid)
          .get();

      DocumentSnapshot userDoc =
      await _firestore.collection('users').doc(user.uid).get();
      List<dynamic> appointments = userDoc['qrData'];

      List<Map<String, String>> parsedAppointments = appointments.map((appointment) {
        List<String> parts = appointment.split('-');
        return {
          'doctor_id': parts[3],
          'slot': parts[1],
          'date': parts[2],
          'status': _getStatus(parts[2]),

        };
      }).toList();

      setState(() {
        schedules = parsedAppointments;
      });
    }
  }

  String _getStatus(String appointmentDate) {
    DateTime now = DateTime.now();
    DateTime parsedAppointmentDate = DateFormat('dd.MM.yyyy').parse(appointmentDate);
    if (now.isAfter(parsedAppointmentDate)) {
      return 'complete';
    } else {
      return 'upcoming';
    }
  }

  List<dynamic> getAppointmentsForToday(List<dynamic> doctor) {
    // Get today's date
    DateTime now = DateTime.now();
    String todayDate = DateFormat('dd.MM.yyyy').format(now);
    String currentTime = DateFormat('HHmm').format(now);

    List<dynamic> appointmentsForToday = doctor
      .where((appointment) {
      appointment['date'] == todayDate;
      appointment['slot'] == currentTime;

      if (appointment['date'] != todayDate) {
        return false;
      }

      if (appointment['slot'] != null &&
          appointment['slot'].compareTo(currentTime) >= 0) {
        return true; // Appointment time is after or equal to current time
      }
      return false;
    })
      .toList();

    return appointmentsForToday;
  }

  Future<List<dynamic>> getUserData(String userId) async {
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(userId).get();
    if (userSnapshot.exists) {
      Map<String,dynamic>? userData = userSnapshot.data() as Map<String,dynamic>?;

      if (userData != null && userData.containsKey('fav')) {
        userData['fav'] = json.decode(userData['fav']) as List<dynamic>;
      } else {
        userData?['fav'] = [];
      }
      return userData?['fav'];
    }
    return [];
  }

  void fetchData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      favList = await getUserData(user.uid.toString());
    }
  }


  @override
  Widget build(BuildContext context) {
    Config().init(context);

    List<dynamic> doctor = getAppointmentsForToday(schedules);
    final User? user1 = _auth.currentUser;

    return FutureBuilder<void>(
      future: _initializeData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                            Text(
                              user['username'] ?? 'Manya',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          const SizedBox(
                            child: CircleAvatar(
                              radius: 30,
                              backgroundImage:
                              AssetImage('assets/images/splash/profile3.jpeg'),
                            ),
                          )
                        ],
                      ),
                      Config.spaceMedium,
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Config.spaceSmall,
                      SizedBox(
                        height: Config.heightSize * 0.05,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children:
                          List<Widget>.generate(medCat.length, (index) {
                            return Card(
                              margin: const EdgeInsets.only(right: 20),
                              color: Config.primaryColor,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    FaIcon(
                                      medCat[index]['icon'],
                                      color: Colors.white,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      medCat[index]['category'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                      Config.spaceSmall,
                      const Text(
                        'Appointment Today',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Config.spaceSmall,
                      doctor.isNotEmpty
                          ? AppointmentCard(
                        doctor: doctor[0],
                        color: Config.primaryColor,
                      )
                          : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text(
                              'No Appointment Today',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Config.spaceSmall,
                      const Text(
                        'Top Doctors',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Config.spaceSmall,
                      SingleChildScrollView(
                        child:Column(
                          children:[
                            SizedBox(height: 10),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance.collection("doctors").snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                    return Text('No data available');
                                  } else {
                                    return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, index) {
                                        var doctorData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                                        String c=doctorData['id'].toString();
                                        return DoctorCard(

                                        doctor: doctorData,
                                          isFav : favList.contains(c)? true: false,
                                        );
                                      },
                                    );
                                  };
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _initializeData() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

      Map<String, dynamic> userData = {}; // Fetch user data from Firestore
      Map<String, dynamic> appointmentInfo = {}; // Fetch appointment data from Firestore

  }
}








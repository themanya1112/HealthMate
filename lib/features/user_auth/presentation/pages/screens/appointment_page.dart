import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:healthapp/features/user_auth/presentation/pages/utils/config.dart';

class AppointmentPage extends StatefulWidget {
  const AppointmentPage({Key? key}) : super(key: key);

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

enum FilterStatus { upcoming, complete, cancel }

class _AppointmentPageState extends State<AppointmentPage> {
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

  @override
  void initState() {
    getAppointments();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredSchedules = schedules.where((schedule) {
      return schedule['status'] == status.toString().split('.').last;
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Appointment Schedule',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (FilterStatus filterStatus in FilterStatus.values)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                status = filterStatus;
                                switch (filterStatus) {
                                  case FilterStatus.upcoming:
                                    _alignment = Alignment.centerLeft;
                                    break;
                                  case FilterStatus.complete:
                                    _alignment = Alignment.center;
                                    break;
                                  case FilterStatus.cancel:
                                    _alignment = Alignment.centerRight;
                                    break;
                                }
                              });
                            },
                            child: Center(
                              child: Text(filterStatus.toString().split('.').last),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedAlign(
                  alignment: _alignment,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Config.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        status.toString().split('.').last,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredSchedules.length,
                itemBuilder: (context, index) {
                  var schedule = filteredSchedules[index];
                  bool isLastElement = index == filteredSchedules.length - 1;
                  return Card(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    margin: isLastElement
                        ? EdgeInsets.zero
                        : const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(
                                  "assets/images/profile1.jpeg",
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    schedule['doctor_id'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    schedule['slot'],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          ScheduleCard(
                            date: schedule['date'],
                            time: schedule['slot'],
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    Key? key,
    required this.date,
    required this.time,
  }) : super(key: key);

  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Icon(Icons.calendar_today, color: Config.primaryColor, size: 15),
          const SizedBox(width: 5),
          Text(
            '$date',
            style: const TextStyle(color: Config.primaryColor),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.access_alarm, color: Config.primaryColor, size: 17),
          const SizedBox(width: 5),
          Flexible(child: Text(time, style: const TextStyle(color: Config.primaryColor))),
        ],
      ),
    );
  }
}

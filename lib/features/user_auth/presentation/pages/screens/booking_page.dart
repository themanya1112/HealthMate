import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:healthapp/features/user_auth/presentation/pages/models/booking_datetime_converted.dart';
import 'package:healthapp/features/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:healthapp/features/user_auth/presentation/pages/components/button.dart';
import 'package:healthapp/features/user_auth/presentation/pages/utils/config.dart';
import 'package:healthapp/features/user_auth/presentation/pages/components/custom_appbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:healthapp/features/user_auth/presentation/pages/screens/qr_gen.dart';


class BookingPage extends StatefulWidget {

  BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {

  CalendarFormat _format = CalendarFormat.month;
  DateTime _focusDay = DateTime.now();
  DateTime _currentDay = DateTime.now();
  int? _currentIndex;
  bool _isWeekend = false;
  bool _dateSelected = false;
  bool _timeSelected = false;
  final AppointmentManager _appointmentManager = AppointmentManager();


  @override
  Widget build(BuildContext context) {
    Config().init(context);
    final doctor= ModalRoute.of(context)!.settings.arguments as Map;
    return Scaffold(
      appBar: CustomAppBar(
        appTitle: 'Appointment',
        icon: const FaIcon(Icons.arrow_back_ios),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              children: <Widget>[
                _tableCalendar(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                  child: Center(
                    child: Text(
                      'Select Consultation Time',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          _isWeekend
              ? SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 30),
                alignment: Alignment.center,
                child: const Text(
                  'Weekend is not available, please select another date',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
              :SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('bookings')
                          .doc(DateFormat('d.M.y').format(_currentDay))
                          .get(),
                      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          return InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              setState(() {
                                _currentIndex = index;
                                _timeSelected = true;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: _currentIndex == index ? Colors.white : Colors.black,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                color: _currentIndex == index ? Config.primaryColor : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${index + 9}:00 ${index + 9 > 11 ? "PM" : "AM"}\n',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _currentIndex == index ? Colors.white : null,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    );
                  },
                  childCount: 8,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.0,
                ),
              ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 80),
              child: Button(
                width: double.infinity,
                title: 'Book Ticket',
                onPressed: () async {
                  final getTime = DateConverted.getTime(_currentIndex!);

                  final timeParts = getTime.split(":");
                  final hourString = timeParts[0];
                  final minuteString = timeParts[1].split(" ")[0];
                  final formattedTime = hourString.replaceAll(RegExp(r'[^0-9]'), '') + minuteString;
                  final getTimeInt = int.tryParse(formattedTime) ?? 0;

                  final user = FirebaseAuth.instance.currentUser;

                  if (user != null) {
                    final userId = user.uid;
                    final getDayFormatted = DateFormat('d.M.y').format(_currentDay);

                    await _appointmentManager.bookAppointment(getDayFormatted, getTimeInt, userId,doctor['doctor_id']);
                    bool isBookingSuccessful = await _appointmentManager
                        .bookAppointment(
                        getDayFormatted, getTimeInt, userId,doctor['doctor_id']);
                    if (isBookingSuccessful) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => QRView(
                            userId: user.uid,
                            date: getDayFormatted,
                            slot: getTimeInt.toString(),
                            doctor: doctor['doctor_id'].toString(),
                          ),
                        ),
                      );
                    }
                    else {
                      // Show a message on the screen indicating that no booking is available in this slot
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('No booking available in this slot.'),
                        ),
                      );
                    }
                  } else {
                    // Handle the case where the user is not logged in
                  }
                },
                disable: _timeSelected && _dateSelected ? false : true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Table calendar
  Widget _tableCalendar() {
    return TableCalendar(
      focusedDay: _focusDay,
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(Duration(days: 60)),
      calendarFormat: _format,
      currentDay: _currentDay,
      rowHeight: 48,
      calendarStyle: const CalendarStyle(
        todayDecoration: BoxDecoration(color: Config.primaryColor, shape: BoxShape.circle),
      ),
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      onFormatChanged: (format) {
        setState(() {
          _format = format;
        });
      },
      onDaySelected: ((selectedDay, focusedDay) {
        setState(() {
          _currentDay = selectedDay;
          _focusDay = focusedDay;
          _dateSelected = true;

          if (selectedDay.weekday == 6 || selectedDay.weekday == 7) {
            _isWeekend = true;
            _timeSelected = false;
            _currentIndex = null;
          } else {
            _isWeekend = false;
          }
        });
      }),
    );
  }
}

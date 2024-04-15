import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

class FirebaseAuthServices{

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUpWithEmailandPassword(String email, String password) async{
    try{
      UserCredential credential =await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    }on FirebaseAuthException catch  (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
    }
    return null;
  }

  Future<User?> signInWithEmailandPassword(String email, String password) async{
    try{
      UserCredential credential =await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    }on FirebaseAuthException catch  (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
    }
    return null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> updateUserFavList(List<dynamic> favList) async {
    User? user = getCurrentUser();
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'fav': (favList),
      });
    }
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

  Future<void> addDocToFav(String doctorId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get the current list of favorite doctors for the user
      DocumentSnapshot userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userSnapshot.exists) {
        Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;

        if (userData != null) {
          List<dynamic>? favList = userData['fav'];

          // Check if the favList is null or empty
          if (favList == null) {
            favList = [];
          }

          // Add the new doctorId to the favList if it's not already present
          if (!favList.contains(doctorId)) {
            favList.add(doctorId);

            // Update the 'fav' field in Firestore for the user
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .update({'fav': favList});
          }
        }
      }
    }
  }


}
// class AppointmentManager {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<bool> bookAppointment(String dateString, int selectedSlot,
//       String userId, int doctorId) async {
//     // Create a document reference with the selected date
//     DocumentReference bookingRef = _firestore.collection('bookings').doc('$dateString-$doctorId');
//
//     // Get the document snapshot for the selected date
//     DocumentSnapshot dateSnapshot = await bookingRef.get();
//
//     if (!dateSnapshot.exists) {
//       // Document does not exist, create a new document
//       Map<String, dynamic> initialSlots = {
//         'slot$selectedSlot': {
//           'numberOfTicketsBooked': 1,
//           'users': [userId],
//           // 'doctor': [doctorId],
//         }
//       };
//
//       // Set the document in Firestore
//       await bookingRef.set(initialSlots);
//       print('Appointment booked successfully!');
//       return true;
//     } else {
//       // Document exists, get the current slot data
//       Map<String, dynamic>? slotData = dateSnapshot.data() as Map<String, dynamic>?;
//
//       // Check if the slot is available
//       Map<String, dynamic>? selectedSlotData = slotData?['slot$selectedSlot'];
//
//       if (selectedSlotData != null) {
//         // Slot exists
//         int count = selectedSlotData['numberOfTicketsBooked'] ?? 0;
//         if (count < 100) {
//           // Slot is available, update slot data with user ID
//           List<dynamic> users = List.from(selectedSlotData['users']);
//           users.add(userId);
//
//           // Update slot data
//           selectedSlotData['numberOfTicketsBooked'] = count + 1;
//           selectedSlotData['users'] = users;
//
//           // Update the document in Firestore
//           await bookingRef.update({ 'slot$selectedSlot': selectedSlotData });
//           print('Appointment booked successfully!');
//           return true;
//         } else {
//           // Slot is fully booked
//           print('Slot is fully booked. Please choose another slot.');
//           return false;
//         }
//       } else {
//         // Slot does not exist, create a new slot
//         Map<String, dynamic> newSlotData = {
//           'numberOfTicketsBooked': 1,
//           'users': [userId],
//         };
//
//         // Update the document in Firestore
//         await bookingRef.update({ 'slot$selectedSlot': newSlotData });
//         print('Appointment booked successfully!');
//         return true;
//       }
//     }
//   }
// }

// class AppointmentManager {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Future<bool> bookAppointment(String dateString, int selectedSlot, String userId, int doctorId) async {
//     // Create a document reference with the doctor's ID
//     DocumentReference doctorRef = _firestore.collection('bookings').doc('$doctorId');
//
//     // Get the document snapshot for the doctor's ID
//     DocumentSnapshot doctorSnapshot = await doctorRef.get();
//
//     // if (!doctorSnapshot.exists) {
//     //   // Doctor document does not exist, create a new document
//     //   Map<String, dynamic> initialSlots = {
//     //     dateString: {
//     //       'slot$selectedSlot': {
//     //         'numberOfTicketsBooked': 1,
//     //         'users': [userId],
//     //       }
//     //     }
//     //   };
//     //
//     //   // Set the document in Firestore
//     //   await doctorRef.set(initialSlots);
//     //   print('Appointment booked successfully!');
//     //   return true;
//     // } else {
//       // Doctor document exists, get the current slot data for the date
//       Map<String, dynamic>? doctorData = doctorSnapshot.data() as Map<String, dynamic>?;
//
//       // Check if the slot for the date is available
//       DateTime parsedDate = DateFormat('d.M.y').parse(dateString);
//       int day = parsedDate.day;
//       int month = parsedDate.month;
//       int year = parsedDate.year;
//
//       print('Day: $day');
//       print('Month: $month');
//       print('Year: $year');
//       Map<String, dynamic>? daySlotData = doctorData?[day.toString()];
//       Map<String, dynamic>? monthSlotData = daySlotData?[month.toString()];
//       Map<String, dynamic>? dateSlotData = monthSlotData?[year.toString()];
//
//       if (dateSlotData != null) {
//         // Slot exists for the date
//         Map<String, dynamic>? selectedSlotData = dateSlotData['slot$selectedSlot'];
//
//         if (selectedSlotData != null) {
//           // Slot exists, check availability and update slot data
//           int count = selectedSlotData['numberOfTicketsBooked'] ?? 0;
//           if (count < 100) {
//             // Slot is available, update slot data with user ID
//             List<dynamic> users = List.from(selectedSlotData['users']);
//             users.add(userId);
//
//             // Update slot data
//             selectedSlotData['numberOfTicketsBooked'] = count + 1;
//             selectedSlotData['users'] = users;
//
//             // Update the document in Firestore
//             await doctorRef.update({ '$dateString.slot$selectedSlot': selectedSlotData });
//             print('Appointment booked successfully!');
//             return true;
//           } else {
//             // Slot is fully booked
//             print('Slot is fully booked. Please choose another slot.');
//             return false;
//           }
//         } else {
//           // Slot does not exist for the selected date, create a new slot
//           Map<String, dynamic> newSlotData = {
//             'numberOfTicketsBooked': 1,
//             'users': [userId],
//           };
//
//           // Update the document in Firestore
//           await doctorRef.update({ '$dateString.slot$selectedSlot': newSlotData });
//           print('Appointment booked successfully!');
//           return true;
//         }
//       } else {
//         // Slot does not exist for the date, create a new slot for the date
//         Map<String, dynamic> newDateSlotData = {
//           'slot$selectedSlot': {
//             'numberOfTicketsBooked': 1,
//             'users': [userId],
//           }
//         };
//
//         // Update the document in Firestore
//         await doctorRef.update({ '$dateString': newDateSlotData });
//         print('Appointment booked successfully!');
//         return true;
//       }
//     }
//   }

// import 'package:intl/intl.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentManager {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> bookAppointment(String dateString, int selectedSlot, String userId, int doctorId) async {
    DocumentReference doctorRef = _firestore.collection('bookings').doc(
        '$doctorId');
    DocumentSnapshot doctorSnapshot = await doctorRef.get();
    Map<String, dynamic>? doctorData = doctorSnapshot.data() as Map<
        String,
        dynamic>?;

    if (doctorData != null) {
      // Parse the dateString to extract day, month, and year
      DateTime parsedDate = DateFormat('d.M.y').parse(dateString);
      int day = parsedDate.day;
      int month = parsedDate.month;
      int year = parsedDate.year;

      // Retrieve slot data based on the date components
      Map<String, dynamic>? daySlotData = doctorData[day.toString()];
      Map<String, dynamic>? monthSlotData = daySlotData?[month.toString()];
      Map<String, dynamic>? dateSlotData = monthSlotData?[year.toString()];

      if (daySlotData !=null && monthSlotData !=null) {
      Map<String, dynamic>? selectedSlotData = dateSlotData?['slot$selectedSlot'];

        if (selectedSlotData != null) {
          int count = selectedSlotData['numberOfTicketsBooked'] ?? 0;
          print("count:$count");
          if (count < 2) {
            List<dynamic> users = selectedSlotData['users']!=null ? List.from(selectedSlotData['users']) : [];
            users.add(userId);
            selectedSlotData['numberOfTicketsBooked'] = count + 1;
            selectedSlotData['users'] = users;
            await doctorRef.update(
                { '$day.$month.$year.slot$selectedSlot': selectedSlotData});
            print('Appointment booked successfully!');
            return true;
          } else {
            print('Slot is fully booked. Please choose another slot.');
            return false;
          }
        }
        else{
          Map<String, dynamic> newDateSlotData = {
            'slot$selectedSlot': {
              'numberOfTicketsBooked': 1,
              'users': [userId],
            }
          };
          DateTime parsedDate = DateFormat('d.M.y').parse(dateString);
          int day = parsedDate.day;
          int month = parsedDate.month;
          int year = parsedDate.year;

          Map<String, dynamic> existingData = {
            '$day.$month.$year': dateSlotData,
          };
          existingData['$day.$month.$year']['slot$selectedSlot'] = newDateSlotData;

          await doctorRef.update(existingData);

          Map<String, dynamic> newDate = {
            '$day': {
              '$month': {
                '$year': newDateSlotData,
              }
            }
          };
          // await doctorRef.update({
          //
          //   '$day.$month.$year': newDateSlotData
          // });
          print('Appointment booked successfullyru!');
          return true;
        }
      }
      else {
        Map<String, dynamic> newDateSlotData = {
          'slot$selectedSlot': {
            'numberOfTicketsBooked': 1,
            'users': [userId],
          }
        };
        DateTime parsedDate = DateFormat('d.M.y').parse(dateString);
        int day = parsedDate.day;
        int month = parsedDate.month;
        int year = parsedDate.year;

        Map<String, dynamic> newDate = {
          '$day': {
            '$month': {
              '$year': newDateSlotData,
            }
          }
        };
        await doctorRef.update({

          '$day.$month.$year': newDateSlotData
        });
        print('Appointment booked successfullyr!');
        return true;
      }
    }
    else {
      return false;
    }
    return false;
  }
}


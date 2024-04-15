import "package:healthapp/features/user_auth/presentation/pages/components/doctor_card.dart";
import "package:flutter/material.dart";
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavPage extends StatefulWidget {
  FavPage({Key? key}) : super(key: key);

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String,dynamic>doctorData={};

  void fetchData(String doctorId) async {
    final User? user = _auth.currentUser;
    var snap = await FirebaseFirestore.instance.collection('doctors').doc(doctorId).get();
    doctorData=snap.data() as Map<String,dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20, right: 20),
        child: Column(
          children: [
            const Text(
              'My Favorite Doctors',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  var favDoctors = userData['fav'] ?? []; // Assuming 'fav' is the field storing favorite doctors

                  return ListView.builder(
                    itemCount: favDoctors.length,
                    itemBuilder: (context, index) {
                      var doctorId = favDoctors[index];
                      return StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance.collection('doctors').doc(doctorId.toString()).snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return SizedBox();
                          }

                          fetchData(doctorId.toString());
                          return DoctorCard(
                            doctor: doctorData,
                            isFav: true,
                          );
                        },
                      );
                    },
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
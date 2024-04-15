import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRView extends StatelessWidget {
  final String userId;
  final String date;
  final String slot;
  final String doctor;

  const QRView({
    Key? key,
    required this.userId,
    required this.date,
    required this.slot,
    required this.doctor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String qrData = '$userId-$slot-$date-$doctor';

    Future<void> addData(String userId, String qr) async {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'qrData':FieldValue.arrayUnion([qr]),
      });
    }

    addData(userId,qrData);

    return Scaffold(
      appBar: AppBar(
        title: Text('QR Code'),
      ),
      body: Stack(
        children: [

          Container(
            color: Colors.blueGrey,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(20),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                ),
                SizedBox(height: 40),
                Text(
                  'Booking Successful!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

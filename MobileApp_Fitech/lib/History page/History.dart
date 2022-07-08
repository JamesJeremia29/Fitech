import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

//history page
class dataHistory extends StatelessWidget {
  DateTime dateToday = new DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);
//query 1 week length firestore documents
  DateTime lastWeek = new DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 7);

  User? user = FirebaseAuth.instance.currentUser;
  String? uid = FirebaseAuth.instance.currentUser?.uid.toString();
  Stream<QuerySnapshot> getDataHistory(BuildContext context) async* {
    yield* FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('History')
        .where('created', isGreaterThanOrEqualTo: lastWeek)
        .orderBy('created', descending: true)
        .snapshots(
            includeMetadataChanges:
                true); /*query user history based on uid and timestamp */
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: StreamBuilder(
              stream: getDataHistory(context),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                //display document fields
                if (snapshot.hasData) {
                  return new ListView(
                    children: snapshot.data!.docs.map((_history) {
                      return Container(
                        padding: EdgeInsets.all(5),
                        child: ListTile(
                          tileColor: Color(0xffD3D3D3),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          title: Text(_history['Variations']),
                          subtitle: Text(_history['Time']),
                          leading: Text(_history['Category']),
                          trailing: Text(_history['Value']),
                        ),
                      );
                    }).toList(),
                  );
                } else {
                  return Center(
                    child: Text(
                      'No Workout in This Week',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                    ),
                  );
                }
              })),
    );
  }
}

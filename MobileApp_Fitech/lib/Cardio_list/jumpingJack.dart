import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fitech_mobile_apps/Cardio_list/workout.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:date_format/date_format.dart';
import 'package:fitech_mobile_apps/Timer_widget.dart';

//code description in Arm_list/pushUp.dart
class jumpingJackWidget extends StatefulWidget {
  bool _isStart;
  jumpingJackWidget(this._isStart);
  @override
  _jumpingJackWidgetState createState() => _jumpingJackWidgetState();
}

class _jumpingJackWidgetState extends State<jumpingJackWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: widget._isStart
          ? ListTile(
              contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              tileColor: Colors.white,
              leading: Icon(
                Icons.rectangle,
                color: Colors.green,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text("Jumping Jack"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => _workoutJJ()));
              },
              trailing: IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => JJinfoPage()));
                  },
                  icon: Icon(Icons.info_outline)),
            )
          : ListTile(
              contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              tileColor: Colors.white60,
              leading: Icon(
                Icons.rectangle,
                color: Colors.green,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text("Jumping Jack"),
              trailing: IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => JJinfoPage()));
                  },
                  icon: Icon(Icons.info_outline)),
            ),
    );
  }
}

class JJinfoPage extends StatefulWidget {
  @override
  _JJinfoPageState createState() => _JJinfoPageState();
}

class _JJinfoPageState extends State<JJinfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jumping Jack"),
        backgroundColor: Colors.blueGrey,
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => cardioPage(),
            ),
          ),
        ),
      ),
    );
  }
}

class _workoutJJ extends StatefulWidget {
  @override
  _workoutJJState createState() => _workoutJJState();
}

class _workoutJJState extends State<_workoutJJ> {
  String timestamp_start = '';
  final _auth = FirebaseAuth.instance;
  int counter = 0;
  String _displayCount = 'counting...';
  final _dataset = FirebaseDatabase.instance.reference();
  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  void _activateListeners() async {
    String? uid = _auth.currentUser?.uid.toString();
    var collection = FirebaseFirestore.instance.collection('Users');
    var docSnapshot = await collection.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var value = data?['product id']; // <-- The value you want to retrieve.
      // Call setState if needed.
      setState(() {
        _dataset.child('$value/IR_count').onValue.listen((event) {
          final IR_count = event.snapshot.value;
          setState(() {
            _displayCount = "$IR_count";
          });
        });
      });
    }
  }

  void _startWorkout() async {
    String? uid = _auth.currentUser?.uid.toString();
    var collection = FirebaseFirestore.instance.collection('Users');
    var docSnapshot = await collection.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var value = data?['product id'];
      setState(() {
        _dataset.child('$value').update({
          'sensor': 1,
        });
      });
    }
  }

  void _finishWorkout() async {
    final _auth = FirebaseAuth.instance;
    DateTime _time = DateTime.now();
    String timestamp = formatDate(_time, [
      yyyy,
      '-',
      mm,
      '-',
      dd,
      ' ',
      HH,
      ':',
      nn,
    ]);
    String? uid = _auth.currentUser?.uid.toString();
    var collection = FirebaseFirestore.instance.collection('Users');
    var docSnapshot = await collection.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var value = data?['product id'];
      setState(() async {
        final snapshot = await _dataset.child('$value/IR_count').get();
        final IR_count = snapshot.value;
        CollectionReference _log =
            FirebaseFirestore.instance.collection("Users");
        _log.doc(uid).collection('History').doc('$timestamp').set({
          'Category': "Cardio",
          'Variations': "Jumping Jack",
          'Time': timestamp,
          'Value': "$IR_count reps",
          'created': FieldValue.serverTimestamp()
        });
        _dataset.child('$value').update({'sensor': 0});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _activateListeners();
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$_displayCount',
                  style: TextStyle(fontSize: 100, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _startWorkout();
                      },
                      child: RoundButton(
                        icon: Icons.play_arrow,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        _finishWorkout();
                      },
                      child: RoundButton(
                        icon: Icons.stop,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => cardioPage()));
                    },
                    child: Text(
                      'DONE',
                      style: TextStyle(color: Colors.blue, fontSize: 20),
                    )),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

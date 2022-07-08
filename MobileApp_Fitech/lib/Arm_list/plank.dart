import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fitech_mobile_apps/Arm_list/workout.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:fitech_mobile_apps/Timer_widget.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:date_format/date_format.dart';

class plankWidget extends StatefulWidget {
  bool _isStart;
  plankWidget(this._isStart);
  @override
  _plankWidgetState createState() => _plankWidgetState();
}

class _plankWidgetState extends State<plankWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: widget._isStart
          ? ListTile(
              //function button = true -> on tap function
              contentPadding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              tileColor: Colors.white,
              leading: Icon(
                Icons.rectangle,
                color: Colors.green,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text("Plank"),
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => _workoutPL()));
              },
              trailing: IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => PLinfoPage()));
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
              title: Text("Plank"),
              trailing: IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => PLinfoPage()));
                  },
                  icon: Icon(Icons.info_outline)),
            ),
    );
  }
}

class PLinfoPage extends StatefulWidget {
  @override
  _PLinfoPageState createState() => _PLinfoPageState();
}

class _PLinfoPageState extends State<PLinfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Plank"),
        backgroundColor: Colors.blueGrey,
        automaticallyImplyLeading: false,
        leading: BackButton(
          color: Colors.white,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => armPage(),
            ),
          ),
        ),
      ),
    );
  }
}

class _workoutPL extends StatefulWidget {
  const _workoutPL({Key? key}) : super(key: key);
  @override
  _workoutPLState createState() => _workoutPLState();
}

class _workoutPLState extends State<_workoutPL> with TickerProviderStateMixin {
  late AnimationController controller;
  final _auth = FirebaseAuth.instance;
  bool isPlaying = false;
  final _dataset = FirebaseDatabase.instance.reference();
  int count = 0;
  int minutes = 0;
  Timer? timer;

  void closeAlert() async {
    //to close to object notification
    String? uid = _auth.currentUser?.uid.toString();
    var collection = FirebaseFirestore.instance.collection('Users');
    var docSnapshot = await collection.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var value = data?['product id'];
      setState(() {
        _dataset.child('$value/warning').onValue.listen((event) {
          final warning = event.snapshot.value;
          setState(() {
            if (warning == 'Move Further') {
              Fluttertoast.showToast(
                  msg: 'Please Move Further',
                  backgroundColor: Colors.redAccent,
                  gravity: ToastGravity.TOP,
                  toastLength: Toast.LENGTH_LONG);
              FlutterRingtonePlayer.playAlarm();
              return;
            } else if (warning != 'Move Further') {
              Fluttertoast.showToast(
                  msg: 'Great Job!',
                  backgroundColor: Colors.green,
                  gravity: ToastGravity.TOP,
                  toastLength: Toast.LENGTH_SHORT);
              FlutterRingtonePlayer.stop();
              return;
            }
            return;
          });
        });
      });
    }
  }

  String get countText {
    Duration count = controller.duration! * controller.value;
    return controller.isDismissed
        ? '${controller.duration!.inHours}:${(controller.duration!.inMinutes % 60).toString().padLeft(2, '0')}:${(controller.duration!.inSeconds % 60).toString().padLeft(2, '0')}'
        : '${count.inHours}:${(count.inMinutes % 60).toString().padLeft(2, '0')}:${(count.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  double progress = 1.0;
  void notify() {
    // finish workout action
    if (countText == '0:00:00') {
      FlutterRingtonePlayer.playNotification();
      UltrasonicOff();
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
      setState(() {
        timer?.cancel();
        CollectionReference _log =
            FirebaseFirestore.instance.collection("Users");
        String? uid = _auth.currentUser?.uid.toString();
        _log.doc(uid).collection('History').doc('$timestamp').set({
          'Category': "Arm",
          'Variations': "Plank",
          'Time': timestamp,
          'Value': "$minutes min $count sec",
          'created': FieldValue.serverTimestamp()
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 60),
    );
    controller.addListener(() {
      notify();
      if (controller.isAnimating) {
        setState(() {
          progress = controller.value;
        });
      } else {
        setState(() {
          progress = 1.0;
          isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void UltrasonicOn() async {
    //to activate device
    String? uid = _auth.currentUser?.uid.toString();
    var collection = FirebaseFirestore.instance.collection('Users');
    var docSnapshot = await collection.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var value = data?['product id']; //access data based on device product id
      setState(() {
        _dataset.child('$value').update({
          'sensor': 2,
        });
      });
    }
  }

  void UltrasonicOff() async {
    //to deactivate device
    String? uid = _auth.currentUser?.uid.toString();
    var collection = FirebaseFirestore.instance.collection('Users');
    var docSnapshot = await collection.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var value = data?['product id']; //access data based on device product id
      setState(() {
        _dataset.child('$value').update({
          'sensor': 0,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.grey.shade300,
                    value: progress,
                    strokeWidth: 6,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (controller.isDismissed) {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => Container(
                          height: 300,
                          child: CupertinoTimerPicker(
                            initialTimerDuration: controller.duration!,
                            onTimerDurationChanged: (time) {
                              setState(() {
                                controller.duration = time;
                                return;
                              });
                              return;
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (context, child) => Text(
                      countText,
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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
                        timer = Timer.periodic(
                          const Duration(seconds: 1),
                          (timer) {
                            setState(() {
                              if (count < 60) {
                                count++;
                              } else if (count == 60) {
                                count = 0;
                                minutes++;
                              }
                            });
                          },
                        );
                        if (controller.isAnimating) {
                          controller.stop();
                          setState(() {
                            isPlaying = false;
                            UltrasonicOff();
                          });
                        } else {
                          closeAlert();
                          controller.reverse(
                              from: controller.value == 0
                                  ? 1.0
                                  : controller.value);
                          setState(() {
                            isPlaying = true;
                            UltrasonicOn();
                          });
                        }
                      },
                      child: RoundButton(
                        icon:
                            isPlaying == true ? Icons.pause : Icons.play_arrow,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        UltrasonicOff();
                        controller.reset();
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
                        setState(() {
                          /*send data history*/
                          timer?.cancel();
                          isPlaying = false;
                          CollectionReference _log =
                              FirebaseFirestore.instance.collection("Users");
                          String? uid = _auth.currentUser?.uid.toString();
                          _log
                              .doc(uid)
                              .collection('History')
                              .doc('$timestamp')
                              .set({
                            'Category': "Arm",
                            'Variations': "Plank",
                            'Time': timestamp,
                            'Value': "$minutes min $count sec",
                            'created': FieldValue.serverTimestamp()
                          });
                        });
                        count = 0;
                        minutes = 0;
                      },
                      child: RoundButton(
                        icon: Icons.stop,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => armPage()));
                      UltrasonicOff();
                    },
                    child: Text(
                      'DONE',
                      style: TextStyle(color: Colors.blue, fontSize: 20),
                    )),
                SizedBox(height: 10),
              ],
            ),
          )
        ],
      ),
    );
  }
}

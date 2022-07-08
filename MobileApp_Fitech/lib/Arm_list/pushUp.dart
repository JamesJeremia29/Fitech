import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitech_mobile_apps/home.dart';
import 'package:flutter/material.dart';
import 'package:fitech_mobile_apps/Arm_list/workout.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:date_format/date_format.dart';
import 'package:fitech_mobile_apps/Timer_widget.dart';
import 'package:video_player/video_player.dart';

class pushUpWidget extends StatefulWidget {
  bool _isStart;
  pushUpWidget(this._isStart);
  @override
  _pushUpWidgetState createState() => _pushUpWidgetState();
}

class _pushUpWidgetState extends State<pushUpWidget> {
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
              title: Text("Push Up"),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => _workoutPU()));
              },
              trailing: IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => PUinfoPage()));
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
              title: Text("Push Up"),
              trailing: IconButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => PUinfoPage()));
                  },
                  icon: Icon(Icons.info_outline)),
            ),
    );
  }
}

class PUinfoPage extends StatefulWidget {
  @override
  _PUinfoPageState createState() => _PUinfoPageState();
}

class _PUinfoPageState extends State<PUinfoPage> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  /*Tutorial Video Player */
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(
      'assets/video/push_up.mp4',
    );
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Push Up"),
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
  }*/
  @override //video func
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Butterfly Video'),
      ),
      // Use a FutureBuilder to display a loading spinner while waiting for the
      // VideoPlayerController to finish initializing.
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            return AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              // Use the VideoPlayer widget to display the video.
              child: VideoPlayer(_controller),
            );
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Wrap the play or pause in a call to `setState`. This ensures the
          // correct icon is shown.
          setState(() {
            // If the video is playing, pause it.
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              // If the video is paused, play it.
              _controller.play();
            }
          });
        },
        // Display the correct icon depending on the state of the player.
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

class _workoutPU extends StatefulWidget {
  @override
  _workoutPUState createState() => _workoutPUState();
}

class _workoutPUState extends State<_workoutPU> {
  final _auth = FirebaseAuth.instance;
  String timestamp_start = '';
  int counter = 0;
  String _displayCount = 'counting...';
  final _dataset = FirebaseDatabase.instance.reference();
  @override
  void initState() {
    super.initState();
    _activateListeners();
  }

  void _activateListeners() async {
    //listen to counter values
    String? uid = _auth.currentUser?.uid.toString();
    var collection = FirebaseFirestore.instance.collection('Users');
    var docSnapshot = await collection.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var value = data?['product id']; // <-- The value product id to retrieve
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
    //activate device
    String? uid = _auth.currentUser?.uid.toString();
    var collection = FirebaseFirestore.instance.collection('Users');
    var docSnapshot = await collection.doc(uid).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var value = data?['product id']; // access data based on product id
      setState(() {
        _dataset.child('$value').update({
          'sensor': 1,
        });
      });
    }
  }

  void _finishWorkout() async {
    //deactivate device
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
        //send data history
        final snapshot = await _dataset.child('$value/IR_count').get();
        final IR_count = snapshot.value;
        CollectionReference _log =
            FirebaseFirestore.instance.collection("Users");
        _log.doc(uid).collection('History').doc('$timestamp').set({
          'Category': "Arm",
          'Variations': "Push Up",
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
                          MaterialPageRoute(builder: (_) => armPage()));
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitech_mobile_apps/Arm_list/workout.dart';
import 'package:fitech_mobile_apps/Upper_list/workout.dart';
import 'package:fitech_mobile_apps/Cardio_list/workout.dart';
import 'package:fitech_mobile_apps/Lower_list/workout.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'package:app_settings/app_settings.dart';
import 'package:fitech_mobile_apps/History page/History.dart';
import 'ML_API.dart';
import 'datamodel.dart';

class HomeScreen extends StatefulWidget {
  final int currentIndex; //for bottom navigation bar index
  const HomeScreen({Key? key, required this.currentIndex}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ML> futureML; //to display ML web API
  User? user = FirebaseAuth.instance.currentUser; //Access Firebase Auth data
  String? uid = FirebaseAuth.instance.currentUser?.uid
      .toString(); //Save current UID Login info
  int _selectedIndex = 1; //default bottom nav bar poge
  DateTime lastWeek = new DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day - 7);

  String _displayBmi = ""; //value for Bmi widget
  DateTime dateToday = new DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);

  var stats = 0; //value for Total Workouts
  var week = 0; //Value for This Week's Workouts
  workoutstats() async {
    final query = FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .collection('History')
        .get()
        .then((documents) {
      setState(() {
        stats = documents.docs.length; //query current user document length
      });
    });

    final weekQuery = FirebaseFirestore.instance
        .collection("Users")
        .doc(uid)
        .collection('History')
        .where('created', isGreaterThanOrEqualTo: lastWeek) //for 1 week data
        .get()
        .then((documents) {
      setState(() {
        week = documents.docs.length; //query current user document length
      });
    });
  }

  void _bmiCalculator() async {
    double? _personalBmi;
    var collection = FirebaseFirestore.instance.collection('Users');
    final Bmi = collection.doc(uid).snapshots().listen((docSnapshot) {
      Map<String, dynamic> data = docSnapshot.data()!;
      final double? heightBmi =
          double.tryParse(data['height']); //retrieve current user height
      final double? weightBmi =
          double.tryParse(data['weight']); //retrieve current user weight
      _personalBmi = weightBmi! / ((heightBmi! * 0.01) * (heightBmi * 0.01));
      //Bmi Calculator
      if (_personalBmi! < 18.5) {
        _displayBmi = "Underweight";
        return;
      } else if (_personalBmi! < 25) {
        _displayBmi = "Ideal!";
        return;
      } else if (_personalBmi! >= 25) {
        _displayBmi = "Overweight";
        return;
      } else {
        _displayBmi = "Obese";
        return;
      }
    });
  }

  @override
  void initState() {
    _selectedIndex = widget.currentIndex;
    super.initState();
    futureML = fetchValue(); //fetch string recommendation value
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; //Bottom nav bar
    });
  }

  final editHeightEditingController =
      new TextEditingController(); //to update current user height data
  final editWeightEditingController =
      new TextEditingController(); //to update current user weight data

  @override
  Widget build(BuildContext context) {
    final editWeight = TextFormField(
      controller: editWeightEditingController,
      autofocus: false,
      autocorrect: false,
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.black),
      validator: (value) {
        if (value!.isEmpty) {
          return ("Weight cannot be Empty");
        }
        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
          return ("Please Enter a valid Weight");
        }
        return null;
      },
      onSaved: (value) {
        editHeightEditingController.text = value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        suffix: Text("Kg"),
        hintText: "Enter Your Weight",
        hintStyle: TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    final editHeight = TextFormField(
      controller: editHeightEditingController,
      autofocus: false,
      autocorrect: false,
      keyboardType: TextInputType.number,
      style: TextStyle(color: Colors.black),
      validator: (value) {
        if (value!.isEmpty) {
          return ("Height cannot be Empty");
        }
        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
          return ("Please Enter a valid Height");
        }
        return null;
      },
      onSaved: (value) {
        editHeightEditingController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
        suffix: Text("Cm"),
        hintText: "Enter Your Height",
        hintStyle: TextStyle(color: Colors.black54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    _bmiCalculator();
    workoutstats();
    return Scaffold(
      appBar: AppBar(
        title: const Text("FiTech"),
        backgroundColor: Colors.blueGrey,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            LoginScreen())); //icon button for logout to login screen
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      backgroundColor: Color(0xffD3D3D3),
      body: IndexedStack(
        index: _selectedIndex,
        children: <Widget>[
          WorkOutPage(),
          Center(
            child: StreamBuilder(
              /*Listen data value*/
              stream: FirebaseFirestore.instance
                  .collection("Users")
                  .where("uid", isEqualTo: uid) //listen for current user data
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                return ListView.builder(
                  itemCount: streamSnapshot.data?.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      child: Column(
                        children: [
                          Card(
                            clipBehavior: Clip.antiAlias,
                            elevation: 8,
                            shadowColor: Colors.blueGrey,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Container(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      colors: [
                                    Color(0x80000000),
                                    Color(0x8c000000),
                                    Color(0x99000000),
                                    Color(0xb3000000),
                                    Color(0xcc000000),
                                  ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight)),
                              padding: EdgeInsets.all(50),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Hi, ${streamSnapshot.data?.docs[index]['fullName']}", //display user name
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.left,
                                  ),
                                  SizedBox(height: 30),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Status: $_displayBmi", //display current Bmi
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      IconButton(
                                          onPressed: () => showDialog(
                                              // dialog contain text field to edit Weight/Height
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  AlertDialog(
                                                    title: Text(
                                                        'Input your current height and weight'),
                                                    actions: [
                                                      editHeight,
                                                      SizedBox(height: 10),
                                                      editWeight,
                                                      TextButton(
                                                          onPressed: () {
                                                            //display dialog to update weight and height
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'Users')
                                                                .doc(uid)
                                                                .update({
                                                              'height':
                                                                  editHeightEditingController
                                                                      .text, //update current user height data
                                                              'weight':
                                                                  editWeightEditingController
                                                                      .text //update current user weight data
                                                            });
                                                            Navigator.pop(
                                                                context,
                                                                'Submit');
                                                          },
                                                          child: Text("Submit"))
                                                    ],
                                                  )),
                                          icon: Icon(
                                            Icons.edit_note_outlined,
                                            color: Colors.white,
                                          ))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Card(
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 8,
                                  shadowColor: Colors.blueGrey,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: [
                                          Color(0x80000000),
                                          Colors.blueGrey,
                                        ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight)),
                                    padding:
                                        EdgeInsets.fromLTRB(10, 35, 10, 35),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Workouts',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Text(
                                          '$stats', //show total number of workouts
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Card(
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 8,
                                  shadowColor: Colors.blueGrey,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: [
                                          Color(0x80000000),
                                          Colors.blueGrey,
                                        ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight)),
                                    padding:
                                        EdgeInsets.fromLTRB(24, 30, 24, 30),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "This Week's",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        Text(
                                          "Workouts",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          '$week', //show number of workout in a week
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 36,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Card(
                                  clipBehavior: Clip.antiAlias,
                                  elevation: 8,
                                  shadowColor: Colors.blueGrey,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            colors: [
                                          Colors.blueGrey,
                                          Colors.black,
                                        ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight)),
                                    padding: EdgeInsets.all(20.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Recommended Exercise",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        SizedBox(height: 20),
                                        FutureBuilder<ML>(
                                          //one time fetch ML web API
                                          future: futureML,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Text(
                                                snapshot.data!.Recommend,
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              );
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                'No Suggestions yet',
                                                style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              );
                                            }
                                            return CircularProgressIndicator();
                                          },
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        FutureBuilder<ML>(
                                          future: futureML,
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              if (snapshot.data!.Recommend ==
                                                  'push_up') {
                                                return Text(
                                                  'Category: Arm, Upper',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.white),
                                                );
                                              } else if (snapshot
                                                      .data!.Recommend ==
                                                  'pull_up') {
                                                return Text(
                                                  'Category: Arm',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.white),
                                                );
                                              } else if (snapshot
                                                      .data!.Recommend ==
                                                  'plank') {
                                                return Text(
                                                  'Category: Arm, Upper',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.white),
                                                );
                                              } else if (snapshot
                                                      .data!.Recommend ==
                                                  'weight_lift') {
                                                return Text(
                                                  'Category: Arm',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.white),
                                                );
                                              } else if (snapshot
                                                      .data!.Recommend ==
                                                  'squat') {
                                                return Text(
                                                  'Category: Lower, Cardio',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.white),
                                                );
                                              } else if (snapshot
                                                      .data!.Recommend ==
                                                  'burpees') {
                                                return Text(
                                                  'Category: Cardio',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.white),
                                                );
                                              } else if (snapshot
                                                      .data!.Recommend ==
                                                  'mountain_climber') {
                                                return Text(
                                                  'Category: Lower',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.white),
                                                );
                                              } else if (snapshot
                                                      .data!.Recommend ==
                                                  'sit_up') {
                                                return Text(
                                                  'Category: Upper',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.white),
                                                );
                                              } else if (snapshot
                                                      .data!.Recommend ==
                                                  'jumping_jacks') {
                                                return Text(
                                                  'Category: Cardio',
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.white),
                                                );
                                              }
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                'No Suggestions yet',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w300,
                                                    color: Colors.white),
                                              );
                                            }
                                            return CircularProgressIndicator();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          dataHistory(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        //Bottom Nav bar to change page
        selectedFontSize: 16,
        selectedIconTheme: IconThemeData(color: Colors.blueGrey, size: 40),
        selectedItemColor: Colors.blueGrey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class WorkOutPage extends StatelessWidget {
  const WorkOutPage();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TabBar(
                tabs: [
                  Tab(
                    text: 'Menu',
                  ),
                  Tab(
                    text: 'Connect Device',
                  ),
                ],
              )
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MenuPage(),
            ConnectDevicePage(),
          ],
        ),
      ),
    );
  }
}

class ConnectDevicePage extends StatefulWidget {
  @override
  _ConnectDevicePageState createState() => _ConnectDevicePageState();
}

class _ConnectDevicePageState extends State<ConnectDevicePage>
    with AutomaticKeepAliveClientMixin<ConnectDevicePage> {
  int count = 10;
  final _auth = FirebaseAuth.instance;
  final TextEditingController product_id =
      new TextEditingController(); //to configure device
  @override
  void clear() {
    setState(() {
      count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? uid = _auth.currentUser?.uid.toString();
    final idfield = TextFormField(
        autofocus: false,
        controller: product_id,
        style: TextStyle(color: Colors.black),
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.code),
          contentPadding: EdgeInsets.all(10.0),
          hintText: "Enter Your Product ID",
          hintStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));
    return Scaffold(
      backgroundColor: Colors.grey[350],
      body: Center(
          child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset("assets/image/Connect.png"),
            SizedBox(height: 40),
            idfield,
            ElevatedButton(
                onPressed: () async {
                  FirebaseFirestore.instance
                      .collection('Users')
                      .doc(uid)
                      .update({
                    'product id': product_id.text
                  }); //send device product id
                  AppSettings
                      .openWIFISettings(); //function to access wifi phone settings
                },
                child: Text("Configure")),
            SizedBox(height: 50),
            Text(
              "To connect your Fitech device: \n 1. Enter Product ID and click 'Configure' \n 2. Select Fitech and input Workout for password \n 3. Choose configure WiFi \n 4. Choose available Wifi (input wifi name in SSID field, if WiFi not yet registered) \n 5. Input WiFi password and click Save",
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      )),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(1.0),
            child: Column(children: <Widget>[
              FlatButton(
                splashColor: Colors.white70,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              armPage())); //navigate to workout page
                },
                child: Container(
                  padding: EdgeInsets.all(24),
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/image/WO_arm.png'),
                          colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.1),
                            BlendMode.darken,
                          ))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 175),
                      Text(
                        'ARM',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                padding: EdgeInsets.all(1.0),
              ),
              FlatButton(
                splashColor: Colors.white70,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => upperPage()));
                },
                child: Container(
                  padding: EdgeInsets.all(24),
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/image/WO_chest.png'),
                          colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.8),
                            BlendMode.darken,
                          ))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 175),
                      Text(
                        'UPPER',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                padding: EdgeInsets.all(1.0),
              ),
              FlatButton(
                splashColor: Colors.white70,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => lowerPage()));
                },
                child: Container(
                  padding: EdgeInsets.all(24),
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/image/WO_leg.png'),
                          colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.1),
                            BlendMode.darken,
                          ))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 175),
                      Text(
                        'LOWER',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                padding: EdgeInsets.all(1.0),
              ),
              FlatButton(
                splashColor: Colors.white70,
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => cardioPage()));
                },
                child: Container(
                  padding: EdgeInsets.all(24),
                  height: 250,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage('assets/image/WO_cardio.png'),
                          colorFilter: ColorFilter.mode(
                            Colors.white.withOpacity(0.1),
                            BlendMode.darken,
                          ))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 175),
                      Text(
                        'CARDIO',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                padding: EdgeInsets.all(1.0),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

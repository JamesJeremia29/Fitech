import 'package:fitech_mobile_apps/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fitech_mobile_apps/home.dart';
import 'package:fitech_mobile_apps/Cardio_list/squat.dart';
import 'package:fitech_mobile_apps/Cardio_list/jumpingJack.dart';
import 'package:fitech_mobile_apps/Cardio_list/burpees.dart';

class cardioPage extends StatefulWidget {
  @override
  _cardioPageState createState() => _cardioPageState();
}

class _cardioPageState extends State<cardioPage> {
  bool _isStart = false; //button condition to activate exercise
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text("FiTech"),
          backgroundColor: Colors.blueGrey,
          automaticallyImplyLeading: false,
          leading: BackButton(
            color: Colors.white,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(currentIndex: 0),
              ),
            ),
          ),
        ),
        backgroundColor: Color(0xccD3D3D3).withOpacity(0x1),
        body: Center(
            child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    RichText(
                        text: TextSpan(children: [
                      WidgetSpan(
                          child: Icon(
                        Icons.rectangle,
                        color: Colors.green,
                        size: 16,
                      )),
                      TextSpan(
                          text: 'Easy ', style: TextStyle(color: Colors.black)),
                    ])),
                    RichText(
                        text: TextSpan(children: [
                      WidgetSpan(
                          child: Icon(
                        Icons.rectangle,
                        color: Colors.yellow,
                        size: 16,
                      )),
                      TextSpan(
                          text: 'Medium ',
                          style: TextStyle(color: Colors.black)),
                    ])),
                    RichText(
                        text: TextSpan(children: [
                      WidgetSpan(
                          child: Icon(
                        Icons.rectangle,
                        color: Colors.red,
                        size: 16,
                      )),
                      TextSpan(
                          text: 'Hard ', style: TextStyle(color: Colors.black)),
                    ])),
                  ],
                ),
                SizedBox(height: 10),
                functionButton(),
                SizedBox(height: 50),
                squatWidget(_isStart),
                SizedBox(height: 5),
                jumpingJackWidget(_isStart),
                SizedBox(height: 5),
                burpeesWidget(_isStart),
              ],
            ),
          ),
        )));
  }

  Widget functionButton() {
    return RaisedButton(
      elevation: 5,
      padding: EdgeInsets.all(1),
      onPressed: () {
        if (_isStart == false) {
          setState(() {
            _isStart = true; //if press = true, exercise accessible
          });
        } else {
          setState(() {
            _isStart = false;
          });
        }
      },
      child: _isStart ? Text("stop") : Text("start"),
    );
  }
}

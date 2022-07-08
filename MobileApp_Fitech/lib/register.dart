import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitech_mobile_apps/login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

Widget SignUpText() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        'Sign Up',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
      )
    ],
  );
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = FirebaseAuth.instance; //firebase auth

  String? errorMessage;

  final _formKey = GlobalKey<FormState>();

  final fullNameEditingController = new TextEditingController();
  final AgeEditingController = new TextEditingController();
  final heightEditingController = new TextEditingController();
  final weightEditingController = new TextEditingController();
  final emailEditingController = new TextEditingController();
  final passwordEditingController = new TextEditingController();
  final confirmPasswordEditingController = new TextEditingController();

  DateTime date = DateTime(2022, 12, 24);
  final List<String> items = [
    'Bali',
    'Bandung',
    'Jakarta',
    'Manado',
    'Surabaya',
    'Tangerang'
  ]; //list of cities for dropdown menu

  String? dropdownvalues;
  String? gender;
  final List<String> genders = [
    "Male",
    "Female",
    "Other"
  ]; //;ist of gender for dropdown menu

  Widget birthDate(context) {
    //widget for pick birthdate using Calendar
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('${date.year}/${date.month}/${date.day}',
            style: TextStyle(fontSize: 32, color: Colors.white)),
        const SizedBox(height: 16),
        ElevatedButton(
            onPressed: () async {
              DateTime? newDate = await showDatePicker(
                  /*widget calendar*/
                  context: context,
                  initialDate: date,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100));
              if (newDate == null) return;

              setState(() => date = newDate);
            },
            child: Text('Select Date'))
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final fullNameField = TextFormField(
        //field entering name
        autofocus: false,
        controller: fullNameEditingController,
        keyboardType: TextInputType.name,
        style: TextStyle(color: Colors.white),
        validator: (value) {
          RegExp regex = new RegExp(r'^.{3,}$');
          if (value!.isEmpty) {
            return ("First Name cannot be Empty"); //check for empty values
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid name(Min. 3 Character)"); //check characters count
          }
          return null;
        },
        onSaved: (value) {
          fullNameEditingController.text = value!; //save value to controller
        },
        textInputAction: TextInputAction.next, //navigate to next field
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.account_circle),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Full Name",
          hintStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final emailField = TextFormField(
        autofocus: false,
        controller: emailEditingController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(color: Colors.white),
        validator: (value) {
          if (value!.isEmpty) {
            return ("Please Enter Your Email");
          }
          // reg expression for email validation
          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
              .hasMatch(value)) {
            return ("Please Enter a valid email"); //check email format
          }
          return null;
        },
        onSaved: (value) {
          emailEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.mail),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Email",
          hintStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final countryField = Container(
      alignment: Alignment.centerLeft,
      child: DropdownButton(
        //dropdown menu to choose country
        value: dropdownvalues,
        dropdownColor: Color(0xff525252),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.white,
        ),
        items: items.map((items) {
          return DropdownMenuItem(
              value: items,
              child: Text(
                "$items",
                /*to use list of country values*/
                style: TextStyle(color: Colors.white),
              ));
        }).toList(),
        onChanged: (val) => setState(() => dropdownvalues =
            val as String), //if chosen display show chosen country
      ),
    );

    final genderField = Container(
      alignment: Alignment.centerLeft,
      child: DropdownButton(
        value: gender,
        dropdownColor: Color(0xff525252),
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: Colors.white,
        ),
        items: genders.map((genders) {
          return DropdownMenuItem(
              value: genders,
              child: Text(
                "$genders",
                /*to use list of gender values*/
                style: TextStyle(color: Colors.white),
              ));
        }).toList(),
        onChanged: (val) => setState(() => gender = val as String),
      ),
    );

    final ageField = TextFormField(
        autofocus: false,
        controller: AgeEditingController,
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.white),
        validator: (value) {
          if (value!.isEmpty) {
            return ("Age cannot be Empty");
          }
          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
            return ("Please Enter a valid Age"); //check if text input is number
          }
          return null;
        },
        onSaved: (value) {
          AgeEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.cake),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Enter Your Age",
          hintStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final weightField = TextFormField(
        autofocus: false,
        controller: weightEditingController,
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.white),
        validator: (value) {
          if (value!.isEmpty) {
            return ("Weight cannot be Empty");
          }
          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
            return ("Please Enter a valid Weight"); //check if text input is number
          }
          return null;
        },
        onSaved: (value) {
          weightEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          suffix: Text("Kg"),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Enter Your Weight",
          hintStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final heightField = TextFormField(
        autofocus: false,
        controller: heightEditingController,
        keyboardType: TextInputType.number,
        style: TextStyle(color: Colors.white),
        validator: (value) {
          if (value!.isEmpty) {
            return ("Height cannot be Empty");
          }
          if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
            return ("Please Enter a valid Height"); //check if text input is number
          }
          return null;
        },
        onSaved: (value) {
          heightEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          suffix: Text("cm"),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Enter Your Height",
          hintStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final passwordField = TextFormField(
        autofocus: false,
        controller: passwordEditingController,
        obscureText: true,
        validator: (value) {
          RegExp regex = new RegExp(r'^.{6,}$');
          if (value!.isEmpty) {
            return ("Password is required for login");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Password(Min. 6 Character)"); //check password count
          }
        },
        onSaved: (value) {
          passwordEditingController.text = value!;
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          hintStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final confirmPasswordField = TextFormField(
        autofocus: false,
        controller: confirmPasswordEditingController,
        obscureText: true,
        validator: (value) {
          if (confirmPasswordEditingController.text !=
              passwordEditingController.text) {
            return "Password don't match"; //check if value = password field
          }
          return null;
        },
        onSaved: (value) {
          confirmPasswordEditingController.text = value!;
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Confirm Password",
          hintStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final signUpButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.white,
      child: MaterialButton(
          padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              //check with validators
              signUp(context); //to write data for firebase auth
            }
          },
          child: Text(
            "Sign Up",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                color: Color(0xb3000000),
                fontWeight: FontWeight.bold),
          )),
    );

    return Scaffold(
      //UI for Sign Up
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Form(
          key: _formKey,
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                      Color(0x80000000),
                      Color(0x8c000000),
                      Color(0x99000000),
                      Color(0xb3000000),
                      Color(0xcc000000),
                    ])),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 50,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 10),
                      SignUpText(),
                      SizedBox(height: 50),
                      fullNameField,
                      SizedBox(height: 30),
                      emailField,
                      SizedBox(height: 30),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Country',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                      countryField,
                      SizedBox(height: 20),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Gender',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ),
                      genderField,
                      SizedBox(height: 30),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Input Your Birth Date',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                      birthDate(context),
                      SizedBox(height: 30),
                      weightField,
                      SizedBox(height: 30),
                      heightField,
                      SizedBox(height: 30),
                      passwordField,
                      SizedBox(height: 30),
                      confirmPasswordField,
                      SizedBox(height: 50),
                      signUpButton
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> userSetup() async {
    //Function write data to Firestore
    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    String? uid = _auth.currentUser?.uid.toString();
    users.doc(uid).set({
      'fullName': fullNameEditingController.text,
      'uid': uid,
      'email': emailEditingController.text,
      'country': dropdownvalues,
      'gender': gender,
      'birthdate': date,
      'height': heightEditingController.text,
      'weight': weightEditingController.text,
      'product id': ''
    });
    return;
  }

  void signUp(context) {
    try {
      //Function to create user in Firebase Auth
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailEditingController.text,
              password: passwordEditingController.text)
          .then((value) => {
                Fluttertoast.showToast(
                    msg: "Account Created",
                    gravity: ToastGravity.TOP,
                    backgroundColor: Colors.green,
                    toastLength: Toast.LENGTH_LONG),
                userSetup(),
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => LoginScreen()))
              });
    } on FirebaseAuthException catch (e) {
      print(e.code);
      print(e.message);
    }
  }
}

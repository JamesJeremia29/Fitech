import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitech_mobile_apps/home.dart';
import 'package:fitech_mobile_apps/register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

Widget buildSignUpBtn(context) {
  return GestureDetector(
    onTap: () {
      /* Button on Tap Function*/
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  SignUpScreen())); //Navigate to Register Screen
    },
    child: RichText(
      text: TextSpan(children: [
        TextSpan(
            text: "Don't Have an Account? ",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            )),
        TextSpan(
          /*to create Text as button */
          text: 'Sign Up',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        )
      ]),
    ),
  );
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); //Global key for validations
  String? errorMessage;
  // editing controller
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  final _auth = FirebaseAuth.instance; //firebase authentication

  @override
  Widget build(BuildContext context) {
    final emailField = TextFormField(
        //field to input email address
        autofocus: false,
        controller: emailController,
        style: TextStyle(color: Colors.white),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return ("Please Enter Your Email"); //return error msg if empty
          }
          if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
              .hasMatch(value)) {
            return ("Please Enter a valid email"); //check text format
          }
          return null;
        },
        onSaved: (value) {
          emailController.text = value!; //saving value on controller
        },
        textInputAction: TextInputAction.next, //navigate to next field
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.mail),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Email",
          hintStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final passwordField = TextFormField(
        style: TextStyle(color: Colors.white),
        autofocus: false,
        controller: passwordController,
        obscureText: true,
        validator: (value) {
          RegExp regex = new RegExp(r'^.{6,}$');
          if (value == null || value.isEmpty) {
            return ("Password is required for login");
          }
          if (!regex.hasMatch(value)) {
            return ("Enter Valid Password(Min. 6 Character)"); //check password count
          }
          return null;
        },
        onSaved: (value) {
          passwordController.text = value!;
        },
        textInputAction: TextInputAction.done, //close keyboard
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.vpn_key),
          contentPadding: EdgeInsets.fromLTRB(20, 15, 20, 15),
          hintText: "Password",
          hintStyle: TextStyle(color: Colors.white),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ));

    final loginButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.white,
      child: MaterialButton(
          //button for submit
          padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
          minWidth: MediaQuery.of(context).size.width,
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              /*check with validator*/
              signIn(
                  context); /*run function to authenticate registered user in Firebase auth data*/
            }
          },
          child: Text(
            "Login",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                color: Color(0xb3000000),
                fontWeight: FontWeight.bold),
          )),
    );

    return Scaffold(
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
                      Image.asset('assets/image/login_register.png'),
                      SizedBox(height: 10),
                      emailField,
                      SizedBox(height: 50),
                      passwordField,
                      SizedBox(height: 80),
                      loginButton,
                      SizedBox(height: 10),
                      buildSignUpBtn(context),
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

  void signIn(context) {
    //function for authentication with firebase auth
    try {
      FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text,
              password: passwordController
                  .text) //check if email and password registered
          .then((value) => {
                Fluttertoast.showToast(
                    msg: "Login Successful!",
                    backgroundColor: Colors.green,
                    gravity: ToastGravity.TOP,
                    toastLength: Toast.LENGTH_LONG),
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreen(
                            currentIndex:
                                1))), //if registered push navigation to Home Screen
              });
    } on FirebaseAuthException catch (e) {
      print(e.code);
      print(e.message);
      if (e.code == 'user-not-found') {
        print('No user found for that email.'); //email doesn't exist
        Fluttertoast.showToast(
            msg: "invalid email",
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            gravity: ToastGravity.TOP);
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.'); //wrong password
        Fluttertoast.showToast(
            msg: "wrong password",
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.red,
            gravity: ToastGravity.TOP);
      }
    }
  }
}

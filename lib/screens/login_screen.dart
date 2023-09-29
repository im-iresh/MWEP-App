import 'package:chat_app/screens/chat_screen.dart';
import 'package:chat_app/screens/forgot_password_page.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/rounded_button.dart';
import 'package:chat_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // late String email;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // late String password;
  final _auth =FirebaseAuth.instance;
  bool showSpinner=false;
  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    // final user = _auth.currentUser;
    // if(user!=null){
    //   Navigator.pushNamed(context, ChatScreen.id);
    // }
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: Container(
                      height: 200.0,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                  SizedBox(
                    height: 48.0,
                  ),
                  TextField(
                    controller: _emailController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.emailAddress,
                    // onChanged: (value) {
                    //   email=value;
                    //   //Do something with the user input.
                    // },
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: 'Enter Your Email'
                    )
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    controller: _passwordController,
                    textAlign: TextAlign.center,
                    obscureText: true,
                    // onChanged: (value) {
                    //   password=value;
                    // },
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Enter Your Password'
                      )
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              decoration: TextDecoration.underline
                            ),
                          ),
                          onTap: (){
                            Navigator.pushNamed(context, ForgotPasswordPage.id);
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  RoundedButton(
                    color: Colors.lightBlueAccent,
                    onPressed: () async{


                      try{
                        setState(() {
                          showSpinner=true;
                        });
                        String s = _emailController.text.trim();
                        if(!s.endsWith('@lnmiit.ac.in')){
                          s="$s@lnmiit.ac.in";
                        }
                        final user = await _auth.signInWithEmailAndPassword(
                            email: s, password: _passwordController.text.trim());

                        setState(() {
                          showSpinner=false;
                        });
                        _emailController.clear();
                        _passwordController.clear();
                        // email="";
                        // password="";
                        if (user != null) {
                          Navigator.pushNamed(context, ChatScreen.id);
                        }
                      }on FirebaseAuthException
                      catch(e){
                        if(showSpinner){
                          setState(() {
                            showSpinner=false;
                          });
                        }

                        print(e);
                        showDialog(context: context, builder: (context){
                          return AlertDialog(
                            content: Text(e.message.toString()),
                          );
                        });
                      }
                    },
                    text: 'Log In',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

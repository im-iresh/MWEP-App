import 'package:chat_app/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/rounded_button.dart';
import 'package:chat_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';
  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  bool showSpinner=false;
  // Text Controllers
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _batchController = TextEditingController();
  final _groupIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool checkMobile(String number){
    if(number.length==10 || number.length==11){
      return true;
    }
    showDialog(context: context, builder: (context){
      return const AlertDialog(
        content: Text('Invalid Number'),
      );
    });
    return false;
  }
  bool checkMail(String mail){
    if( mail.endsWith("@lnmiit.ac.in")){
      return true;
    }
    showDialog(context: context, builder: (context){
      return const AlertDialog(
        content: Text('Invalid mail-id, please use College mail-id'),
      );
    });
    return false;
  }
  bool checkPassword(String a, String b){
    if(a==b){
      return true;
    }
    showDialog(context: context, builder: (context){
      return const AlertDialog(
        content: Text('Passwords don\'t match'),
      );
    });
    return false;
  }
  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _nameController.dispose();
    _batchController.dispose();
    _groupIdController.dispose();
    _passwordController.dispose();
    _mobileNumberController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future signUp() async{
    setState(() {
      showSpinner=true;
    });
    if(checkMail(_emailController.text.trim()) && checkMobile(_mobileNumberController.text.trim())
        && checkPassword(_passwordController.text.trim(), _confirmPasswordController.text.trim())){
      // creating User
      try{
        await _auth.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim()
        );
        setState(() {
          showSpinner=false;
        });
        // Adding user details
        addUserDetails();
        clearControllers();
        Navigator.pushNamed(context, ChatScreen.id);
      } on FirebaseAuthException
      catch(e){
        setState(() {
          showSpinner=false;
        });
        showDialog(context: context, builder: (context){
          return AlertDialog(
            content: Text(e.message.toString()),
          );
        });
      }
    }
    else{
      setState(() {
        showSpinner=false;
      });
    }
  }
  Future addUserDetails()async{
    await _firestore.collection('users').add({
      'email': _emailController.text.trim(),
      'name':_nameController.text.trim(),
      'batch':_batchController.text.trim(),
      'group':_groupIdController.text.trim(),
      'mobile':_mobileNumberController.text.trim()
    });
  }
  void clearControllers(){
    _emailController.clear();
    _nameController.clear();
    _batchController.clear();
    _groupIdController.clear();
    _passwordController.clear();
    _mobileNumberController.clear();
    _confirmPasswordController.clear();

  }
  @override
  Widget build(BuildContext context) {
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
                      height: 120.0,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                  SizedBox(
                    height: 48.0,
                  ),
                  //mail id
                  TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Enter Your Email'
                      )
                  ),// for email
                  SizedBox(
                    height: 8.0,
                  ),

                  //enter username
                  TextField(
                      textAlign: TextAlign.center,
                      controller: _nameController,
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Enter Your full name'
                      )
                  ),//name

                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                      textAlign: TextAlign.center,
                      controller: _mobileNumberController,
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Enter Your Mobile Number'
                      )
                  ),// for mobile number
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                      textAlign: TextAlign.center,
                      controller: _batchController,
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Enter Your Batch(Y-XX)'
                      )
                  ),// for batch

                  SizedBox(
                    height: 8.0,
                  ),
                  // group ID
                  TextField(
                      textAlign: TextAlign.center,
                      controller: _groupIdController,
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Enter Your Group ID'
                      )
                  ),// for group id
                  SizedBox(
                    height: 8.0,
                  ),
                  //password
                  TextField(
                      textAlign: TextAlign.center,
                      obscureText: true,
                      controller: _passwordController,
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Enter Your Password'
                      )
                  ),// for password
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                      textAlign: TextAlign.center,
                      obscureText: true,
                      controller: _confirmPasswordController,
                      decoration: kTextFieldDecoration.copyWith(
                          hintText: 'Confirm Your Password'
                      )
                  ),//confirm password
                  const SizedBox(
                    height: 24.0,
                  ),

                  RoundedButton(
                    color: Colors.blueAccent,
                    onPressed: signUp,

                    text: 'Register',
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

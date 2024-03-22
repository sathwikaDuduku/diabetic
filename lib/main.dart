import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:diabetic/first.dart';
import 'package:diabetic/home.dart';
import 'package:diabetic/login.dart';
import 'package:diabetic/register.dart';
import 'package:diabetic/otp_verification.dart';
import 'package:diabetic/otp_verify_email.dart';
import 'package:diabetic/path.dart';
import 'package:diabetic/retino.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: 'first',
    routes: {
      'first': (context) => MyFirst(),
      'register': (context) => SignupPage(),
      'login': (context) => MyLogin(),
      'home': (context) => DiabetesPredictionPage(),
      'otp_verification' : (context) => VerifyOTPPage(),
      'otp_verify_email': (context) => VerifyOTPEmailPage(),
      'path': (context) => HomeScreen(),
      'retino': (context) => ImageUploadPage(),




    },
  ));
}
import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/auth/login_view_modal.dart';
import 'package:thaartransport/auth/register_view_modal.dart';
import 'package:thaartransport/screens/kyc/kycverfied.dart';
import 'package:thaartransport/services/auth_service.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/services/post_service.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/widget/indicatiors.dart';

import 'package:thaartransport/services/services.dart';

import '../utils/firebase.dart';

class UserRegistrationOtp extends StatefulWidget {
  final String name;
  final String companyName;
  final String phoneNumber;
  final String emailId;
  final String city;
  final String verificationOtp;
  final int timer;
  final String userType;
  UserRegistrationOtp(this.name, this.companyName, this.phoneNumber,
      this.emailId, this.city, this.verificationOtp, this.timer, this.userType);
  @override
  State<UserRegistrationOtp> createState() => _UserRegistrationOtpState();
}

class _UserRegistrationOtpState extends State<UserRegistrationOtp> {
  late String _verificationCode;
  final TextEditingController otpController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool showLoading = false;
  final FocusNode _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: Constants.white,
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: Constants.textfieldborder,
    ),
  );

  @override
  void initState() {
    super.initState();
    counter = widget.timer;
    startTimer();
  }

  bool resend = true;
  int counter = 0;
  late Timer _timer;

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (counter > 0) {
        if (mounted) {
          setState(() {
            counter--;
          });
        }
      } else {
        _timer.cancel();
        if (mounted) {
          setState(() {
            resend = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final text = isOnline ? "Internet" : "No Internet";
    final color = isOnline ? Colors.green : Colors.red;
    RegisterViewModel registerViewModel =
        Provider.of<RegisterViewModel>(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Thaar-Transport",
          style: GoogleFonts.oswald(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, right: 15, top: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
                child: Text(
              "Enter the OTP sent to you at",
              style: GoogleFonts.roboto(fontSize: 20),
            )),
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.phoneNumber,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(
              height: 20,
            ),
            PinPut(
              fieldsCount: 6,
              textStyle:
                  TextStyle(fontSize: 25.0, color: Constants.btntextactive),
              eachFieldWidth: 40.0,
              eachFieldHeight: 55.0,
              focusNode: _pinPutFocusNode,
              controller: otpController,
              submittedFieldDecoration: pinPutDecoration,
              selectedFieldDecoration: pinPutDecoration,
              followingFieldDecoration: pinPutDecoration,
              pinAnimationType: PinAnimationType.fade,
              onChanged: registerViewModel.onChangedOtp,
            ),
            const SizedBox(
              height: 25,
            ),
            RaisedButton(
                color: registerViewModel.statusotp
                    ? Color(0XFF142438)
                    : Constants.btninactive,
                textColor: registerViewModel.statusotp
                    ? Constants.btntextinactive
                    : Constants.btntextactive,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onPressed: () async {
                  !isOnline
                      ? showSimpleNotification(
                          Text(
                            text,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                          slideDismiss: true,
                          background: color,
                        )
                      : registerViewModel.statusotp
                          ? Verify(registerViewModel)
                          : null;
                },
                child: Container(
                    width: width,
                    height: 48,
                    alignment: Alignment.center,
                    child: showLoading
                        ? circularProgress(context)
                        : const Text(
                            "Verify Now",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ))),
            const SizedBox(
              height: 25,
            ),
            Container(
              alignment: Alignment.center,
              child: Text(
                "Did't get any OTP??",
                style: GoogleFonts.roboto(fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      resend ? null : resendOTP();
                    },
                    child: Text(
                      "Resend OTP",
                      style: TextStyle(
                          fontSize: 17,
                          color: resend ? Colors.brown[100] : Colors.red),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text("00:${counter.toString()}")
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  resendOTP() async {
    _auth.verifyPhoneNumber(
      phoneNumber: "+91" + widget.phoneNumber.toString().trim(),
      timeout: Duration(seconds: counter),
      verificationCompleted: (phoneAuthCredential) async {},
      verificationFailed: (verificationFailed) async {
        ScaffoldMessenger.of(context).showSnackBar((const SnackBar(
            content: Text(
          "Please Enter the correct number",
          style: TextStyle(fontSize: 16),
        ))));
      },
      codeSent: (verificationId, resendingToken) async {},
      codeAutoRetrievalTimeout: (verificationId) async {},
    );
    if (mounted) {
      setState(() {
        resend = true;
        counter = 30;
        startTimer();
      });
    }
  }

  Verify(RegisterViewModel registerViewModel) async {
    PhoneAuthCredential phoneAuthCredential =
        await PhoneAuthProvider.credential(
            verificationId: widget.verificationOtp.toString(),
            smsCode: otpController.text);

    signInWithPhoneAuthCredential(phoneAuthCredential, registerViewModel);
  }

  void signInWithPhoneAuthCredential(PhoneAuthCredential phoneAuthCredential,
      RegisterViewModel registerViewModel) async {
    if (mounted) {
      setState(() {
        showLoading = true;
      });
    }

    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      if (mounted) {
        setState(() {
          showLoading = true;
        });
      }
      if (authCredential.user != null) {
        CheckDataExit(registerViewModel);
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter the correct otp number',
              style: TextStyle(fontSize: 16))));
      if (mounted) {
        setState(() {
          showLoading = false;
        });
      }
    }
  }

  CheckDataExit(RegisterViewModel registerViewModel) async {
    var data = await usersRef.doc(UserService().currentUid()).get();
    if (data.exists) {
      if (mounted) {
        setState(() {
          showLoading = true;
        });
      }
      print("exist");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        "You already registered!!",
        style: TextStyle(fontSize: 18),
      )));
    } else {
      AuthService().saveUserToFirestore(context, widget.name,
          widget.companyName, widget.emailId, widget.city, widget.userType);
      AuthService().Firebasetoken();
      if (mounted) {
        setState(() {
          showLoading = false;
        });
        registerViewModel.statusotp = false;
      }
    }
  }
}

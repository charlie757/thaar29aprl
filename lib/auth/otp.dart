// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/homepage.dart';
import 'package:thaartransport/NEW/truckpostuser/truckhomepage.dart';
import 'package:lottie/lottie.dart';
import 'package:thaartransport/auth/login_view_modal.dart';
import 'package:thaartransport/services/auth_service.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';
import '../NEW/currentuserprovider.dart';
import '../NEW/postloaduser/shipperhomepage.dart';
import 'login.dart';

class OTPScreen extends StatefulWidget {
  final String verificationOtp;
  final String phone;
  final int timer;
  const OTPScreen(this.verificationOtp, this.phone, this.timer);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  late String _verificationCode;
  final TextEditingController otpController = TextEditingController();

  bool showLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  String usertype = '';

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final text = isOnline ? "Internet" : "No Internet";
    final color = isOnline ? Colors.green : Colors.red;
    LoginViewModal loginViewModal = Provider.of<LoginViewModal>(context);
    CurrentUserProvider currentUserProvider =
        Provider.of<CurrentUserProvider>(context);
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return LoadingOverlay(
        isLoading: showLoading,
        progressIndicator: CircularProgressIndicator(
            strokeWidth: 4,
            color: Colors.blueGrey[900],
            backgroundColor: Colors.blue),
        opacity: 0.2,
        color: Colors.white,
        child: Scaffold(
            key: _scaffoldkey,
            appBar: AppBar(
              elevation: 0.0,
              title: Text(
                "Thaar-Transport",
                style: GoogleFonts.charm(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20),
              ),
              backgroundColor: Colors.white,
              centerTitle: true,
            ),
            body: Padding(
                padding: const EdgeInsets.only(
                    top: 10, left: 10, right: 5, bottom: 10),
                child: Container(
                    height: height,
                    child: SingleChildScrollView(
                        reverse: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Lottie.asset('assets/60247-mobile-otp.json'),
                            SizedBox(
                              height: height * 0.03,
                            ),
                            Text(
                              "Enter the OTP sent to you at",
                              style: GoogleFonts.roboto(fontSize: 20),
                            ),
                            SizedBox(height: height * 0.01),
                            Row(
                              children: [
                                Text(
                                  widget.phone,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                InkWell(
                                  onTap: () {
                                    // saveNumber();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EnterNumber()));
                                  },
                                  child: CircleAvatar(
                                      backgroundColor: Constants.thaartheme,
                                      radius: 15,
                                      child: const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 20,
                                      )),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: height * 0.04,
                            ),
                            PinPut(
                              fieldsCount: 6,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              textStyle: TextStyle(
                                  fontSize: 25.0,
                                  color: Constants.btntextactive),
                              eachFieldWidth: 40.0,
                              eachFieldHeight: 55.0,
                              focusNode: _pinPutFocusNode,
                              controller: otpController,
                              submittedFieldDecoration: pinPutDecoration,
                              selectedFieldDecoration: pinPutDecoration,
                              followingFieldDecoration: pinPutDecoration,
                              pinAnimationType: PinAnimationType.fade,
                              onChanged: loginViewModal.onChangedOtp,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    resend ? null : resendOTP();
                                  },
                                  child: Text(
                                    "Resend OTP",
                                    style: TextStyle(
                                        fontSize: 17,
                                        color: resend == false
                                            ? Colors.red
                                            : Colors.brown[100]),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  resend ? "00:${counter.toString()}" : '',
                                  style: GoogleFonts.oswald(fontSize: 16),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  resend ? "Sec" : '',
                                  style: GoogleFonts.oswald(fontSize: 16),
                                )
                              ],
                            ),
                            SizedBox(
                              height: height * 0.09,
                            ),
                            RaisedButton(
                                color: loginViewModal.statusotp
                                    ? const Color(0XFF142438)
                                    : Constants.btninactive,
                                textColor: loginViewModal.statusotp
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
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          slideDismiss: true,
                                          background: color,
                                        )
                                      : loginViewModal.statusotp
                                          ? Verify(loginViewModal)
                                          : null;
                                },
                                child: Container(
                                    width: width,
                                    height: 48,
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "Verify Now",
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.white),
                                    )))
                          ],
                        ))))));
  }

  Verify(LoginViewModal loginViewModal) async {
    PhoneAuthCredential phoneAuthCredential =
        await PhoneAuthProvider.credential(
            verificationId: widget.verificationOtp.toString(),
            smsCode: otpController.text);
    // currentuser();
    signInWithPhoneAuthCredential(phoneAuthCredential, loginViewModal);
  }

  resendOTP() async {
    _auth.verifyPhoneNumber(
      phoneNumber: "+91" + widget.phone.toString().trim(),
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

  CheckDataExit(LoginViewModal loginViewModal) async {
    if (mounted) {
      setState(() {
        showLoading = true;
      });

      await usersRef.doc(UserService().currentUid()).update({
        "id": UserService().currentUid(),
        "usernumber": UserService().currentNumber(),
        "lastsigntime": Timestamp.now().toDate(),
        'loginstatus': "login",
      });
      AuthService().Firebasetoken();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));

      // print("userType${currentuserprovider.usertype}");
      if (mounted) {
        setState(() {
          showLoading = false;
        });
        loginViewModal.statusotp = false;
      }
    }
  }

  void signInWithPhoneAuthCredential(PhoneAuthCredential phoneAuthCredential,
      LoginViewModal loginViewModal) async {
    setState(() {
      showLoading = true;
    });

    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        showLoading = true;
      });

      if (authCredential.user != null) {
        CheckDataExit(loginViewModal);
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter the correct otp number',
              style: TextStyle(fontSize: 16))));
      setState(() {
        showLoading = false;
      });
    }
  }
}

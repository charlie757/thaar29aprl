// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/homepage.dart';
import 'package:thaartransport/auth/login_view_modal.dart';
import 'package:thaartransport/services/auth_service.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';
import '../NEW/currentuserprovider.dart';

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
      opacity: 0.1,
      isLoading: showLoading,
      child: Scaffold(
          key: _scaffoldkey,
          appBar: AppBar(
            elevation: 0.0,
            leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back_sharp,
                color: Colors.black,
              ),
            ),
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
                  top: 10, left: 30, right: 30, bottom: 10),
              child: Container(
                  height: height,
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Lottie.asset('assets/60247-mobile-otp.json'),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        "Verification",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),

                      Text(
                        "Enter the OTP sent to the number",
                        style: GoogleFonts.roboto(
                            fontSize: 16, fontWeight: FontWeight.w300),
                      ),
                      SizedBox(height: height * 0.02),
                      Text(
                        widget.phone,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      PinCodeTextField(
                        controller: otpController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        // obscureText: true,
                        // obscuringCharacter: '●',
                        pinTheme: PinTheme(
                          // shape: PinCodeFieldShape.circle,
                          // borderRadius: BorderRadius.circular(
                          //   25,
                          // ),
                          activeColor: Colors.black,
                          disabledColor: Colors.black,
                          selectedColor: Colors.black,
                          inactiveColor: Colors.black,
                          fieldHeight: 50,
                          fieldWidth: 40,
                          activeFillColor: Colors.white,
                        ),

                        length: 6,
                        appContext: context,
                        keyboardType: TextInputType.number,
                        pastedTextStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: loginViewModal.onChangedOtp,
                        onCompleted: (result) {
                          if (result != null) {
                            // _callAccessPin(result);
                            Verify(loginViewModal);
                          }

                          // Your logic with code
                          print(result);
                          //pin=result;

                          print(result);
                        },
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              resend ? null : resendOTP();
                            },
                            child: Text(
                              "RESEND OTP",
                              style: TextStyle(
                                  fontSize: 17,
                                  color: resend == false
                                      ? Constants.alert
                                      : Colors.brown[100]),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            resend ? "00:${counter.toString()}" : '',
                            style: GoogleFonts.oswald(
                                fontSize: 16, color: Constants.alert),
                          ),
                          // const SizedBox(
                          //   width: 5,
                          // ),
                          // Text(
                          //   resend ? "Sec" : '',
                          //   style: GoogleFonts.oswald(fontSize: 16),
                          // )
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
                                ? ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        backgroundColor: Constants.kYellowColor,
                                        content: const Text(
                                          "No Internet",
                                          style: TextStyle(fontSize: 16),
                                        )))
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
                  ))))),
    );
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
        Fluttertoast.showToast(
            msg: "Invalid phone number",
            backgroundColor: Colors.red,
            textColor: Colors.white);
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

        EasyLoading.show();
      });

      await usersRef.doc(UserService().currentUid()).update({
        "id": UserService().currentUid(),
        "usernumber": UserService().currentNumber(),
        "lastsigntime": Timestamp.now().toDate(),
        'loginstatus': "login",
      });
      AuthService().Firebasetoken();

//       if(widget.phone== '9999999999'){

// usersRef
//         .where('usernumber', isEqualTo: "+91${widget.phone}")
//         .get()
//         .then((value) {

//       value.docs.length == 0
//           ? Navigator

//       }
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomePage()));

      // print("userType${currentuserprovider.usertype}");
      if (mounted) {
        setState(() {
          showLoading = false;

          EasyLoading.dismiss();
        });
        loginViewModal.statusotp = false;
      }
    }
  }

  void signInWithPhoneAuthCredential(PhoneAuthCredential phoneAuthCredential,
      LoginViewModal loginViewModal) async {
    setState(() {
      showLoading = true;
      EasyLoading.show();
    });

    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        showLoading = true;
        EasyLoading.show();
      });

      if (authCredential.user != null) {
        CheckDataExit(loginViewModal);
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      Fluttertoast.showToast(
          msg: "Invalid OTP",
          backgroundColor: Colors.red,
          textColor: Colors.white);

      setState(() {
        showLoading = false;
        EasyLoading.dismiss();
      });
    }
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
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
    return LoadingOverlay(
      isLoading: showLoading,
      opacity: 0.1,
      child: Scaffold(
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
          centerTitle: true,
          title: Text(
            "Thaar-Transport",
            style: GoogleFonts.charm(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30, top: 30),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  widget.phoneNumber,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(
                  height: 30,
                ),
                PinCodeTextField(
                  controller: otpController,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  pinTheme: PinTheme(
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
                  onChanged: registerViewModel.onChangedOtp,
                  onCompleted: (result) {
                    if (result != null) {
                      Verify(registerViewModel);
                    }

                    print(result);

                    print(result);
                  },
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
                          ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              backgroundColor: Constants.kYellowColor,
                              content: const Text(
                                "No Internet",
                                style: TextStyle(fontSize: 16),
                              )))
                          : registerViewModel.statusotp
                              ? Verify(registerViewModel)
                              : null;
                    },
                    child: Container(
                        width: width,
                        height: 48,
                        alignment: Alignment.center,
                        child: const Text(
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
                      Text(
                        resend ? "00:${counter.toString()}" : '',
                        style: GoogleFonts.oswald(
                            fontSize: 16, color: Constants.alert),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
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
        EasyLoading.show();
        showLoading = true;
      });
    }

    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      if (mounted) {
        setState(() {
          EasyLoading.show();
          showLoading = true;
        });
      }
      if (authCredential.user != null) {
        CheckDataExit(registerViewModel);
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      Fluttertoast.showToast(
          msg: 'Invalid OTP',
          backgroundColor: Colors.red,
          textColor: Colors.white);
      if (mounted) {
        setState(() {
          EasyLoading.dismiss();
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
          EasyLoading.show();
        });
      }
      print("exist");
      Fluttertoast.showToast(
          msg: "You already registered",
          backgroundColor: Colors.green,
          textColor: Colors.white);
    } else {
      AuthService().saveUserToFirestore(context, widget.name,
          widget.companyName, widget.emailId, widget.city, widget.userType);
      AuthService().Firebasetoken();
      registerViewModel.clearController();
      if (mounted) {
        setState(() {
          showLoading = false;
          EasyLoading.dismiss();
        });
        registerViewModel.statusotp = false;
      }
    }
  }
}

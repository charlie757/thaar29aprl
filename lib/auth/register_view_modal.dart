import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:thaartransport/auth/userregistrationotp.dart';
import 'package:thaartransport/services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AuthService auth = AuthService();

  late String verificationId;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  int timer = 30;

  bool isLoading = false;
  File? image;
  final city = TextEditingController();
  final name = TextEditingController();
  final companyName = TextEditingController();
  final email = TextEditingController();
  final phoneNumber = TextEditingController();

  bool statusotp = false;
  int charLength = 0;

  clearController() {
    name.clear();
    companyName.clear();
    email.clear();
    phoneNumber.clear();
    city.clear();
  }

  onChangedOtp(String value) {
    charLength = value.length;
    notifyListeners();
    if (charLength == 6) {
      statusotp = true;
      notifyListeners();
    } else {
      statusotp = false;
      notifyListeners();
    }
  }
  // setName(val) {
  //   username = val;
  //   notifyListeners();
  // }

  login(BuildContext context, String userType) async {
    isLoading = true;
    EasyLoading.show();
    notifyListeners();
    await _auth.verifyPhoneNumber(
      phoneNumber: "+91" + phoneNumber.text.toString().trim(),
      timeout: Duration(seconds: timer),
      verificationCompleted: (phoneAuthCredential) async {
        isLoading = false;
        notifyListeners();
      },
      verificationFailed: (verificationFailed) async {
        Fluttertoast.showToast(
            msg: "Invalid phone number",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        isLoading = false;

        EasyLoading.dismiss();
        notifyListeners();
      },
      codeSent: (verificationId, resendingToken) async {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserRegistrationOtp(
                    name.text,
                    companyName.text,
                    phoneNumber.text,
                    email.text,
                    city.text,
                    verificationId,
                    timer,
                    userType)));
        this.verificationId = verificationId;
        isLoading = false;

        EasyLoading.dismiss();
        notifyListeners();
      },
      codeAutoRetrievalTimeout: (verificationId) async {},
    );
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}

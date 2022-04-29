import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:thaartransport/auth/otp.dart';
import 'package:thaartransport/services/auth_service.dart';
import 'package:thaartransport/utils/firebase.dart';

class LoginViewModal extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  AuthService auth = AuthService();
  TextEditingController phoneController = TextEditingController();

  bool showDialogBox = false;

  late String verificationId;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool status = false;

  bool statusotp = false;
  int charLength = 0;
  int numberlimit = 10;
  int otplimit = 6;

  int timer = 10;
  onChanged(String value) {
    charLength = value.length;
    notifyListeners();
    if (charLength == 10) {
      status = true;
      notifyListeners();
    } else {
      status = false;
      notifyListeners();
    }
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

  void dispose() {
    // notifyListeners();
    super.dispose();
    statusotp = false;
    notifyListeners();
  }

  numbererror() {
    Fluttertoast.showToast(
        msg: "Enter Valid Numner ",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    notifyListeners();
  }

  List userDocs = [];
  checknumberexit(BuildContext context) async {
    await usersRef
        .where('usernumber', isEqualTo: "+91${phoneController.text}")
        .get()
        .then((value) {
      userDocs = value.docs;
      userDocs.length == 0
          ? ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "You are not registered",
                style: TextStyle(fontSize: 16),
              )))
          : login(context);
    });
  }

  login(BuildContext context) async {
    showDialogBox = true;

    notifyListeners();
    await _auth.verifyPhoneNumber(
      phoneNumber: "+91" + phoneController.text.toString().trim(),
      timeout: Duration(seconds: timer),
      verificationCompleted: (phoneAuthCredential) async {
        showDialogBox = false;
        notifyListeners();
      },
      verificationFailed: (verificationFailed) async {
        ScaffoldMessenger.of(context).showSnackBar((const SnackBar(
            content: Text(
          "Please check your number",
          style: TextStyle(fontSize: 16),
        ))));
        showDialogBox = false;
        notifyListeners();
      },
      codeSent: (verificationId, resendingToken) async {
        Get.to(OTPScreen(verificationId, phoneController.text, timer),
            fullscreenDialog: true);
        Navigator.push(
          context,
          PageRouteBuilder(
            fullscreenDialog: true,
            pageBuilder: (c, a1, a2) =>
                OTPScreen(verificationId, phoneController.text, timer),
            transitionsBuilder: (c, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
        this.verificationId = verificationId;
        showDialogBox = false;
        notifyListeners();
      },
      codeAutoRetrievalTimeout: (verificationId) async {},
    );
  }
}

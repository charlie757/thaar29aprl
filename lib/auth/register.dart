import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/auth/register_view_modal.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/widget/inputtextfield.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class UserRegistration extends StatefulWidget {
  final String userPreference;
  final String address;
  UserRegistration(this.userPreference, this.address);

  @override
  _UserRegistrationState createState() => _UserRegistrationState();
}

class _UserRegistrationState extends State<UserRegistration> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  int timer = 30;
  late String verificationId;
  @override
  void initState() {
    super.initState();
  }

  List<DocumentSnapshot> docs = [];
  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final text = isOnline ? "Internet" : "No Internet";
    final color = isOnline ? Colors.green : Colors.red;
    RegisterViewModel registerViewModel =
        Provider.of<RegisterViewModel>(context);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    registerViewModel.city.text = widget.address;
    return WillPopScope(
      onWillPop: () async {
        registerViewModel.clearController();
        return true;
      },
      child: LoadingOverlay(
        isLoading: registerViewModel.isLoading,
        child: Scaffold(
            appBar: AppBar(
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  registerViewModel.clearController();
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: Text(
                "Thaar-Transport",
                style: GoogleFonts.charm(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 20),
              ),
            ),
            body: Padding(
                padding: const EdgeInsets.only(
                    top: 35, left: 20, right: 20, bottom: 10),
                child: SingleChildScrollView(
                    physics: const ScrollPhysics(),
                    child: _registrationForm(text, color, isOnline)))),
      ),
    );
  }

  Widget _registrationForm(final text, final color, bool isOnline) {
    RegisterViewModel registerViewModel =
        Provider.of<RegisterViewModel>(context);
    Size size = MediaQuery.of(context).size;
    return Form(
        key: formKey,
        child: Column(
          children: [
            inputTextField(registerViewModel.name, 'Enter Your Name',
                'Your Name', false, TextInputType.name, [], () {}, (val) {
              // if (val!.isEmpty) {
              //   return 'Please Enter Your Name';
              // }
              // return null;
            }),
            const SizedBox(
              height: 20,
            ),
            widget.userPreference == "Transporator"
                ? inputTextField(
                    registerViewModel.companyName,
                    'Enter Your Comapny Name',
                    'Your Company Name',
                    false,
                    TextInputType.name,
                    [],
                    () {}, (val) {
                    // if (val!.isEmpty) {
                    //   return 'Enter the company name';
                    // }
                    return null;
                  })
                : Container(),
            widget.userPreference == "Transporator"
                ? const SizedBox(
                    height: 20,
                  )
                : const SizedBox(),
            numberTextField(),
            const SizedBox(
              height: 20,
            ),
            inputTextField(
                registerViewModel.email,
                'Enter Your Email Address',
                'Your Email',
                false,
                TextInputType.emailAddress,
                [],
                () {}, (val) {
              // if (val!.isEmpty) {
              //   return 'Enter your email';
              // } else if (val.isValidEmail()) {
              //   return null;
              // }
              // return 'Enter your correct email id';
            }),
            const SizedBox(
              height: 20,
            ),
            inputTextField(
                registerViewModel.city,
                'Enter Your location',
                'Your location',
                true,
                TextInputType.streetAddress,
                [],
                () {}, (val) {
              // if (val!.isEmpty) {
              //   return 'Enter your location';
              // }
              return null;
            }),
            const SizedBox(
              height: 100,
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: 48,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  color: Color(0XFF142438),
                  textColor: Constants.btntextinactive,
                  onPressed: () async {
                    !isOnline
                        ? ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Constants.kYellowColor,
                            content: const Text(
                              "No Internet",
                              style: TextStyle(fontSize: 16),
                            )))
                        : widget.userPreference == "Transporator"
                            ? calltransFunction(registerViewModel)
                            : callshipperFunction(registerViewModel);
                  },
                  child: const Text(
                    "SUBMIT",
                    style: TextStyle(fontSize: 18),
                  ),
                )),
          ],
        ));
  }

  calltransFunction(RegisterViewModel registerViewModel) async {
    String patttern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(patttern);

    final isValid = formKey.currentState!.validate();
    if (registerViewModel.name.text.isEmpty) {
      EasyLoading.showToast("Enter your name");
    } else if (registerViewModel.companyName.text.isEmpty) {
      EasyLoading.showToast("Enter your company name");
    } else if (registerViewModel.phoneNumber.text.isEmpty ||
        registerViewModel.phoneNumber.text.length < 10) {
      EasyLoading.showToast("Enter your phone number");
    } else if (registerViewModel.email.value.text.isEmpty ||
        !regExp.hasMatch(registerViewModel.email.text)) {
      EasyLoading.showToast("Enter your email address");
    } else if (registerViewModel.city.text.isEmpty) {
      EasyLoading.showToast("Enter your location");
    } else {
      final result = await usersRef
          .where('usernumber',
              isEqualTo: '+91${registerViewModel.phoneNumber.text}')
          .get()
          .then((value) {
        docs = value.docs;
        print(docs.length);
        if (docs.length == 1) {
          ScaffoldMessenger.of(context).showSnackBar((const SnackBar(
              content: Text(
            "Already registered",
            style: TextStyle(fontSize: 16),
          ))));
          print("exist");
        } else {
          registerViewModel.login(context, widget.userPreference);
        }
      });

      print("Added");
    }
  }

  callshipperFunction(RegisterViewModel registerViewModel) async {
    String patttern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(patttern);

    final isValid = formKey.currentState!.validate();
    if (registerViewModel.name.text.isEmpty) {
      EasyLoading.showToast("Enter your name");
    } else if (registerViewModel.phoneNumber.text.isEmpty ||
        registerViewModel.phoneNumber.text.length < 10) {
      EasyLoading.showToast("Enter your phone number");
    } else if (registerViewModel.email.value.text.isEmpty ||
        !regExp.hasMatch(registerViewModel.email.text)) {
      EasyLoading.showToast("Enter your email address");
    } else if (registerViewModel.city.text.isEmpty) {
      EasyLoading.showToast("Enter your location");
    } else {
      final result = await usersRef
          .where('usernumber',
              isEqualTo: '+91${registerViewModel.phoneNumber.text}')
          .get()
          .then((value) {
        docs = value.docs;
        print(docs.length);
        if (docs.length == 1) {
          ScaffoldMessenger.of(context).showSnackBar((const SnackBar(
              content: Text(
            "Already registered",
            style: TextStyle(fontSize: 16),
          ))));
          print("exist");
        } else {
          registerViewModel.login(context, widget.userPreference);
        }
      });

      print("Added");
    }
  }

  Widget numberTextField() {
    RegisterViewModel registerViewModel =
        Provider.of<RegisterViewModel>(context);
    return TextFormField(
        controller: registerViewModel.phoneNumber,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10),
        ],
        decoration: InputDecoration(
            labelText: 'Your Number',
            isDense: true,
            hintText: "Enter your number",
            labelStyle: TextStyle(color: Colors.black),
            focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Constants.textfieldborder, width: 1)),
            border: OutlineInputBorder(
                borderSide:
                    BorderSide(width: 1, color: Constants.textfieldborder))),
        validator: (val) {
          // if (val!.isEmpty) {
          //   return 'Enter your phone number';
          // } else if (val.length < 10) {
          //   return "Please enter 10 number";
          // }
          // return null;
        });
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}

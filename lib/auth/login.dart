// ignore_for_file: deprecated_member_use, sized_box_for_whitespace, avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:is_first_run/is_first_run.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/auth/login_view_modal.dart';
import 'package:thaartransport/auth/userpreference.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/utils/constants.dart';

class EnterNumber extends StatefulWidget {
  @override
  _EnterNumberState createState() => _EnterNumberState();
}

class _EnterNumberState extends State<EnterNumber> {
  bool isLoading = false;

  Alignment childAlignment = Alignment.center;

  @override
  void initState() {
    super.initState();
    checkFirstRun();
  }

  checkFirstRun() async {
    firstRun = await IsFirstRun.isFirstRun();
    print(firstRun);
  }

  bool firstRun = false;
  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final text = isOnline ? "Internet" : "No Internet";
    final color = isOnline ? Colors.green : Colors.red;

    LoginViewModal viewModel = Provider.of<LoginViewModal>(context);

    return WillPopScope(
      onWillPop: () async {
        exit(0);
      },
      child: LoadingOverlay(
        isLoading: viewModel.showDialogBox,
        opacity: 0.1,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            leading: GestureDetector(
                onTap: () {
                  firstRun ? Navigator.pop(context) : null;
                },
                child: const Icon(
                  Icons.arrow_back_sharp,
                  color: Colors.black,
                )),
            title: Text(
              "Thaar-Transport",
              style: GoogleFonts.charm(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20),
            ),
            backgroundColor: Colors.white24,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
              reverse: true,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 30, right: 30, top: 30, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image.asset(
                    //   'assets/images/enternumber.jpg',
                    // ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 45,
                    ),
                    const Text(
                      'Enter your mobile number to\nLogin',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(
                      height: 75,
                    ),

                    TextFormField(
                      focusNode: FocusNode(),
                      readOnly: viewModel.showDialogBox == false ? false : true,
                      autofocus: true,
                      controller: viewModel.phoneController,
                      onChanged: viewModel.onChanged,
                      cursorHeight: 20,
                      cursorColor: Constants.cursorColor,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          isDense: true,
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            width: 1,
                            color: Constants.textfieldborder,
                          )),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: 1, color: Constants.textfieldborder)),
                          labelText: "Phone Number",
                          labelStyle: const TextStyle(color: Colors.black),
                          hintText: "Phone Number",
                          hintStyle: const TextStyle(color: Colors.black)),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: 48,
                        // padding: const EdgeInsets.only(left: 30, right: 30),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              primary:
                                  //  viewModel.status
                                  //     ?
                                  Constants.maincolor,
                              // : Constants.btninactive,
                              textStyle: TextStyle(
                                  color:
                                      // viewModel.status
                                      //     ?
                                      Constants.btntextinactive
                                  // : Constants.btntextactive,
                                  )),
                          onPressed: () async {
                            !isOnline
                                ? ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        backgroundColor: Constants.kYellowColor,
                                        content: const Text(
                                          "No Internet",
                                          style: TextStyle(fontSize: 16),
                                        )))
                                : print('$num');
                            if (viewModel.phoneController.text.length <
                                viewModel.numberlimit) {
                              Fluttertoast.showToast(
                                  msg: "Enter your number", fontSize: 16);
                            } else {
                              viewModel.checknumberexit(context);
                            }
                          },
                          child: const Text(
                            "CONTINUE",
                            style: TextStyle(fontSize: 18),
                          ),
                        )),
                    const SizedBox(
                      height: 40,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UserPreference()));
                              },
                              child: Text(
                                "Register",
                                style: TextStyle(
                                    color: Constants.kYellowColor,
                                    fontSize: 22),
                              ))
                        ],
                      ),
                    )
                  ],
                ),
              )),
          // bottomNavigationBar: Container(
          //   height: 60,
          //   alignment: Alignment.center,
          //   child: Column(
          //     mainAxisAlignment: MainAxisAlignment.center,
          //     children: [
          //       const Text(
          //         "Don't have an account? ",
          //         style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          //       ),
          //       const SizedBox(
          //         height: 5,
          //       ),
          //       InkWell(
          //           onTap: () {
          //             Navigator.push(
          //                 context,
          //                 MaterialPageRoute(
          //                     builder: (context) => UserPreference()));
          //           },
          //           child: Text(
          //             "Register",
          //             style: TextStyle(
          //                 color: Constants.kYellowColor, fontSize: 22),
          //           ))
          //     ],
          //   ),
          // ),
        ),
      ),
    );
  }

  // void showFlashSnackBar() async {
  //   Flushbar(
  //     icon: const Icon(Icons.network_check),
  //     flushbarPosition: FlushbarPosition.TOP,
  //     isDismissible: true,
  //     title: 'No Connection',
  //   ).show(context);
  // }
}

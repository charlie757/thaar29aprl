// ignore_for_file: deprecated_member_use, sized_box_for_whitespace, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/auth/login_view_modal.dart';
import 'package:loading_overlay/loading_overlay.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final text = isOnline ? "Internet" : "No Internet";
    final color = isOnline ? Colors.green : Colors.red;

    LoginViewModal viewModel = Provider.of<LoginViewModal>(context);

    return LoadingOverlay(
      isLoading: viewModel.showDialogBox,
      progressIndicator: CircularProgressIndicator(
          strokeWidth: 4,
          color: Colors.blueGrey[900],
          backgroundColor: Colors.blue),
      opacity: 0.2,
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
          title: Text(
            "Thaar-Transport",
            style: GoogleFonts.charm(
                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: AnimatedPadding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
            duration: const Duration(milliseconds: 200),
            curve: Curves.decelerate,
            child: AnimatedContainer(
                curve: Curves.easeInOut,
                duration: const Duration(
                  milliseconds: 200,
                ),
                // alignment: childAlignment,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/enternumber.jpg',
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Text(
                          "Get Started",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          focusNode: FocusNode(),
                          readOnly:
                              viewModel.showDialogBox == false ? false : true,
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
                                    width: 1,
                                    color: Constants.textfieldborder)),
                            hintText: "Phone Number",
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  primary: viewModel.status
                                      ? Constants.maincolor
                                      : Constants.btninactive,
                                  textStyle: TextStyle(
                                    color: viewModel.status
                                        ? Constants.btntextinactive
                                        : Constants.btntextactive,
                                  )),
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
                                    : print('$num');
                                if (viewModel.phoneController.text.length <
                                    viewModel.numberlimit) {
                                  return;
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
                          height: 25,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(fontSize: 16),
                            ),
                            InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              UserPreference()));
                                },
                                child: const Text(
                                  "Register",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 22),
                                ))
                          ],
                        ),
                      ],
                    )))),
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

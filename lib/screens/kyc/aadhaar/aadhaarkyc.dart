import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:thaartransport/screens/kyc/aadhaar/aadhaarimage.dart';
import 'package:thaartransport/screens/kyc/pannumber/kycdocuments.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/utils/validations.dart';

import '../registerkyc.dart';

class AadhaarKyc extends StatefulWidget {
  const AadhaarKyc({Key? key}) : super(key: key);

  @override
  _AadhaarKycState createState() => _AadhaarKycState();
}

class _AadhaarKycState extends State<AadhaarKyc> {
  TextEditingController AadhaarNumber = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String AadhaarFront = '';
  String AadhaarBack = '';
  bool validate = false;
  int charLength = 0;
  bool status = false;
  onChanged(String value) {
    charLength = value.length;
    if (charLength == 12) {
      status = true;
    } else {
      status = false;
    }
  }

  bool loading = false;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => RegisterKYC()));
          return true;
        },
        child: LoadingOverlay(
            isLoading: loading,
            progressIndicator: const CircularProgressIndicator(
                strokeWidth: 4,
                color: Colors.blue,
                backgroundColor: Colors.red),
            opacity: 0.2,
            color: Colors.white,
            child: Scaffold(
              appBar: AppBar(
                title: const Text("Your Documents"),
                backgroundColor: Constants.thaartheme,
                actions: [
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => KycDocuments()));
                      },
                      child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          alignment: Alignment.center,
                          child: const Text(
                            "SKIP",
                            style: TextStyle(fontSize: 18, color: Colors.green),
                          )))
                ],
              ),
              body: SingleChildScrollView(
                  child: Padding(
                      padding: const EdgeInsets.only(
                          top: 25, left: 10, right: 10, bottom: 10),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Enter aadhaar number",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            const SizedBox(
                              height: 28,
                            ),
                            TextFormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(12),
                              ],
                              controller: AadhaarNumber,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Aadhaar Number",
                                labelText: "Aadhaar number",
                                suffixIcon: status
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      )
                                    : null,
                                labelStyle:
                                    TextStyle(color: Constants.labelcolor),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  width: 1.5,
                                  color: Constants.textfieldborder,
                                )),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Constants.textfieldborder)),
                              ),
                              validator: Validations.validateAadhaarNumber,
                              onChanged: onChanged,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Align(
                              child: Column(
                                children: [
                                  FrontImage(),
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  BackImage(),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  RaisedButton(
                                      color: Constants.maincolor,
                                      textColor: Constants.btntextactive,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      onPressed: () async {
                                        FormState? form = _formKey.currentState;
                                        form!.save();
                                        if (!form.validate()) {
                                          validate = true;
                                        } else if (AadhaarFront.isEmpty &&
                                            AadhaarBack.isEmpty) {
                                          EasyLoading.showToast(
                                              'Please upload both image');
                                        } else if (AadhaarFront.isEmpty) {
                                          EasyLoading.showToast(
                                              'Please upload fornt image');
                                        } else if (AadhaarBack.isEmpty) {
                                          EasyLoading.showToast(
                                              'Please upload back image');
                                        } else {
                                          if (mounted) {
                                            setState(() {
                                              loading = true;
                                            });
                                          }
                                          await usersRef
                                              .doc(UserService().currentUid())
                                              .update({
                                            "AadhaarKyc": {
                                              "aadhaarnumber":
                                                  AadhaarNumber.text,
                                              "aadhaarfrontimg": AadhaarFront,
                                              "aadhaarbackimg": AadhaarBack,
                                            },
                                          }).catchError((e) {
                                            if (mounted) {
                                              setState(() {
                                                loading = false;
                                              });
                                            }
                                            print(e);
                                          });
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      KycDocuments()));
                                          if (mounted) {
                                            setState(() {
                                              loading = false;
                                            });
                                          }
                                        }
                                      },
                                      child: Container(
                                          width: width,
                                          height: 48,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "SUBMIT",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.white),
                                          ))),
                                ],
                              ),
                            )
                          ],
                        ),
                      ))),
            )));
  }

  Widget FrontImage() {
    return InkWell(
        child: Column(
      children: [
        AadhaarImage(onFileChanged: (imgUrl) {
          setState(() {
            this.AadhaarFront = imgUrl;
          });
        }),
        const SizedBox(
          height: 10,
        ),
        const Text("Front image"),
      ],
    ));
  }

  Widget BackImage() {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          AadhaarImage(onFileChanged: (imgUrl) {
            setState(() {
              this.AadhaarBack = imgUrl;
            });
          }),
          const SizedBox(
            height: 10,
          ),
          const Text("Back image"),
        ],
      ),
    );
  }
}

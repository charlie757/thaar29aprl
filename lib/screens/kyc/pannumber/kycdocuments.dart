import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:thaartransport/screens/kyc/aadhaar/aadhaarkyc.dart';
import 'package:thaartransport/screens/kyc/gstdoc.dart';
import 'package:thaartransport/screens/kyc/officeproof/officeproof.dart';
import 'package:thaartransport/screens/kyc/pannumber/kycrectangelimage.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/utils/validations.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:dotted_decoration/dotted_decoration.dart';

import '../registerkyc.dart';

class KycDocuments extends StatefulWidget {
  const KycDocuments({Key? key}) : super(key: key);

  @override
  _KycDocumentsState createState() => _KycDocumentsState();
}

class _KycDocumentsState extends State<KycDocuments> {
  int charLength = 0;
  int numberlimit = 10;
  final _formKey = GlobalKey<FormState>();
  bool validate = false;

  bool status = false;
  TextEditingController PANumber = TextEditingController();
  String imgUrl1 = '';
  String imgUrl2 = '';
  onChanged(String value) {
    charLength = value.length;
    if (charLength == 10) {
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
                backgroundColor: Constants.thaartheme,
                title: Text("Your Documents"),
              ),
              body: SingleChildScrollView(
                child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10, right: 10, top: 25, bottom: 10),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Enter your PAN number ",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(
                              height: 28,
                            ),
                            TextFormField(
                              controller: PANumber,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: "PAN Number",
                                labelText: "PAN Number",
                                labelStyle:
                                    TextStyle(color: Constants.labelcolor),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  width: 2.5,
                                  color: Constants.textfieldborder,
                                )),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Constants.textfieldborder)),
                              ),
                              validator: Validations.validatePANNumber,
                              onChanged: onChanged,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Align(
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    const Text(
                                      "Photo and PAN number shouble be clear",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    FrontImage(),

                                    // )),
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    BackImage(),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    RaisedButton(
                                        color: Color(0XFF142438),
                                        textColor: Constants.btntextactive,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        onPressed: () async {
                                          FormState? form =
                                              _formKey.currentState;
                                          form!.save();
                                          if (!form.validate()) {
                                            validate = true;
                                          } else if (imgUrl1.isEmpty &&
                                              imgUrl2.isEmpty) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Please select the both image');
                                          } else if (imgUrl1.isEmpty) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Please select the fornt image');
                                          } else if (imgUrl2.isEmpty) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    'Please select the back image');
                                          } else {
                                            if (mounted) {
                                              setState(() {
                                                loading = true;
                                              });
                                            }
                                            await usersRef
                                                .doc(UserService().currentUid())
                                                .update({
                                              "PANKyc": {
                                                "pannumber": PANumber.text,
                                                "panfrontimg": imgUrl1,
                                                "panbackimg": imgUrl2,
                                              },
                                            }).catchError((e) {
                                              print(e);
                                              if (mounted) {
                                                setState(() {
                                                  loading = false;
                                                });
                                              }
                                            });
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Gstdocs()));
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
                                              "SAVE & PROCEED",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ))),
                                  ],
                                )),
                          ],
                        ))),
              ),
            )));
  }

  Widget FrontImage() {
    return InkWell(
        child: Column(
      children: [
        KycRectangelImage(onFileChanged: (imgUrl) {
          setState(() {
            this.imgUrl1 = imgUrl;
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
          KycRectangelImage(onFileChanged: (imgUrl) {
            setState(() {
              this.imgUrl2 = imgUrl;
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

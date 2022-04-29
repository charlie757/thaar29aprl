import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:thaartransport/NEW/homepage.dart';
import 'package:thaartransport/screens/kyc/officeproof/images.dart';
import 'package:thaartransport/screens/kyc/registerkyc.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/validations.dart';

import '../../utils/constants.dart';
import '../../utils/firebase.dart';

class Gstdocs extends StatefulWidget {
  const Gstdocs({Key? key}) : super(key: key);

  @override
  State<Gstdocs> createState() => _GstdocsState();
}

class _GstdocsState extends State<Gstdocs> {
  TextEditingController businessName = TextEditingController();
  TextEditingController gstnumber = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String imgUrl1 = '';
  String imgUrl2 = '';
  String imgUrl3 = '';
  String imgUrl4 = '';
  bool loading = false;
  bool validate = false;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => RegisterKYC()));
        return true;
      },
      child: LoadingOverlay(
        isLoading: loading,
        progressIndicator: const CircularProgressIndicator(
            strokeWidth: 4, color: Colors.blue, backgroundColor: Colors.red),
        opacity: 0.2,
        color: Colors.white,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("GST Docs"),
            backgroundColor: Color(0XFF142438),
            actions: [
              GestureDetector(
                  onTap: () async {
                    FormState? form = _formKey.currentState;
                    form!.save();
                    if (!form.validate()) {
                      validate = true;
                    } else if (imgUrl1.isEmpty ||
                        imgUrl2.isEmpty && imgUrl3.isEmpty) {
                      Fluttertoast.showToast(msg: 'Please upload gst images');
                    } else {
                      setState(() {
                        loading = true;
                      });
                      await usersRef.doc(UserService().currentUid()).update({
                        "GstKyc": {
                          "businessname": businessName.text,
                          "gstnumber": gstnumber.text,
                          "gstimg1": imgUrl1,
                          "gstimg2": imgUrl2,
                          "gstimg3": imgUrl3,
                        },
                        "userkycstatus": "Pending"
                      }).catchError((e) {
                        print(e);
                      });
                      bottomWidget(context);
                      // await CoolAlert.show(
                      //     context: context,
                      //     type: CoolAlertType.loading,
                      //     text: 'KYC Successfully',
                      //     lottieAsset: 'assets/782-check-mark-success.json',
                      //     autoCloseDuration: Duration(seconds: 2),
                      //     animType: CoolAlertAnimType.slideInUp,
                      //     title: 'KYC documents uploaded successfully');

                      setState(() {
                        loading = false;
                      });
                    }
                  },
                  child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      alignment: Alignment.center,
                      child: const Text(
                        "SUBMIT",
                        style: TextStyle(fontSize: 18, color: Colors.green),
                      )))
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 15, right: 15, top: 10),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: businessName,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      decoration: InputDecoration(
                        hintText: "Enter your business name",
                        labelText: "Business Name",
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          width: 1.5,
                          color: Constants.textfieldborder,
                        )),
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Constants.textfieldborder)),
                      ),
                      validator: (val) {
                        if (val!.isEmpty) {
                          return "Business Name should not be Empty";
                        } else {
                          return null;
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                        textCapitalization: TextCapitalization.characters,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: gstnumber,
                        inputFormatters: [LengthLimitingTextInputFormatter(15)],
                        decoration: InputDecoration(
                          hintText: "Enter your GST Number",
                          labelText: "GST Number",
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            width: 1.5,
                            color: Constants.textfieldborder,
                          )),
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Constants.textfieldborder)),
                        ),
                        validator: Validations.validateGstNumber),
                    const SizedBox(
                      height: 20,
                    ),
                    ImageProof()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget ImageProof() {
    return Column(
      children: [
        OfficeImage(onFileChanged: (imgUrl) {
          setState(() {
            this.imgUrl1 = imgUrl;
          });
        }),
        const SizedBox(
          height: 10,
        ),
        OfficeImage(onFileChanged: (imgUrl) {
          setState(() {
            this.imgUrl2 = imgUrl;
          });
        }),
        const SizedBox(
          height: 10,
        ),
        OfficeImage(onFileChanged: (imgUrl) {
          setState(() {
            this.imgUrl3 = imgUrl;
          });
        }),
      ],
    );
  }

  bottomWidget(
    BuildContext context,
  ) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (
          context,
        ) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                color: Color(0xFF737373),
                child: Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: StatefulBuilder(builder: (context, state) {
                      return Column(
                        children: [
                          Lottie.asset('assets/782-check-mark-success.json',
                              height: 100),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "Your KYC details are under review. We will update you within 24 Hours",
                            style: TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                left: 15, right: 15, bottom: 5, top: 20),
                            width: MediaQuery.of(context).size.width,
                            height: 45,
                            child: RaisedButton(
                              textColor: Colors.white,
                              color: Color(0XFF142438),
                              onPressed: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomePage()));
                              },
                              child: Text("OK"),
                            ),
                          )
                        ],
                      );
                    })),
              ));
        });
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}

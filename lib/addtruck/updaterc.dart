// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/homepage.dart';
import 'package:thaartransport/addtruck/UserRectangelImage.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';

class UpdateRC extends StatefulWidget {
  final String lorrynumber;
  UpdateRC(this.lorrynumber);

  @override
  _UpdateRCState createState() => _UpdateRCState();
}

class _UpdateRCState extends State<UpdateRC> {
  String imgUrl1 = '';
  String imgUrl2 = '';
  String userId = user!.phoneNumber.toString();

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final text = isOnline ? "Internet" : "No Internet";
    final color = isOnline ? Colors.green : Colors.red;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Update RC"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                width: width,
                alignment: Alignment.center,
                height: 30,
                color: Colors.black12,
                child: Text.rich(
                    TextSpan(text: 'Please update RC for ', children: [
                  TextSpan(
                      text: widget.lorrynumber.toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold))
                ]))),
            SizedBox(
              height: height * 0.04,
            ),
            ForntImage(),
            SizedBox(
              height: height * 0.05,
            ),
            BackImage(),
            // Spacer(),
            Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: RaisedButton(
                  color: Constants.btnBG,
                  onPressed: () async {
                    if (imgUrl1.isEmpty && imgUrl2.isEmpty) {
                      Fluttertoast.showToast(
                          msg: 'Please select the both image');
                    } else if (imgUrl1.isEmpty) {
                      Fluttertoast.showToast(
                          msg: 'Please select the fornt image');
                    } else if (imgUrl2.isEmpty) {
                      Fluttertoast.showToast(
                          msg: 'Please select the back image');
                    } else {
                      !isOnline
                          ? showSimpleNotification(
                              Text(
                                text,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              slideDismiss: true,
                              background: color,
                            )
                          : callFunction();
                    }
                  },
                  child: Container(
                    height: 45,
                    alignment: Alignment.center,
                    width: width,
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ))
          ],
        ),
      ),
    );
  }

  callFunction() async {
    DocumentSnapshot doc =
        await usersRef.doc(firebaseAuth.currentUser!.uid).get();
    var user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
    var truckref = truckRef.doc();
    truckref.update({
      'frontimage': imgUrl1,
      'backimage': imgUrl2,
      'truckloadstatus': 'Verification Pending',
      "updaterctime": Jiffy(DateTime.now()).yMMMMEEEEdjm,
    });

    await usersRef.doc(UserService().currentUid()).update({'isTruck': true});

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  Widget ForntImage() {
    return InkWell(
      child: Column(
        children: [
          Text("Front Image"),
          SizedBox(
            height: 30,
          ),
          UserRectangelImage(onFileChanged: (imgUrl) {
            setState(() {
              this.imgUrl1 = imgUrl;
            });
          }),
        ],
      ),
    );
  }

  Widget BackImage() {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          Text("Back image"),
          const SizedBox(
            height: 30,
          ),
          UserRectangelImage(onFileChanged: (imgUrl) {
            setState(() {
              this.imgUrl2 = imgUrl;
            });
          }),
        ],
      ),
    );
  }
}

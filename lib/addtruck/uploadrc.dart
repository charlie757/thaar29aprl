// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/addtruck/UserRectangelImage.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';

class UploadRC extends StatefulWidget {
  final String sourcelocation;
  final String destinationlocation;
  final String lorrynumber;
  final String capacity;
  final String expireTruck;
  final List<String> routes;
  UploadRC(this.sourcelocation, this.destinationlocation, this.lorrynumber,
      this.capacity, this.expireTruck, this.routes);

  @override
  _UploadRCState createState() => _UploadRCState();
}

class _UploadRCState extends State<UploadRC> {
  String imgUrl1 = '';
  String imgUrl2 = '';
  String userId = user!.phoneNumber.toString();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final text = isOnline ? "Internet" : "No Internet";
    final color = isOnline ? Colors.green : Colors.red;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return LoadingOverlay(
      isLoading: isLoading,
      progressIndicator: const CircularProgressIndicator(
          strokeWidth: 4, color: Colors.blue, backgroundColor: Colors.red),
      opacity: 0.2,
      color: Colors.white,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Upload RC"),
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
                      TextSpan(text: 'Please upload RC for ', children: [
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
              Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 5),
                  child: RaisedButton(
                    color: Constants.thaartheme,
                    textColor: Colors.white,
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
                      } else {}
                    },
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      width: width,
                      child: const Text(
                        'Submit',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
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
              isLoading = true;
              this.imgUrl1 = imgUrl;
              isLoading = false;
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
              isLoading = true;
              this.imgUrl2 = imgUrl;
              isLoading = false;
            });
          }),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thaartransport/NEW/currentuserprovider.dart';
import 'package:thaartransport/addtruck/addtruck.dart';
import 'package:thaartransport/utils/constants.dart';

buildFAB(
  BuildContext context,
) {
  return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.linear,
      width: 50,
      height: 50,
      child: FloatingActionButton.extended(
          backgroundColor: Constants.floatingbtnBG,
          shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: BorderSide(color: Constants.floatingbtnBG)),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => AddTruck()));
          },
          label: SizedBox(),
          icon: const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(
              Icons.add,
              color: Colors.black,
            ),
          )));
}

buildExtendedFAB(BuildContext context, String kycstatus) {
  return Padding(
      padding: EdgeInsets.only(),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.linear,
          width: 150,
          height: 50,
          child: FloatingActionButton.extended(
              backgroundColor: Constants.floatingbtnBG,
              shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              onPressed: () {
                print(kycstatus);
                kycstatus == 'Pending'
                    ? addMoneyAlert(context)
                    : Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AddTruck()));
              },
              icon: Icon(
                Icons.add,
                color: Colors.black,
              ),
              label: const Center(
                child: Text(
                  "ADD TRUCK",
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
              ))));
}

addMoneyAlert(BuildContext context) {
  Alert(
    context: context,
    type: AlertType.info,
    title: "KYC Pending",
    desc: "You are not verified to add truck",
    buttons: [
      DialogButton(
        child: const Text(
          "Ok",
          style: TextStyle(color: Colors.white, fontSize: 17),
        ),
        onPressed: () {
          Navigator.pop(context);
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => TruckHomePage(2)));
        },
        color: Color(0XFF142438),
      )
    ],
  ).show();
}

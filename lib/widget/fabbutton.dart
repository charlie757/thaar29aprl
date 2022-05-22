import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thaartransport/NEW/currentuserprovider.dart';
import 'package:thaartransport/addtruck/addtruck.dart';
import 'package:thaartransport/screens/kyc/kycverfied.dart';
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

                kycstatus == 'Pending' || kycstatus == 'rePending'
                    ? KYCPendingAlert(
                        context,
                      )
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

KYCPendingAlert(
  BuildContext context,
) {
  showGeneralDialog(
    context: context,
    barrierLabel: "Barrier",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.5),
    transitionDuration: const Duration(milliseconds: 700),
    pageBuilder: (_, __, ___) {
      return Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Container(
                width: 330,
                margin: EdgeInsets.all(10.0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                padding: const EdgeInsets.only(
                    top: 25, left: 25, right: 25, bottom: 20),
                child: Column(
                  children: [
                    const Text(
                      "KYC Pending",
                      style:
                          TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "You are not verified to add truck",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: DialogButton(
                            child: const Text(
                              "Ok",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigator.push(context,
                              //     MaterialPageRoute(builder: (context) => TruckHomePage(2)));
                            },
                            color: Constants.alert,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: DialogButton(
                            child: const Text(
                              "UPDATE",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => KycVerified()));
                            },
                            color: Constants.thaartheme,
                          ),
                        )
                      ],
                    )
                  ],
                ))
          ]));
    },
    transitionBuilder: (_, anim, __, child) {
      Tween<Offset> tween;
      if (anim.status == AnimationStatus.reverse) {
        tween = Tween(begin: Offset(-1, 0), end: Offset.zero);
      } else {
        tween = Tween(begin: Offset(1, 0), end: Offset.zero);
      }

      return SlideTransition(
        position: tween.animate(anim),
        child: FadeTransition(
          opacity: anim,
          child: child,
        ),
      );
    },
  );
}

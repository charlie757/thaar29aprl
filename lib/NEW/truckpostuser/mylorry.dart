// ignore: file_names
// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/currentuserprovider.dart';
import 'package:thaartransport/NEW/truckpostuser/mylorrydata.dart';
import 'package:thaartransport/addtruck/repostlorry.dart';
import 'package:thaartransport/admin/adminhome.dart';
import 'package:thaartransport/modal/truckmodal.dart';
import 'package:thaartransport/screens/kyc/kycverfied.dart';
import 'package:thaartransport/screens/myorders/mybidorder.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/widget/fabbutton.dart';
import 'package:thaartransport/widget/flickerwidget.dart';
import 'package:thaartransport/widget/indicatiors.dart';
import 'package:thaartransport/widget/internetmsg.dart';

import '../../utils/firebase.dart';

class MyLorry extends StatefulWidget {
  const MyLorry({Key? key}) : super(key: key);

  @override
  _MyLorryState createState() => _MyLorryState();
}

class _MyLorryState extends State<MyLorry> with WidgetsBindingObserver {
  bool isFab = false;
  ScrollController scrollController = ScrollController();
  void initState() {
    currentUser();
    WidgetsBinding.instance!.addObserver(this);

    super.initState();
    scrollController.addListener(() {
      if (scrollController.offset > 50) {
        if (mounted) {
          setState(() {
            isFab = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isFab = false;
          });
        }
      }
    });
  }

  void dispose() {
    super.dispose();
    scrollController.dispose();
    WidgetsBinding.instance!.removeObserver(this);
  }

  currentUser() async {
    await usersRef.doc(UserService().currentUid()).get().then((value) {
      setState(() {
        kycstatus = value.get('userkycstatus');
        kycmsg = value.get('kycmsg');
      });
      print(kycstatus);
      print(kycmsg);
    });
  }

  String kycstatus = '';
  String kycmsg = '';
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // GeofenceService.instance.stop();
    }
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.detached) {}
  }

  @override
  Widget build(BuildContext context) {
    // CurrentUserProvider currentUserProvider =
    //     Provider.of<CurrentUserProvider>(context);
    // currentUserProvider.currentuser();

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    return !isOnline
        ? internetchecker()
        : Scaffold(
            floatingActionButton: isFab
                ? buildFAB(
                    context,
                  )
                : buildExtendedFAB(context, kycstatus),
            body: kycstatus == 'rePending'
                ? Center(
                    child: AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                    title: const Text("KYC Status"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kycmsg,
                          style: GoogleFonts.ibmPlexSerif(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            fontStyle: FontStyle.normal,
                            fontSize: 16.0,
                          ),
                        )
                      ],
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(left: 50, right: 50),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.orange),
                              onPressed: () async {
                                await usersRef
                                    .doc(UserService().currentUid())
                                    .update({'userkycstatus': 'Pending'}).then(
                                        (value) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => KycVerified()));
                                });
                              },
                              child: const Text("Update")),
                        ),
                      )
                    ],
                  ))
                : Container(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: [
                        heading(),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                              stream: truckRef
                                  .where('ownerId',
                                      isEqualTo: UserService().currentUid())
                                  .orderBy('time', descending: true)
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasError) {
                                  return const Scaffold(
                                      body: Text("Somthing went Wrong"));
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return FlickerWidget();
                                } else if (snapshot.data!.docs.isEmpty) {
                                  return Container(
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "You have not active truck at the moment",
                                      ));
                                }
                                final data = snapshot.requireData;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15, left: 10, right: 10),
                                  child: ListView.builder(
                                      itemCount: snapshot.data!.docs.length,
                                      physics: const ScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        TruckModal truckModal =
                                            TruckModal.fromJson(snapshot
                                                    .data!.docs[index]
                                                    .data()
                                                as Map<String, dynamic>);
                                        return Mylorrydata(truckModal);
                                      }),
                                );
                              }),
                        ),
                      ],
                    ),
                  ));
  }

  Widget heading() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Trucks',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          FlatButton(
              color: Color(0XFF142438),
              textColor: Colors.white,
              onPressed: () {
                // showCustomDialog(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyBidOrder()));
              },
              child: Container(
                width: 100,
                alignment: Alignment.center,
                child: const Text(
                  "My Orders",
                ),
              ))
        ],
      ),
    );
  }

  pendingkycbox(BuildContext context) {
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      title: const Text("KYC Status"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kycmsg,
            style: GoogleFonts.ibmPlexSerif(
              fontWeight: FontWeight.w400,
              color: Colors.black,
              fontStyle: FontStyle.normal,
              fontSize: 16.0,
            ),
          )
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(left: 50, right: 50),
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.orange),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => KycVerified()));
                },
                child: const Text("Update")),
          ),
        )
      ],
    );
  }

  showCustomDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) {
        return Center(
          child: Container(
            height: 240,
            child: SizedBox.expand(child: FlutterLogo()),
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(40)),
          ),
        );
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
}

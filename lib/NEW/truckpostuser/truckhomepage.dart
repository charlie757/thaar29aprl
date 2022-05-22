import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thaartransport/NEW/currentuserprovider.dart';
import 'package:thaartransport/NEW/postloaduser/marketload.dart';
import 'package:thaartransport/NEW/truckpostuser/mylorry.dart';
import 'package:thaartransport/admin/adminhome.dart';
import 'package:thaartransport/screens/Notifications/notification.dart';
import 'package:thaartransport/screens/myorders/mybidorder.dart';

import 'package:thaartransport/screens/profile/profilescreen.dart';
import 'package:thaartransport/screens/sidebar.dart';
import 'package:thaartransport/services/notificationhandling.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/widget/flickerwidget.dart';

import '../../payment/addmoney.dart';

class TruckHomePage extends StatefulWidget {
  int currentIndex;
  TruckHomePage(this.currentIndex);
  @override
  State<TruckHomePage> createState() => _TruckHomePageState();
}

class _TruckHomePageState extends State<TruckHomePage> {
  void versionCheck() async {
    final NewVersion newVersion =
        NewVersion(androidId: 'thaar.app.thaartransport');
    final status = await newVersion.getVersionStatus();
    newVersion.showUpdateDialog(
        context: context,
        versionStatus: status!,
        dialogText: "Please update your app from" +
            status.localVersion +
            "to" +
            "${status.storeVersion} version",
        dismissButtonText: "Skip",
        dialogTitle: "UPDATE!!",
        dismissAction: () {
          SystemNavigator.pop();
        },
        updateButtonText: "Lets update");
    print("device: ${status.localVersion}");
    print("store: ${status.storeVersion}");
  }

  @override
  void initState() {
    super.initState();
    NotificationHandling().handleMessaging(context);
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data['screen'] == 'Update App') {}

      RemoteNotification notification = message.notification!;
      AndroidNotification? androidNotification = message.notification?.android;
      if (androidNotification != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => MyBidOrder()));
      }
    });

    // versionCheck();
    _selectedIndex = widget.currentIndex;
  }

  int _selectedIndex = 0;
  final tabs = [MyLorry(), MarketLoad(), AddMoney()];

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
          gravity: ToastGravity.CENTER,
          msg: 'Press again to exit app',
          fontSize: 17);
      return Future.value(false);
    }
    exit(0);

    // return Future.value(true);
  }

  @override
  Widget build(BuildContext context) {
    CurrentUserProvider currentUserProvider =
        Provider.of<CurrentUserProvider>(context);
    currentUserProvider.currentuser();
    return WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.white,
            leading: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()));
              },
              child: Container(
                margin: const EdgeInsets.all(5),
                width: 20,
                height: 20,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(15)),
                child: CachedNetworkImage(
                    // height: 50,
                    // width: 50,
                    imageUrl: currentUserProvider.photourl,
                    placeholder: (context, url) => Transform.scale(
                          scale: 0.4,
                          child: CircularProgressIndicator(
                            color: Constants.kYellowColor,
                            strokeWidth: 3,
                          ),
                        ),
                    errorWidget: (context, url, error) => Container(
                        height: 40,
                        width: 40,
                        child:
                            Image.asset('assets/images/account_profile.png')),
                    fit: BoxFit.cover),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                currentUserProvider.username == ""
                    ? Shimmer.fromColors(
                        baseColor: Colors.grey.shade100,
                        highlightColor: Colors.grey.shade300,
                        child: Text(currentUserProvider.username))
                    : Text(
                        currentUserProvider.username,
                        style: const TextStyle(color: Colors.black),
                      ),
                const SizedBox(
                  height: 2,
                ),
                currentUserProvider.kycstatus == "Pending" ||
                        currentUserProvider.kycstatus == "rePending"
                    ? Container(
                        width: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.red)),
                        child: const Text(
                          "KYC PENDING",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      )
                    : Container(
                        width: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.green)),
                        child: const Text(
                          "KYC Completed",
                          style: TextStyle(color: Colors.green, fontSize: 12),
                        ),
                      )
              ],
            ),
            actions: [
              IconButton(
                  splashRadius: 20,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Notifications()));
                  },
                  icon: const Icon(Icons.notifications),
                  color: Colors.black),
              IconButton(
                splashRadius: 20,
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      fullscreenDialog: true,
                      pageBuilder: (c, a1, a2) => SideBar(),
                      transitionsBuilder: (c, anim, a2, child) =>
                          FadeTransition(opacity: anim, child: child),
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                color: Colors.black,
                icon: const Icon(Icons.menu_outlined),
              ),
            ],
          ),
          body: tabs[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              selectedItemColor: const Color(0XFF142438),
              unselectedItemColor: Colors.black26,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(LineIcons.truck), label: "My Lorry"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: "Market"),
                BottomNavigationBarItem(
                    icon: Icon(LineIcons.coins), label: "Payment")
              ]),
        ));
  }
}

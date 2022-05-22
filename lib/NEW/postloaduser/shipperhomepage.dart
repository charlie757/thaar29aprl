import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:new_version/new_version.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:thaartransport/NEW/currentuserprovider.dart';
import 'package:thaartransport/NEW/postloaduser/myloadpage.dart';
import 'package:thaartransport/NEW/truckpostuser/markettruck.dart';
import 'package:thaartransport/admin/adminhome.dart';
import 'package:thaartransport/payment/addmoney.dart';
import 'package:thaartransport/screens/Notifications/notification.dart';
import 'package:thaartransport/screens/profile/profilescreen.dart';
import 'package:thaartransport/screens/sidebar.dart';
import 'package:thaartransport/services/auth_service.dart';
import 'package:thaartransport/services/notificationhandling.dart';
import 'package:thaartransport/services/userservice.dart';

import '../../utils/constants.dart';

class ShipperHomePage extends StatefulWidget {
  int currentIndex;
  ShipperHomePage(this.currentIndex);

  @override
  State<ShipperHomePage> createState() => _ShipperHomePageState();
}

class _ShipperHomePageState extends State<ShipperHomePage> {
  int _selectedIndex = 0;
  final tabs = [
    MyLoadPage(currentuser: UserService().currentUid()),
    MarketTruck(),
    AddMoney()
  ];

  void versionCheck() async {
    final NewVersion newVersion =
        NewVersion(androidId: 'thaar.app.thaartransport');
    final status = await newVersion.getVersionStatus();
    newVersion.showUpdateDialog(
        context: context,
        versionStatus: status!,
        dialogText: "Please update your app from" +
            "${status.localVersion}" +
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
    _selectedIndex = widget.currentIndex;
    NotificationHandling().handleMessaging(context);
    // versionCheck();
  }

  DateTime? currentBackPressTime;
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
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
                  child: currentUserProvider.photourl == ""
                      ? const Icon(
                          Icons.people_alt,
                          color: Colors.grey,
                          size: 30,
                        )
                      : CachedNetworkImage(
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
                              child: Image.asset(
                                  'assets/images/account_profile.png')),
                          fit: BoxFit.cover),
                )),
            title: currentUserProvider.username == ""
                ? Shimmer.fromColors(
                    baseColor: Colors.grey.shade100,
                    highlightColor: Colors.grey.shade300,
                    child: Text(currentUserProvider.username))
                : Text(
                    currentUserProvider.username,
                    style: const TextStyle(color: Colors.black),
                  ),
            actions: [
              IconButton(
                  splashRadius: 20,
                  onPressed: () {
                    currentUserProvider.usernumber == "+919999999999"
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AdminHome()))
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Notifications()));
                  },
                  icon: const Icon(Icons.notifications_outlined),
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
              selectedItemColor: Constants.thaartheme,
              unselectedItemColor: Colors.black26,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(LineIcons.boxOpen), label: "My Load"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.home), label: "Market"),
                BottomNavigationBarItem(
                    icon: Icon(LineIcons.coins), label: "Payment")
              ]),
        ));
  }
}

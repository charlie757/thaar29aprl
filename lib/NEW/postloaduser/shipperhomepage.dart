import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/currentuserprovider.dart';
import 'package:thaartransport/NEW/postloaduser/myloadpage.dart';
import 'package:thaartransport/NEW/truckpostuser/markettruck.dart';
import 'package:thaartransport/payment/addmoney.dart';
import 'package:thaartransport/screens/Notifications/notification.dart';
import 'package:thaartransport/screens/profile/profilescreen.dart';
import 'package:thaartransport/screens/sidebar.dart';
import 'package:thaartransport/services/auth_service.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                  },
                  child: Container(
                      margin: const EdgeInsets.all(5),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15)),
                      child: currentUserProvider.photourl == ""
                          ? const Icon(
                              Icons.people_alt,
                              color: Colors.grey,
                              size: 30,
                            )
                          : Image.network(
                              currentUserProvider.photourl,
                              fit: BoxFit.fill,
                            ))),
              title: Text(
                currentUserProvider.username == ""
                    ? "Shipper"
                    : currentUserProvider.username,
                style: const TextStyle(color: Colors.black),
              ),
              actions: [
                IconButton(
                    splashRadius: 20,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Notifications()));
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
                  icon: const Icon(Icons.menu),
                ),
              ],
            ),
            body: tabs[_selectedIndex],
            bottomNavigationBar: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Constants.white,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(.1),
                    )
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 8),
                    child: GNav(
                      hoverColor: Constants.bnbhover,
                      gap: 8,
                      activeColor: Constants.white,
                      iconSize: 24,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      duration: const Duration(milliseconds: 400),
                      tabBackgroundColor: Constants.bnbhover,
                      color: Colors.black,
                      tabs: const [
                        GButton(
                          icon: LineIcons.box,
                          text: 'My Load',
                        ),
                        GButton(
                          icon: LineIcons.home,
                          text: 'Market',
                        ),
                        GButton(
                          icon: LineIcons.coins,
                          text: 'Payment',
                        ),
                      ],
                      selectedIndex: _selectedIndex,
                      onTabChange: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                  ),
                ))));
  }
}

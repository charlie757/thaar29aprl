import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/currentuserprovider.dart';
import 'package:thaartransport/NEW/postloaduser/marketload.dart';
import 'package:thaartransport/NEW/truckpostuser/mylorry.dart';
import 'package:thaartransport/admin/adminhome.dart';
import 'package:thaartransport/screens/Notifications/notification.dart';

import 'package:thaartransport/screens/profile/profilescreen.dart';
import 'package:thaartransport/screens/sidebar.dart';

import '../../payment/addmoney.dart';

class TruckHomePage extends StatefulWidget {
  int currentIndex;
  TruckHomePage(this.currentIndex);
  @override
  State<TruckHomePage> createState() => _TruckHomePageState();
}

class _TruckHomePageState extends State<TruckHomePage> {
  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  int _selectedIndex = 0;
  final tabs = [MyLorry(), MarketLoad(), AddMoney()];

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
                        : Image.network(
                            currentUserProvider.photourl,
                            fit: BoxFit.fill,
                          ))),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUserProvider.username == ""
                      ? "Unknow"
                      : currentUserProvider.username,
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(
                  height: 2,
                ),
                currentUserProvider.kycstatus == "Pending"
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
                            border: Border.all(color: Colors.blue)),
                        child: Text(
                          "KYC Completed",
                          style:
                              TextStyle(color: Colors.blue[900], fontSize: 12),
                        ),
                      )
              ],
            ),
            actions: [
              IconButton(
                  splashRadius: 20,
                  onPressed: () {
                    currentUserProvider.usernumber == "+919999999999"
                        ? Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AdminHome()))
                        : Navigator.push(
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
                icon: const Icon(Icons.menu),
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

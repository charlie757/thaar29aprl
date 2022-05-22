// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:thaartransport/NEW/homepage.dart';
import 'package:thaartransport/screens/myorders/completedorders.dart';
import 'package:thaartransport/screens/myorders/ongoingorders.dart';
import 'package:thaartransport/utils/constants.dart';

class MyBidOrder extends StatefulWidget {
  const MyBidOrder({Key? key}) : super(key: key);

  @override
  _MyBidOrderState createState() => _MyBidOrderState();
}

class _MyBidOrderState extends State<MyBidOrder> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
        return false;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: appBar(),
            body: TabBarView(children: [
              OnGoingOrders(),
              CompletedOrders(),
            ])),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      toolbarHeight: 25,
      backgroundColor: Color(0XFF142438),
      bottom: TabBar(
          labelColor: Constants.white,
          // indicatorColor: Constants.btnBG,
          // // labelColor: Constants.btnBG,
          // unselectedLabelColor: Colors.grey,

          indicatorColor: Constants.cursorColor,
          unselectedLabelColor: Color(0xffb8b0b8),
          labelStyle: TextStyle(fontSize: 18),
          tabs: [
            Tab(
              text: "OnGoing",
            ),
            Tab(
              text: "Completed",
            )
          ]),
    );
  }
}

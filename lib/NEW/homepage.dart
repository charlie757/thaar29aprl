import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/currentuserprovider.dart';
import 'package:thaartransport/NEW/postloaduser/shipperhomepage.dart';
import 'package:thaartransport/NEW/truckpostuser/truckhomepage.dart';
import 'package:thaartransport/widget/flickerwidget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    CurrentUserProvider currentUserProvider =
        Provider.of<CurrentUserProvider>(context);
    currentUserProvider.currentuser();

    return currentUserProvider.usertype == "Transporator"
        ? TruckHomePage(0)
        : ShipperHomePage(0);
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/admin/documents.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/utils/firebase.dart';

class Trucks extends StatefulWidget {
  String ownerid;
  String name;
  String status;
  Trucks(this.ownerid, this.name, this.status);

  @override
  State<Trucks> createState() => _TrucksState();
}

class _TrucksState extends State<Trucks> {
  activeTruck() async {
    await truckRef
        .where('ownerId', isEqualTo: widget.ownerid)
        .where('truckstatus', isEqualTo: "ACTIVE")
        .get()
        .then((value) {
      setState(() {
        activedoc = value.docs;
        print(value.docs.length);
      });
    });
  }

  expireTruck() async {
    await truckRef
        .where('ownerId', isEqualTo: widget.ownerid)
        .where('truckstatus', isEqualTo: "EXPIRED")
        .get()
        .then((value) {
      setState(() {
        expiredoc = value.docs;
        print(value.docs.length);
      });
    });
  }

  waitingbid() async {
    await bidRef
        .where('truckownerid', isEqualTo: widget.ownerid)
        .where('bidresponse', isEqualTo: "")
        .get()
        .then((value) {
      setState(() {
        waitingbiddoc = value.docs;
        print(value.docs.length);
      });
    });
  }

  acceptedbid() async {
    await bidRef
        .where('truckownerid', isEqualTo: widget.ownerid)
        .where('bidresponse', isEqualTo: "Bid Accepted")
        .get()
        .then((value) {
      setState(() {
        acceptbiddoc = value.docs;
        print(value.docs.length);
      });
    });
  }

  rejectedBid() async {
    await bidRef
        .where('truckownerid', isEqualTo: widget.ownerid)
        .where('bidresponse', isEqualTo: "Bid Rejected")
        .get()
        .then((value) {
      setState(() {
        rejectbiddoc = value.docs;
        print(value.docs.length);
      });
    });
  }

  completedBid() async {
    await bidRef
        .where('truckownerid', isEqualTo: widget.ownerid)
        .where('bidresponse', isEqualTo: "Bid Completed")
        .get()
        .then((value) {
      setState(() {
        completebiddoc = value.docs;
        print(value.docs.length);
      });
    });
  }

  List activedoc = [];
  List expiredoc = [];
  List acceptbiddoc = [];
  List rejectbiddoc = [];
  List waitingbiddoc = [];
  List completebiddoc = [];

  @override
  void initState() {
    super.initState();
    activeTruck();
    expireTruck();
    acceptedbid();
    rejectedBid();
    waitingbid();
    completedBid();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
        ),
        body: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2),
          children: [
            InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              documents(widget.name, widget.ownerid)));
                },
                child: cardWidget('Documents', widget.status)),
            cardWidget('Active Truck', activedoc.length.toString()),
            cardWidget('Expire Truck', expiredoc.length.toString()),
            cardWidget('Bid Accept', acceptbiddoc.length.toString()),
            cardWidget('Bid Reject', rejectbiddoc.length.toString()),
            cardWidget('Bid Complete', completebiddoc.length.toString()),
            cardWidget('Bid waiting', waitingbiddoc.length.toString()),
          ],
        ));
  }

  Widget cardWidget(String title, String count) {
    return Card(
      color: Colors.blue.shade100,
      shadowColor: Colors.red,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(count)
        ],
      ),
    );
  }
}

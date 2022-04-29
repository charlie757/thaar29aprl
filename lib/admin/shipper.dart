import 'package:flutter/material.dart';
import 'package:thaartransport/utils/firebase.dart';

class Shipper extends StatefulWidget {
  String name;
  String ownerid;
  Shipper(this.name, this.ownerid);

  @override
  State<Shipper> createState() => _ShipperState();
}

class _ShipperState extends State<Shipper> {
  totalLoad() async {
    await postRef
        .where('ownerId', isEqualTo: widget.ownerid)
        .get()
        .then((value) {
      setState(() {
        totalloadList = value.docs;
        print(value.docs.length);
      });
    });
  }

  activeLoad() async {
    await postRef
        .where('loadstatus', isEqualTo: "Active")
        .where('ownerId', isEqualTo: widget.ownerid)
        .get()
        .then((value) {
      setState(() {
        activeloadList = value.docs;
        print(value.docs.length);
      });
    });
  }

  expiredLoad() async {
    await postRef
        .where('loadstatus', isEqualTo: "Expired")
        .where('ownerId', isEqualTo: widget.ownerid)
        .get()
        .then((value) {
      setState(() {
        expiredloadList = value.docs;
        print(value.docs.length);
      });
    });
  }

  inTransitLoad() async {
    await postRef
        .where('loadstatus', isEqualTo: "InTransit")
        .where('ownerId', isEqualTo: widget.ownerid)
        .get()
        .then((value) {
      setState(() {
        intransitloadList = value.docs;
        print(value.docs.length);
      });
    });
  }

  completedLoad() async {
    await postRef
        .where('loadstatus', isEqualTo: "Completed")
        .where('ownerId', isEqualTo: widget.ownerid)
        .get()
        .then((value) {
      setState(() {
        completedloadList = value.docs;
        print(value.docs.length);
      });
    });
  }

  waitingbid() async {
    await bidRef
        .where('loadpostid', isEqualTo: widget.ownerid)
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
        .where('loadpostid', isEqualTo: widget.ownerid)
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
        .where('loadpostid', isEqualTo: widget.ownerid)
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
        .where('loadpostid', isEqualTo: widget.ownerid)
        .where('bidresponse', isEqualTo: "Bid Completed")
        .get()
        .then((value) {
      setState(() {
        completebiddoc = value.docs;
        print(value.docs.length);
      });
    });
  }

  List totalloadList = [];
  List activeloadList = [];
  List expiredloadList = [];
  List intransitloadList = [];
  List completedloadList = [];
  List acceptbiddoc = [];
  List rejectbiddoc = [];
  List waitingbiddoc = [];
  List completebiddoc = [];

  @override
  void initState() {
    totalLoad();
    activeLoad();
    expiredLoad();
    inTransitLoad();
    completedLoad();
    waitingbid();
    acceptedbid();
    rejectedBid();
    completedBid();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: GridView(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        children: [
          cardWidget('Total Load', totalloadList.length.toString()),
          cardWidget('Active Load', activeloadList.length.toString()),
          cardWidget('Expire Load', expiredloadList.length.toString()),
          cardWidget('InTransit Load', intransitloadList.length.toString()),
          cardWidget('Completed Load', completedloadList.length.toString()),
          cardWidget('Waiting Bid', waitingbiddoc.length.toString()),
          cardWidget('Accepted Bid', acceptbiddoc.length.toString()),
          cardWidget('Rejected Bid', rejectbiddoc.length.toString()),
          cardWidget('Completed Bid', completebiddoc.length.toString()),
        ],
      ),
    );
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

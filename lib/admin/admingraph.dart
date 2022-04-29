import 'package:flutter/material.dart';
import 'package:thaartransport/utils/firebase.dart';

class AdminGraph extends StatefulWidget {
  const AdminGraph({Key? key}) : super(key: key);

  @override
  State<AdminGraph> createState() => _AdminGraphState();
}

class _AdminGraphState extends State<AdminGraph> {
  List totalusersList = [];
  List truckusersList = [];
  List shipperusersList = [];
  List totalloadList = [];
  List activeloadList = [];
  List expiredloadList = [];
  List intransitloadList = [];
  List totaltruckList = [];
  List verifiedtruckList = [];
  List unverifiedtruckList = [];
  List totalbidList = [];
  List waitingbidList = [];
  List acceptedbidList = [];
  List rejectedbidList = [];
  List completedbidList = [];
  totalUsers() async {
    await usersRef.get().then((value) {
      setState(() {
        totalusersList = value.docs;
        print(value.docs.length);
      });
    });
  }

  truckUsers() async {
    await usersRef
        .where('usertype', isEqualTo: "Truck Owner")
        .get()
        .then((value) {
      setState(() {
        truckusersList = value.docs;
        print(value.docs.length);
      });
    });
  }

  shipperUsers() async {
    await usersRef.where('usertype', isEqualTo: "Shipper").get().then((value) {
      setState(() {
        shipperusersList = value.docs;
        print(value.docs.length);
      });
    });
  }

  totalLoad() async {
    await postRef.get().then((value) {
      setState(() {
        totalloadList = value.docs;
        print(value.docs.length);
      });
    });
  }

  activeLoad() async {
    await postRef.where('loadstatus', isEqualTo: "Active").get().then((value) {
      setState(() {
        activeloadList = value.docs;
        print(value.docs.length);
      });
    });
  }

  expiredLoad() async {
    await postRef.where('loadstatus', isEqualTo: "Expired").get().then((value) {
      setState(() {
        expiredloadList = value.docs;
        print(value.docs.length);
      });
    });
  }

  inTransitLoad() async {
    await postRef
        .where('loadstatus', isEqualTo: "InTransit")
        .get()
        .then((value) {
      setState(() {
        intransitloadList = value.docs;
        print(value.docs.length);
      });
    });
  }

  totalTruck() async {
    await truckRef.get().then((value) {
      setState(() {
        totaltruckList = value.docs;
        print(value.docs.length);
      });
    });
  }

  verifiedTruck() async {
    await truckRef
        .where('truckloadstatus', isEqualTo: "Verified")
        .get()
        .then((value) {
      setState(() {
        verifiedtruckList = value.docs;
        print(value.docs.length);
      });
    });
  }

  unverifiedTruck() async {
    await truckRef
        .where('truckloadstatus', isEqualTo: "Verification Pending")
        .get()
        .then((value) {
      setState(() {
        unverifiedtruckList = value.docs;
        print(value.docs.length);
      });
    });
  }

  totalbids() async {
    await bidRef.get().then((value) {
      setState(() {
        totalbidList = value.docs;
        print(value.docs.length);
      });
    });
  }

  waitingbid() async {
    await bidRef.where('bidresponse', isEqualTo: "").get().then((value) {
      setState(() {
        waitingbidList = value.docs;
        print(value.docs.length);
      });
    });
  }

  acceptedbid() async {
    await bidRef
        .where('bidresponse', isEqualTo: "Bid Accepted")
        .get()
        .then((value) {
      setState(() {
        acceptedbidList = value.docs;
        print(value.docs.length);
      });
    });
  }

  rejectedBid() async {
    await bidRef
        .where('bidresponse', isEqualTo: "Bid Rejected")
        .get()
        .then((value) {
      setState(() {
        rejectedbidList = value.docs;
        print(value.docs.length);
      });
    });
  }

  completedbid() async {
    await bidRef
        .where('bidresponse', isEqualTo: "Bid Completed")
        .get()
        .then((value) {
      setState(() {
        completedbidList = value.docs;
        print(value.docs.length);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    totalUsers();
    truckUsers();
    shipperUsers();
    totalLoad();
    activeLoad();
    expiredLoad();
    inTransitLoad();
    totalTruck();
    verifiedTruck();
    unverifiedTruck();
    totalbids();
    waitingbid();
    acceptedbid();
    rejectedBid();
    completedbid();
  }

  @override
  Widget build(BuildContext context) {
    return GridView(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      children: [
        cardWidget('Total users', totalusersList.length.toString()),
        cardWidget('Truck Users', truckusersList.length.toString()),
        cardWidget('Shipper users', shipperusersList.length.toString()),
        cardWidget('Total Load', totalloadList.length.toString()),
        cardWidget('Active Load', activeloadList.length.toString()),
        cardWidget('Expired Load', expiredloadList.length.toString()),
        cardWidget('Intransit Load', intransitloadList.length.toString()),
        cardWidget('Total Truck', totaltruckList.length.toString()),
        cardWidget('Verified Truck', verifiedtruckList.length.toString()),
        cardWidget('UnVerified Truck', unverifiedtruckList.length.toString()),
        cardWidget('Total bid', totalbidList.length.toString()),
        cardWidget('Waiting bid', waitingbidList.length.toString()),
        cardWidget('Accepted bid', acceptedbidList.length.toString()),
        cardWidget('Rejected bid', rejectedbidList.length.toString()),
        cardWidget('Completed Bid', completedbidList.length.toString())
      ],
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

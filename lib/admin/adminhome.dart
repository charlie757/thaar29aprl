import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thaartransport/admin/admingraph.dart';
import 'package:thaartransport/admin/shipperpanel.dart';
import 'package:thaartransport/admin/transportpanel.dart';
import 'package:thaartransport/modal/truckmodal.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/utils/firebase.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  void initState() {
    super.initState();
  }

  int cuurentIndex = 0;

  List bodyList = [
    TransportPanel(),
    ShipperPanel(),
    AdminGraph(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0XFF142438),
        title: const Text("Admin Panel"),
      ),
      body: bodyList[cuurentIndex],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: cuurentIndex,
          onTap: (index) {
            setState(() {
              cuurentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Truck"),
            BottomNavigationBarItem(
                icon: Icon(Icons.production_quantity_limits), label: "load"),
            BottomNavigationBarItem(
                icon: Icon(Icons.auto_graph), label: "graph")
          ]),
    );
  }
}

class LoadData extends StatefulWidget {
  const LoadData({Key? key}) : super(key: key);

  @override
  State<LoadData> createState() => _LoadDataState();
}

class _LoadDataState extends State<LoadData> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: usersRef.where('usertype', isEqualTo: 'Shipper').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                UserModel userModel = UserModel.fromJson(
                    snapshot.data!.docs[index].data() as Map<String, dynamic>);
                return Card(
                  elevation: 9,
                  child: ListTile(
                    leading: Container(
                        width: 80,
                        child: Image.network(
                          userModel.photourl.toString(),
                          fit: BoxFit.cover,
                        )),
                    title: Text(userModel.username.toString()),
                    subtitle: Text(userModel.usernumber.toString()),
                    trailing: Text(
                      userModel.loginstatus.toString(),
                      style: TextStyle(
                          fontSize: 16,
                          color: userModel.loginstatus == 'login'
                              ? Colors.green
                              : Colors.red),
                    ),
                  ),
                );
              });
        });
  }
}

class TruckData extends StatefulWidget {
  const TruckData({Key? key}) : super(key: key);

  @override
  State<TruckData> createState() => _TruckDataState();
}

class _TruckDataState extends State<TruckData> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream:
            usersRef.where('usertype', isEqualTo: 'Truck Owner').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                UserModel userModel = UserModel.fromJson(
                    snapshot.data!.docs[index].data() as Map<String, dynamic>);
                return Card(
                  child: Row(
                    children: [
                      Image.network(
                        userModel.photourl.toString(),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    ],
                  ),
                );
              });
        });
  }

  Widget usersdata(UserModel userModel) {
    return StreamBuilder<QuerySnapshot>(
        stream: truckRef.where('ownerId', isEqualTo: userModel.id).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                TruckModal truckModal = TruckModal.fromJson(
                    snapshot.data!.docs[index].data() as Map<String, dynamic>);
                return Card(
                  child: Row(
                    children: [
                      Image.network(
                        userModel.photourl.toString(),
                        width: 100,
                        height: 100,
                      )
                    ],
                  ),
                );
              });
        });
  }
}

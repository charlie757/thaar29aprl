// ignore: file_names
// ignore_for_file: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/addtruck/repostlorry.dart';
import 'package:thaartransport/modal/truckmodal.dart';
import 'package:thaartransport/screens/myorders/mybidorder.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/widget/fabbutton.dart';
import 'package:thaartransport/widget/flickerwidget.dart';
import 'package:thaartransport/widget/indicatiors.dart';
import 'package:thaartransport/widget/internetmsg.dart';

import '../../utils/firebase.dart';

class MyLorry extends StatefulWidget {
  const MyLorry({Key? key}) : super(key: key);

  @override
  _MyLorryState createState() => _MyLorryState();
}

class _MyLorryState extends State<MyLorry> {
  bool isFab = false;
  ScrollController scrollController = ScrollController();
  void initState() {
    currentUser();
    super.initState();
    scrollController.addListener(() {
      if (scrollController.offset > 50) {
        if (mounted) {
          setState(() {
            isFab = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isFab = false;
          });
        }
      }
    });
  }

  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  currentUser() async {
    await usersRef.doc(UserService().currentUid()).get().then((value) {
      setState(() {
        kycstatus = value.get('userkycstatus');
      });
      print(kycstatus);
    });
  }

  String kycstatus = '';
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    return !isOnline
        ? internetchecker()
        : Scaffold(
            floatingActionButton: isFab
                ? buildFAB(
                    context,
                  )
                : buildExtendedFAB(context, kycstatus),
            body: StreamBuilder<QuerySnapshot>(
                stream: truckRef
                    .where('ownerId', isEqualTo: UserService().currentUid())
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Scaffold(body: Text("Somthing went Wrong"));
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return FlickerWidget();
                  } else if (snapshot.data!.docs.isEmpty) {
                    return Container(
                        alignment: Alignment.center,
                        child: const Text(
                          "You have not active truck at the moment",
                        ));
                  }
                  final data = snapshot.requireData;
                  return Padding(
                      padding:
                          const EdgeInsets.only(top: 15, left: 10, right: 10),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          heading(),
                          SizedBox(height: height * 0.03),
                          ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              physics: const ScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                TruckModal truckModal = TruckModal.fromJson(
                                    snapshot.data!.docs[index].data()
                                        as Map<String, dynamic>);
                                return Column(
                                  children: [
                                    truckData(
                                        data.docs[index]['truckposttime'],
                                        data.docs[index]['expiretruck'],
                                        data.docs[index]['lorrynumber'],
                                        data.docs[index]['truckstatus'],
                                        data.docs[index]['capacity'],
                                        // data.docs[index]['truckloadstatus'],
                                        data.docs[index]['sourcelocation'],
                                        data.docs[index]['routes'],
                                        truckModal)
                                  ],
                                );
                              }),
                        ],
                      ));
                }));
  }

  Widget heading() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Other Trucks',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        FlatButton(
            color: Color(0XFF142438),
            textColor: Colors.white,
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MyBidOrder()));
            },
            child: Container(
              width: 100,
              alignment: Alignment.center,
              child: const Text(
                "My Orders",
              ),
            ))
      ],
    );
  }

  Widget truckData(
      String truckpostTime,
      String expretime,
      String truckNo,
      String status,
      String capcity,
      // String truckloadstatus,
      String sourcelocation,
      List routes,
      TruckModal truckModal) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    final currenttime = DateTime.now();
    final backenddate = DateTime.parse(truckModal.expiretruck.toString());
    final difference = backenddate.difference(currenttime).inHours;
    final checkdifference = difference >= 1 ? difference : 1;

    final difference1 = backenddate.difference(currenttime).inMinutes;
    // if (difference1 >= 0) {
    //   truckRef.doc(truckModal.id).update({'truckstatus': "EXPIRED"});
    // }
    // print(difference);
    print(checkdifference);
    String durationToString(difference1) {
      var d = Duration(minutes: difference1);
      List<String> parts = d.toString().split(':');
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
    }

    print(difference1);
    // print(durationToString(difference1));
    // final checkdifference2 = difference1 >= 90 ? 1 : difference1;
    // print("chec$checkdifference2");

    return Column(
      children: [
        Card(
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        status,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: status == "ACTIVE"
                                ? Constants.cursorColor
                                : Constants.alert),
                      )),
                  status == 'ACTIVE'
                      ? PopupMenuButton(
                          icon: const Icon(
                            Icons.more_vert,
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 1,
                                enabled: true,
                                child: Text(
                                  "Remove from market",
                                )),
                          ],
                          onSelected: (menu) {
                            if (menu == 1) {
                              truckRef.doc(truckModal.id).update({
                                'truckstatus': "EXPIRED",
                              });
                            }
                          },
                        )
                      : Container()
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: const Icon(
                    LineIcons.truck,
                    color: Colors.red,
                  ),
                  title: Text(
                    truckNo,
                    style: const TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                  subtitle: Text(
                      "posted on ${truckpostTime.split(',')[1] + truckpostTime.split(',')[2]}"),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Colors.green),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      sourcelocation,
                      style: TextStyle(fontSize: 15),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Colors.red),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      truckModal.destinationlocation.toString(),
                      style: const TextStyle(fontSize: 15),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(LineIcons.truck,
                                size: 15, color: Colors.black26),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              '${capcity} Tonne',
                              style: TextStyle(fontSize: 15),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 15, color: Colors.black26),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              routes.length.toString(),
                              style: TextStyle(fontSize: 15),
                            )
                          ],
                        ),
                      ],
                    ),
                    status == "ACTIVE"
                        ? Flexible(
                            child: Container(
                                width: 100,
                                height: 35,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.red,
                                    border: Border.all(),
                                    borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(15),
                                        topRight: Radius.circular(15))),
                                child: Text.rich(TextSpan(
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13),
                                    text: "Expire In\n",
                                    children: [
                                      TextSpan(
                                          text: checkdifference.toString(),
                                          children: const [
                                            TextSpan(text: " Hours")
                                          ])
                                    ]))))
                        : Container()
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // Container(
              //   padding: EdgeInsets.only(left: 8, right: 8),
              //   child: Text(
              //     truckloadstatus,
              //     style: const TextStyle(fontSize: 16, color: Colors.red),
              //   ),
              // ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                  onTap: () {
                    status == "ACTIVE"
                        ? null
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    RepostLorry(truckModal, routes.length)));
                    ;
                  },
                  child: Container(
                    height: 40,
                    color: const Color(0xffe8e8f0),
                    // width: 150,
                    alignment: Alignment.center,
                    child: Text(
                      status == "ACTIVE" ? "Active Truck" : "ReActive Truck",
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        )
      ],
    );
  }
}

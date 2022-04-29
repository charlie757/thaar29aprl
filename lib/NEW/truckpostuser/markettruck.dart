import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:thaartransport/addnewload/PostLoad.dart';
import 'package:thaartransport/addnewload/orderpostconfirmed.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/truckmodal.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/widget/flickerwidget.dart';
import 'package:thaartransport/widget/indicatiors.dart';
import 'package:thaartransport/widget/internetmsg.dart';

import '../../utils/constants.dart';

class MarketTruck extends StatefulWidget {
  const MarketTruck({Key? key}) : super(key: key);

  @override
  _MarketTruckState createState() => _MarketTruckState();
}

class _MarketTruckState extends State<MarketTruck> {
  ScrollController scrollController = ScrollController();

  String? ownerId;
  String? username;
  String? companyname;
  String? photourl;

  @override
  void initState() {
    super.initState();
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    return !isOnline
        ? internetchecker()
        : DefaultTabController(
            length: 1,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0XFF142438),
                automaticallyImplyLeading: false,
                toolbarHeight: 8,
                bottom: TabBar(
                    indicatorColor: Constants.cursorColor,
                    unselectedLabelColor: Color(0xffb8b0b8),
                    labelStyle: TextStyle(fontSize: 18),
                    labelColor: Constants.white,
                    tabs: const [
                      Tab(
                        child: Text(
                          "BOOK TRUCKS",
                        ),
                      )
                    ]),
              ),
              body: TabBarView(
                children: [
                  StreamBuilder(
                      stream: truckRef
                          .where('ownerId',
                              isNotEqualTo: UserService().currentUid())
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text("Somthing went Wrong");
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return FlickerWidget();
                        } else if (snapshot.hasData) {
                          return ScrollWrapper(
                              scrollController: scrollController,
                              scrollToTopCurve: Curves.easeInOut,
                              promptAlignment: Alignment.bottomRight,
                              child: ListView(
                                controller: scrollController,
                                shrinkWrap: true,
                                children: [
                                  ListView.builder(
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.all(0),
                                      physics: const BouncingScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, int index) {
                                        TruckModal truckModal =
                                            TruckModal.fromJson(snapshot
                                                    .data!.docs[index]
                                                    .data()
                                                as Map<String, dynamic>);
                                        return userdata(truckModal);
                                      }),
                                  const SizedBox(height: 30),
                                ],
                              ));
                        }
                        return circularProgress(context);
                      }),
                ],
              ),
            ),
          );
  }

  Widget userdata(TruckModal truckModal) {
    return StreamBuilder(
        stream: usersRef.doc(truckModal.ownerId).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Somthing went Wrong");
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center();
          } else if (snapshot.hasData) {
            UserModel users = UserModel.fromJson(
                snapshot.data!.data() as Map<String, dynamic>);
            return Column(
              children: [
                showTruckinMarket(
                    truckModal.lorrynumber.toString(),
                    truckModal.sourcelocation.toString(),
                    truckModal.destinationlocation ?? "".toString(),
                    truckModal.capacity.toString(),
                    users,
                    // truckModal.truckloadstatus.toString(),
                    truckModal.expiretruck.toString(),
                    truckModal.routes!,
                    truckModal),
                const SizedBox(
                  height: 15,
                )
              ],
            );
          } else {
            return circularProgress(context);
          }
        });
  }

  // counter(TruckModal truckModal) {
  //   return Countdown(
  //     seconds: 20 * 60 * 60,
  //     build: (context, time) {
  //       return Text(time.toString());
  //     },
  //     interval: Duration(hours: 1),
  //     onFinished: () async {
  //       await truckRef.doc(truckModal.id).update({'truckstatus': "Expire"});
  //       print("Time is done");
  //     },
  //   );
  // }

  Widget showTruckinMarket(
      String truckno,
      String sourcelocation,
      String destinationlocation,
      String capacity,
      UserModel users,
      // String truckloadstatus,
      String expireTime,
      List routes,
      TruckModal truckModal) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    final currenttime = DateTime.now();
    final backenddate = DateTime.parse(expireTime.toString());
    final difference = backenddate.difference(currenttime).inHours;
    final checkdifference = difference >= 1 ? difference : 1;

    return Container(
        margin: const EdgeInsets.all(7),
        width: width,
        child: Card(
            elevation: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black26),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 35,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: Constants.btnBG,
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
                                      children: const [TextSpan(text: "Hours")])
                                ])),
                          )
                        ],
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/truckpost.jpeg',
                                height: 40,
                                width: 40,
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text(
                                "posted on",
                                style: TextStyle(
                                    fontWeight: FontWeight.w300, fontSize: 13),
                              ),
                              Text(
                                truckModal.truckposttime
                                        .toString()
                                        .split(',')[1] +
                                    truckModal.truckposttime
                                        .toString()
                                        .split(',')[2],
                                style: const TextStyle(fontSize: 14),
                              )
                            ],
                          )),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 13,
                                color: Colors.green,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                sourcelocation,
                                style: TextStyle(fontSize: 15),
                              )
                            ],
                          )),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                size: 13,
                                color: Colors.blue,
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                destinationlocation,
                                style: TextStyle(fontSize: 15),
                              )
                            ],
                          )),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.circle,
                                          size: 13, color: Colors.black12),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Text.rich(TextSpan(
                                          text: capacity,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 17),
                                          children: const [
                                            TextSpan(
                                              text: " tonne capacity",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16),
                                            )
                                          ]))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.circle,
                                          size: 13, color: Colors.black12),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Text.rich(TextSpan(
                                          text: routes.length.toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 17),
                                          children: const [
                                            TextSpan(
                                              text: " routes",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 16),
                                            )
                                          ]))
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      routesSheet(routes);
                                    },
                                    child: Container(
                                      height: 35,
                                      width: 150,
                                      decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.blue)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.add_location_alt_rounded,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "Check Routes",
                                            style:
                                                TextStyle(color: Colors.blue),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Flexible(
                                  child: FlatButton(
                                      color: Color(0XFF142438),
                                      textColor: Colors.white,
                                      onPressed: () {
                                        selectload(truckModal);
                                      },
                                      child: const Text("Book Truck")))
                            ],
                          )),
                      const SizedBox(
                        height: 6,
                      )
                    ],
                  ),
                ),
                Card(
                  elevation: 0,
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xff4D4D4D),
                      backgroundImage:
                          CachedNetworkImageProvider(users.photourl ?? ''),
                    ),
                    title: Text(
                      users.companyname!,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            )));
  }

  selectload(TruckModal truckModal) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                color: const Color(0xFF737373),
                height: MediaQuery.of(context).size.height / 1.3,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: _buildloadbid(truckModal),
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                ),
              ));
        });
  }

  routesSheet(List routes) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            height: 300,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25))),
            child: StatefulBuilder(builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        margin: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Truck Routes",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 18),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(Icons.close),
                            )
                          ],
                        )),
                    Container(
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      child: Wrap(
                        children:
                            routes.map((e) => Chip(label: Text(e))).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }

  _buildloadbid(TruckModal truckModal) {
    return StatefulBuilder(builder: (context, setstate) {
      return StreamBuilder(
          stream: postRef
              .where('ownerId', isEqualTo: UserService().currentUid())
              .where('loadstatus', isEqualTo: "Active")
              .orderBy(
                'loadposttime',
              )
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Somthing went Wrong");
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center();
            } else if (snapshot.data!.docs.isEmpty) {
              return Container(
                  // alignment: Alignment.center,
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "You have not active loads at the moment",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  loadbutton(),
                ],
              ));
            }
            return SingleChildScrollView(
                child: Wrap(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select your load for Bid",
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close))
                      ],
                    )),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, int index) {
                          PostModal posts = PostModal.fromJson(
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>);

                          return LoadPosts(
                              posts.loadstatus!,
                              posts.loadposttime!,
                              posts.sourcelocation!,
                              posts.destinationlocation!,
                              posts.material!,
                              posts.quantity!,
                              posts.expectedprice!,
                              posts.priceunit!,
                              posts,
                              truckModal);
                        })
                  ],
                )
              ],
            ));
          });
    });
  }

  buildloadbid(TruckModal truckModal) {
    return StatefulBuilder(builder: (context, setstate) {
      return StreamBuilder(
          stream: postRef
              .where('ownerId', isEqualTo: UserService().currentUid())
              .where('loadstatus', isEqualTo: "Active")
              .orderBy(
                'loadposttime',
              )
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text("Somthing went Wrong");
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center();
            } else if (snapshot.data!.docs.isEmpty) {
              return Container(
                  // alignment: Alignment.center,
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/77295-not-available.json',
                      height: 200, width: 200),
                  const Text(
                    "You have not active loads at the moment",
                    style: TextStyle(fontSize: 17),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  loadbutton(),
                ],
              ));
            }
            return SingleChildScrollView(
                child: Wrap(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select your load for Bid",
                          style: GoogleFonts.lato(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close))
                      ],
                    )),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, int index) {
                          PostModal posts = PostModal.fromJson(
                              snapshot.data!.docs[index].data()
                                  as Map<String, dynamic>);

                          return LoadPosts(
                              posts.loadstatus!,
                              posts.loadposttime!,
                              posts.sourcelocation!,
                              posts.destinationlocation!,
                              posts.material!,
                              posts.quantity!,
                              posts.expectedprice!,
                              posts.priceunit!,
                              posts,
                              truckModal);
                        })
                  ],
                )
              ],
            ));
          });
    });
  }

  Widget LoadPosts(
      String status,
      String postTime,
      String source,
      String destination,
      String material,
      String quantity,
      String expectedPrice,
      String priceunit,
      PostModal posts,
      TruckModal truckModal) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return InkWell(
        onTap: () async {
          onConfirmBid(posts, truckModal);
        },
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Card(
              // color: Colors.red,
              elevation: 8,
              child: Container(
                child: Column(children: [
                  Container(
                      padding:
                          const EdgeInsets.only(left: 10, right: 10, top: 15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 90,
                                height: 22,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: Border.all(),
                                    borderRadius: BorderRadius.circular(25)),
                                child: Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold,
                                      color: status == "Active"
                                          ? Constants.cursorColor
                                          : status == "Expired"
                                              ? Constants.alert
                                              : status == "Intransit"
                                                  ? Colors.green
                                                  : Colors.blue),
                                ),
                              ),
                            ],
                          ),
                          Text(postTime.split(',')[1] + postTime.split(',')[2]),
                          SizedBox(height: height * 0.02),
                          Row(
                            children: [
                              const Icon(Icons.circle,
                                  color: Colors.green, size: 15),
                              const SizedBox(width: 5),
                              Text(
                                source,
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.circle,
                                  color: Colors.red, size: 15),
                              const SizedBox(width: 5),
                              Text(
                                destination,
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),

                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Column(
                          //       children: [
                          //         Text(
                          //           source.split(',')[0],
                          //           style: GoogleFonts.lato(
                          //               fontWeight: FontWeight.bold,
                          //               fontSize: 16),
                          //         ),
                          //         Text(source.split(',')[1]),
                          //       ],
                          //     ),
                          //     const Icon(Icons.arrow_right_alt_outlined),
                          //     Column(
                          //       children: [
                          //         Text(
                          //           destination.split(',')[0],
                          //           style: GoogleFonts.lato(
                          //               fontWeight: FontWeight.bold,
                          //               fontSize: 16),
                          //         ),
                          //         Text(destination.split(',')[1]),
                          //       ],
                          //     )
                          //   ],
                          // ),
                          Divider(),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/product.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                    SizedBox(
                                      width: width * 0.05,
                                    ),
                                    Text(
                                      material,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/quantity.png',
                                      height: 20,
                                      width: 20,
                                    ),
                                    SizedBox(
                                      width: width * 0.05,
                                    ),
                                    Text(
                                      "$quantity Tons",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          Divider(),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/rupee-indian.png',
                                height: 20,
                                width: 20,
                              ),
                              Text(expectedPrice,
                                  style: GoogleFonts.lato(fontSize: 18)),
                              Text(priceunit == 'tonne' ? " per" : '',
                                  style: TextStyle(fontSize: 18)),
                              SizedBox(
                                width: width * 0.02,
                              ),
                              Text(priceunit,
                                  style: GoogleFonts.lato(fontSize: 18)),
                            ],
                          )
                        ],
                      )),
                  SizedBox(
                    height: height * 0.02,
                  ),
                ]),
              )),
        ));
  }

  Future<bool> onConfirmBid(PostModal posts, TruckModal truckModal) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            contentPadding: const EdgeInsets.only(top: 10.0),
            content: SizedBox(
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Text(
                            "Book Truck",
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 20,
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: 40,
                            width: 40,
                            child: FittedBox(
                              child: FloatingActionButton(
                                elevation: 0,
                                backgroundColor: Colors.blueGrey,
                                onPressed: () => Navigator.pop(context, 1),
                                child: const Icon(Icons.close),
                              ),
                            ),
                          )
                        ],
                      )),
                  const SizedBox(
                    height: 5.0,
                  ),
                  const Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Container(
                        alignment: Alignment.center,
                        height: 100,
                        child: const Text("Book truck for your selected load.",
                            style:
                                TextStyle(fontFamily: 'Oswald', fontSize: 18))),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                    decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12.0),
                          bottomRight: Radius.circular(12.0)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              Navigator.pop(context);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text("Cancel",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              !isLoading
                                  ? callFunction(posts, truckModal)
                                  : Fluttertoast.showToast(msg: "Please wait");
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Text("Bid Now!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
    return Future.value(false);
  }

  callFunction(PostModal posts, TruckModal truckModal) async {
    var ref = posts.postid;

    var id = bidRef.doc().id;
    setState(() {
      isLoading = true;
    });
    try {
      await bidRef.doc(id).set({
        'rate': "",
        'remarks': "",
        'bidtime': Jiffy(DateTime.now()).yMMMMEEEEdjm,
        'biduserid': UserService().currentUid(),
        'bidresponse': "",
        'loadid': posts.postid,
        'loadpostid': posts.ownerId,
        'truckid': truckModal.id,
        'truckownerid': truckModal.ownerId,
        'negotiateprice': posts.expectedprice,
        'id': id,
        'loaderimage': false,
        'truckimage': false,
        'bid': true,
        'bidid': UserService().currentUid(),
        "truckposttime": truckModal.truckposttime,
      });
    } catch (e) {
      print(e);
    }
    await postRef.doc(posts.postid).update({
      'loadorderstatus': "InProgress",
    });
    await bidRef.doc(id).collection('bidmessage').doc().set({
      'rate': posts.expectedprice,
      'bidtime': FieldValue.serverTimestamp(),
      'biduserid': UserService().currentUid(),
      'type': 'text'
    });

    Navigator.push(context,
        MaterialPageRoute(builder: (context) => OrderPostConfirmed(ref!)));
    setState(() {
      isLoading = false;
    });
  }

  Widget loadbutton() {
    return Padding(
      padding: EdgeInsets.only(left: 10, right: 10, top: 20),
      child: RaisedButton(
          color: Constants.maincolor,
          onPressed: () async {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => PostLoad()));
          },
          child: Container(
              height: 45,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Post a new load",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white)
                ],
              ))),
    );
  }
}

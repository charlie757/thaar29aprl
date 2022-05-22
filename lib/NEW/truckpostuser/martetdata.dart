import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:thaartransport/addnewload/PostLoad.dart';
import 'package:thaartransport/addnewload/orderpostconfirmed.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/truckmodal.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/widget/indicatiors.dart';

class Markettruckdata extends StatefulWidget {
  TruckModal truckModal;
  Markettruckdata(this.truckModal);

  @override
  State<Markettruckdata> createState() => _MarkettruckdataState();
}

class _MarkettruckdataState extends State<Markettruckdata>
    with WidgetsBindingObserver {
  int differenceinmin = 0;
  int checkdifference = 0;
  int differenceinsec = 0;
  bool isLoading = false;
  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (state == AppLifecycleState.paused) {
      print('state1');
      timerFunction();
    } else if (state == AppLifecycleState.inactive) {
      print('state2');
      timerFunction();
    } else if (state == AppLifecycleState.resumed) {
      timerFunction();
      print('state3');
    } else if (state == AppLifecycleState.detached) {
      timerFunction();
      print('state4');
    }
  }

  timerFunction() {
    final currenttime = DateTime.now();
    final backenddatehours =
        DateTime.parse(widget.truckModal.expiretruck.toString());
    final differencehours = backenddatehours.difference(currenttime).inHours;
    checkdifference = differencehours >= 1 ? differencehours : 1;

    differenceinmin = backenddatehours.difference(currenttime).inMinutes;
    final checkdifferenceinmin =
        differenceinmin >= 60 ? checkdifference : differenceinmin;

    differenceinsec = backenddatehours.difference(currenttime).inSeconds;
    final checkdifferenceinsec = differenceinsec >= 1
        ? differenceinmin
        : differenceinsec <= 1
            ? 0
            : differenceinsec;

    checkdifferenceinsec == 1 ||
            checkdifferenceinsec <= 1 ||
            checkdifferenceinsec == 0
        ? truckRef.doc(widget.truckModal.id).update({'truckstatus': 'Expired'})
        : null;

    print("expiretime ${widget.truckModal.expiretruck}");
    print("checkdifferenceinsec $checkdifferenceinsec");
    print("checkdifference $checkdifference");
  }

  @override
  Widget build(BuildContext context) {
    timerFunction();
    return StreamBuilder(
        stream: usersRef.doc(widget.truckModal.ownerId).snapshots(),
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
                  widget.truckModal.lorrynumber.toString(),
                  widget.truckModal.sourcelocation.toString(),
                  widget.truckModal.destinationlocation ?? "".toString(),
                  widget.truckModal.capacity.toString(),
                  users,
                  // truckModal.truckloadstatus.toString(),
                  widget.truckModal.expiretruck.toString(),
                  widget.truckModal.routes!,
                  widget.truckModal,
                ),
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

  Widget showTruckinMarket(
    String truckno,
    String sourcelocation,
    String destinationlocation,
    String capacity,
    UserModel users,
    // String truckloadstatus,
    String expireTime,
    List routes,
    TruckModal truckModal,
  ) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

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
                          topRight: Radius.circular(15))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                              width: 110,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: differenceinmin >= 60
                                      ? Constants.btnBG
                                      : differenceinsec >= 1
                                          ? Colors.red
                                          : Colors.orange,
                                  border: Border.all(),
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(15),
                                      topRight: Radius.circular(15))),
                              child: Text.rich(TextSpan(
                                text: "Expire In\n",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 16),
                                children: [
                                  TextSpan(
                                      text: differenceinmin >= 60
                                          ? checkdifference.toString()
                                          : differenceinsec >= 1
                                              ? differenceinmin.toString()
                                              : differenceinsec.toString(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17,
                                          color: Colors.white),
                                      children: [
                                        TextSpan(
                                            text: differenceinmin >= 60
                                                ? " Hours"
                                                : differenceinsec >= 1
                                                    ? " Min"
                                                    : " Sec",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 15,
                                                color: Colors.white))
                                      ]),
                                ],
                              )))
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          leading: Image.asset(
                            'assets/images/truckpost.jpeg',
                            height: 45,
                            width: 45,
                          ),
                          title: Text(
                            truckno,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            truckModal.truckposttime.toString().split(',')[1] +
                                truckModal.truckposttime
                                    .toString()
                                    .split(',')[2],
                            style: const TextStyle(),
                          ),
                        ),
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
                                style: const TextStyle(fontSize: 15),
                              )
                            ],
                          )),
                      const SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Truck Capacity",
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "$capacity tonne",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                            Container(
                                height: 30,
                                child:
                                    const VerticalDivider(color: Colors.black)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Already Loaded",
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "${truckModal.alcapacity} tonne",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                            Container(
                                height: 30,
                                child:
                                    const VerticalDivider(color: Colors.black)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Left Capacity",
                                  style: TextStyle(fontSize: 12),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  "${truckModal.leftcapacity} tonne",
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15,
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
                                    height: 15,
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
                                        selectload(truckModal, users);
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
                    leading: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(100.0)),
                      child: CachedNetworkImage(
                          height: 50,
                          width: 50,
                          imageUrl: users.photourl.toString(),
                          placeholder: (context, url) => Transform.scale(
                                scale: 0.4,
                                child: CircularProgressIndicator(
                                  color: Constants.kYellowColor,
                                  strokeWidth: 3,
                                ),
                              ),
                          errorWidget: (context, url, error) => Container(
                              height: 40,
                              width: 40,
                              child: Image.asset(
                                  'assets/images/account_profile.png')),
                          fit: BoxFit.cover),
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

  selectload(TruckModal truckModal, UserModel userModel) {
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
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 10),
                  child: _buildloadbid(truckModal, userModel),
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
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SingleChildScrollView(
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
                          child: GridView.builder(
                              itemCount: routes.length,
                              scrollDirection: Axis.vertical,
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisSpacing: 5,
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 5),
                              itemBuilder: (context, index) {
                                return Card(
                                  child: Container(
                                    height: 40,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.location_city,
                                          color: Colors.blue,
                                        ),
                                        Text(
                                          routes[index],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600),
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              })

                          // child: Wrap(
                          //   children:
                          //       routes.map((e) => Chip(label: Text(e))).toList(),
                          // ),
                          ),
                    ],
                  ),
                ),
              );
            }),
          );
        });
  }

  _buildloadbid(TruckModal truckModal, UserModel userModel) {
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
                              truckModal,
                              userModel);
                        })
                  ],
                )
              ],
            ));
          });
    });
  }

  buildloadbid(TruckModal truckModal, UserModel userModel) {
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
                              truckModal,
                              userModel);
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
      TruckModal truckModal,
      UserModel userModel) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return InkWell(
        onTap: () async {
          onConfirmBid(posts, truckModal, userModel);
        },
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Card(
              // color: Colors.red,
              elevation: 2,
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

  Future<bool> onConfirmBid(
      PostModal posts, TruckModal truckModal, UserModel userModel) {
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
                                  ? callFunction(posts, truckModal, userModel)
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

  callFunction(
      PostModal posts, TruckModal truckModal, UserModel userModel) async {
    var ref = posts.postid;

    var id = bidRef.doc().id;
    setState(() {
      isLoading = true;
    });
    try {
      await bidRef.doc(id).set({
        'rate': posts.expectedprice,
        'bidtime': FieldValue.serverTimestamp(),
        'biduserid': UserService().currentUid(),
        'bidresponse': "",
        'notificationuser': UserService().currentUid(),
        'loadid': posts.postid,
        'loadpostid': posts.ownerId,
        'truckid': truckModal.id,
        'truckownerid': truckModal.ownerId,
        'negotiateprice': posts.expectedprice,
        'id': id,
        'loaderimage': false,
        'truckimage': false,
        'postuserfeedback': '',
        'bid': true,
        'bidid': truckModal.ownerId,
        "truckposttime": truckModal.truckposttime,
      });
    } catch (e) {
      print(e);
    }

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

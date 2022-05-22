import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'package:path/path.dart' as p;
import 'package:blinking_text/blinking_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/truckmodal.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/screens/chat/chat.dart';
import 'package:thaartransport/modal/bidmodal.dart';
import 'package:thaartransport/screens/myorders/vieworder.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/widget/flickerwidget.dart';
import 'package:thaartransport/widget/indicatiors.dart';
import 'package:thaartransport/widget/internetmsg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../NEW/truckpostuser/truckhomepage.dart';

class OnGoingOrders extends StatefulWidget {
  const OnGoingOrders({Key? key}) : super(key: key);

  @override
  _OnGoingOrdersState createState() => _OnGoingOrdersState();
}

class _OnGoingOrdersState extends State<OnGoingOrders> {
  TextEditingController rate = TextEditingController();

  final bidMessageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool validate = false;
  bool bidloading = false;

  @override
  void dispose() {
    super.dispose();
  }

  String? imgurl1;
  String? imgurl2;
  File? image2;
  File? image1;

  bool submit = false;

  var count = "";

  int amount = 0;
  retriveCurrentUser() {
    usersRef.doc(UserService().currentUid()).get().then((value) {
      if (mounted) {}

      amount = value.get('amount');
      print(amount);
    });
  }

  List biddocs = [];
  bidaceceptcount() async {
    await bidRef
        .where('truckownerid', isEqualTo: UserService().currentUid())
        .where('bidresponse', isEqualTo: 'Bid Accepted')
        .get()
        .then((value) {
      biddocs = value.docs;
      print("bidaceceptcount ${biddocs.length}");
    });
  }

  // fetchtruckidfrombid() async {
  //   bidRef
  //       .where('truckownerid', isEqualTo: UserService().currentUid())
  //       .get()
  //       .then((value) {
  //     bidtruckdoc = value.docs;
  //     bidtruckdoc.forEach((element) {
  //       truckdata(element['truckid'], element['truckposttime']);
  //     });
  //   });
  // }

  // String truckid = '';
  // List truckdoc = [];
  // List bidtruckdoc = [];
  // truckdata(String ownerid, String truckposttime) async {
  //   await truckRef.where('id', isEqualTo: ownerid).get().then((value) {
  //     truckdoc = value.docs;
  //     truckdoc.forEach((element) {
  //       truckid = element['id'];
  //       truckchangesdata(element['id'], truckposttime);
  //       print(truckid);
  //     });
  //   });
  // }

  // truckchangesdata(String truckid, String trucktime) async {
  //   await truckRef
  //       .doc(truckid)
  //       .collection('changeslorry')
  //       .where('truckposttime', isEqualTo: trucktime)
  //       .get()
  //       .then((value) {
  //     truckchangesdoc = value.docs;
  //     truckchangesdoc.forEach((element) {
  //       print(element['truckposttime']);
  //     });
  //   });
  // }

  // List truckchangesdoc = [];

  @override
  void initState() {
    bidaceceptcount();
    retriveCurrentUser();
    // fetchtruckidfrombid();
    super.initState();
  }

  bool choice1 = true;
  bool choice2 = false;
  bool choice3 = false;
  bool choice4 = false;
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    return !isOnline
        ? internetchecker()
        : Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ChoiceChip(
                        label: Text('Waiting'),
                        selected: choice1,
                        labelStyle: TextStyle(
                            color:
                                choice1 == false ? Colors.black : Colors.white),
                        selectedColor: Colors.orange,
                        onSelected: (val) {
                          setState(() {
                            choice1 = val;
                            choice2 = false;
                            choice3 = false;
                            choice4 = false;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: Text('received'),
                        selected: choice2,
                        labelStyle: TextStyle(
                            color:
                                choice2 == false ? Colors.black : Colors.white),
                        selectedColor: Colors.orange,
                        onSelected: (val) {
                          setState(() {
                            choice2 = val;
                            choice1 = false;
                            choice3 = false;
                            choice4 = false;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: Text('accepted'),
                        selected: choice3,
                        selectedColor: Colors.orange,
                        labelStyle: TextStyle(
                            color:
                                choice3 == false ? Colors.black : Colors.white),
                        onSelected: (val) {
                          setState(() {
                            choice3 = val;
                            choice1 = false;
                            choice2 = false;
                            choice4 = false;
                          });
                        },
                      ),
                      ChoiceChip(
                        label: Text('rejected'),
                        selected: choice4,
                        selectedColor: Colors.orange,
                        labelStyle: TextStyle(
                            color:
                                choice4 == false ? Colors.black : Colors.white),
                        onSelected: (val) {
                          setState(() {
                            choice4 = val;
                            choice1 = false;
                            choice2 = false;
                            choice3 = false;
                          });
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ScrollWrapper(
                      scrollController: scrollController,
                      scrollToTopCurve: Curves.easeInOut,
                      promptAlignment: Alignment.bottomRight,
                      child: choice1 == true
                          ? waitingbid()
                          : choice2 == true
                              ? receivedbid()
                              : choice3 == true
                                  ? acceptedbid()
                                  : rejectedbid()),
                ),
              ],
            ),
          );
  }

  Widget acceptedbid() {
    return StreamBuilder<QuerySnapshot>(
        stream: bidRef
            .where('truckownerid', isEqualTo: UserService().currentUid())
            .where('bidresponse', isEqualTo: "Bid Accepted")
            .orderBy('bidtime', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Somthing went Wrong");
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return FlickerWidget();
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child:
                    Text("No accepted bids", style: TextStyle(fontSize: 18)));
          }
          return RefreshIndicator(
            color: Colors.white,
            backgroundColor: Constants.kYellowColor,
            triggerMode: RefreshIndicatorTriggerMode.anywhere,
            onRefresh: () async {
              Future.delayed(const Duration(seconds: 5));
              bidaceceptcount();
              setState(() {});
            },
            child: ListView.builder(
                controller: scrollController,
                shrinkWrap: true,
                padding: const EdgeInsets.only(top: 15),
                physics: const ScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  BidModal bidpost = BidModal.fromJson(
                      snapshot.data!.docs[index].data()
                          as Map<String, dynamic>);
                  return getloadid(bidpost);
                }),
          );
        });
  }

  Widget receivedbid() {
    return StreamBuilder<QuerySnapshot>(
        stream: bidRef
            .where('truckownerid', isEqualTo: UserService().currentUid())
            .where('biduserid', isNotEqualTo: UserService().currentUid())
            .where('bidresponse', isEqualTo: '')
            .orderBy('biduserid')
            .orderBy('bidtime', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Somthing went Wrong");
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return FlickerWidget();
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("No receive bids", style: TextStyle(fontSize: 18)));
          }
          return RefreshIndicator(
              color: Colors.white,
              backgroundColor: Constants.kYellowColor,
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              onRefresh: () async {
                Future.delayed(const Duration(seconds: 5));
                bidaceceptcount();
                setState(() {});
              },
              child: ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 15),
                  physics: const ScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    BidModal bidpost = BidModal.fromJson(
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>);
                    return getloadid(bidpost);
                  }));
        });
  }

  Widget waitingbid() {
    return StreamBuilder<QuerySnapshot>(
        stream: bidRef
            .where('truckownerid', isEqualTo: UserService().currentUid())
            .where('biduserid', isEqualTo: UserService().currentUid())
            .where('bidresponse', isEqualTo: '')
            .orderBy('bidtime', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Somthing went Wrong");
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return FlickerWidget();
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("No Bids", style: TextStyle(fontSize: 18)));
          }
          return RefreshIndicator(
              color: Colors.white,
              backgroundColor: Constants.kYellowColor,
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              onRefresh: () async {
                Future.delayed(const Duration(seconds: 5));
                bidaceceptcount();
                setState(() {});
              },
              child: ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 15),
                  physics: const ScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    BidModal bidpost = BidModal.fromJson(
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>);
                    return getloadid(bidpost);
                  }));
        });
  }

  Widget rejectedbid() {
    return StreamBuilder<QuerySnapshot>(
        stream: bidRef
            .where('truckownerid', isEqualTo: UserService().currentUid())
            .where('bidresponse', isEqualTo: "Bid Rejected")
            .orderBy('bidtime', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Somthing went Wrong");
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return FlickerWidget();
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(
                child:
                    Text("No rejected bids", style: TextStyle(fontSize: 18)));
          }
          return RefreshIndicator(
              color: Colors.white,
              backgroundColor: Constants.kYellowColor,
              triggerMode: RefreshIndicatorTriggerMode.anywhere,
              onRefresh: () async {
                Future.delayed(const Duration(seconds: 5));
                bidaceceptcount();
                setState(() {});
              },
              child: ListView.builder(
                  controller: scrollController,
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 15),
                  physics: const ScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    BidModal bidpost = BidModal.fromJson(
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>);
                    return getloadid(bidpost);
                  }));
        });
  }

  Widget getloadid(BidModal bidpost) {
    return StreamBuilder(
        stream: truckRef.doc(bidpost.truckid).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot1) {
          if (snapshot1.hasError) {
            return const Text("Somthing went Wrong");
          } else if (snapshot1.connectionState == ConnectionState.waiting) {
            return Center();
          }

          TruckModal truckModal = TruckModal.fromJson(
              snapshot1.data!.data() as Map<String, dynamic>);
          return StreamBuilder<QuerySnapshot>(
              stream: postRef
                  .where('postid', isEqualTo: bidpost.loadid)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot2) {
                if (snapshot2.hasError) {
                  return const Text("Somthing went Wrong");
                } else if (snapshot2.connectionState ==
                    ConnectionState.waiting) {
                  return Center();
                }
                return ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(0),
                    physics: const ScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot2.data!.docs.length,
                    itemBuilder: (context, int index) {
                      PostModal posts = PostModal.fromJson(
                          snapshot2.data!.docs[index].data()
                              as Map<String, dynamic>);

                      return buidUser(posts, bidpost, truckModal);
                    });
              });
        });
  }

  Widget buidUser(PostModal posts, BidModal bidpost, TruckModal truckModal) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return StreamBuilder(
        stream: usersRef.doc(posts.ownerId).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Somthing went Wrong");
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center();
          }
          UserModel users =
              UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
          return Column(
            children: [
              InkWell(
                onTap: () {
                  bidpost.bidresponse == "Bid Accepted"
                      ? _onCompletedBid(bidpost, posts, users)
                      : null;
                  // bidpost.bidresponse == ""
                  //     ? biddocs.length >= 5
                  //         ? amount < 500
                  //             ? addMoneyAlert(context)
                  //             : Navigator.push(
                  //                 context,
                  //                 MaterialPageRoute(
                  //                     builder: (context) =>
                  //                         ViewOrder(users, posts, bidpost)))
                  //         : Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //                 builder: (context) =>
                  //                     ViewOrder(users, posts, bidpost)))
                  //     : Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) =>
                  //                 ViewOrder(users, posts, bidpost)));
                },
                child: Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        Container(
                          // height: 20,
                          padding:
                              const EdgeInsets.only(left: 8, right: 8, top: 5),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        const Text(
                                          "posted on:",
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        const SizedBox(
                                          width: 2,
                                        ),
                                        Text(posts.loadposttime!
                                                .split(',')[1]
                                                .toString() +
                                            posts.loadposttime!
                                                .split(',')[2]
                                                .toString()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.02),
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.center,
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
                                    posts.sourcelocation!,
                                    style: const TextStyle(fontSize: 17),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 7,
                              ),
                              Row(
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
                                    posts.destinationlocation!,
                                    style: const TextStyle(fontSize: 17),
                                  )
                                ],
                              ),
                              Divider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          posts.material!,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        )
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          "${posts.quantity} Tons",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("Original Amount",
                                          style: TextStyle()),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/rupee-indian.png',
                                            height: 16,
                                            width: 16,
                                          ),
                                          Text(posts.expectedprice!,
                                              style: GoogleFonts.lato(
                                                  fontSize: 18)),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                              posts.priceunit == 'tonne'
                                                  ? "per ${posts.priceunit}"
                                                  : posts.priceunit!,
                                              style: const TextStyle(
                                                  fontSize: 17)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Bidding Amount",
                                        style: TextStyle(),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/images/rupee-indian.png',
                                            height: 16,
                                            width: 16,
                                          ),
                                          BlinkText(bidpost.rate!,
                                              endColor: Colors.green,
                                              beginColor: Constants.thaartheme,
                                              style: GoogleFonts.lato(
                                                  fontSize: 18)),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          BlinkText(
                                              posts.priceunit == 'tonne'
                                                  ? "per ${posts.priceunit}"
                                                  : posts.priceunit!,
                                              endColor: Colors.green,
                                              beginColor: Constants.thaartheme,
                                              style: const TextStyle(
                                                  fontSize: 17)),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              bidpost.biduserid == UserService().currentUid() &&
                                      bidpost.bidresponse == ""
                                  ? Container(
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.access_time_filled_sharp,
                                            color: Colors.orange,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Waiting for response",
                                            style: TextStyle(
                                                color: Colors.orange,
                                                fontSize: 20),
                                          )
                                        ],
                                      ),
                                    )
                                  : bidpost.bidresponse == "Bid Accepted"
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: const [
                                                Icon(
                                                  Icons
                                                      .check_circle_outline_sharp,
                                                  color: Colors.green,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  "Bid Accepted",
                                                  style: TextStyle(
                                                      color: Colors.green,
                                                      fontSize: 20),
                                                )
                                              ],
                                            ),
                                            FlatButton(
                                                color: Colors.blue,
                                                textColor: Colors.white,
                                                onPressed: () {
                                                  _onCompletedBid(
                                                      bidpost, posts, users);
                                                },
                                                child:
                                                    const Text("Bid Complete"))
                                          ],
                                        )
                                      : bidpost.biduserid !=
                                                  UserService().currentUid() &&
                                              bidpost.bidresponse == ""
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                          textStyle:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                          primary: Constants
                                                              .thaartheme),
                                                      onPressed: () async {
                                                        bidaceceptcount();
                                                        await postUser(bidpost);
                                                        await truckUser(
                                                            bidpost);
                                                        await postbidCount(
                                                            posts);
                                                        await truckbidCount(
                                                            truckModal);
                                                        await getbidacceptcount(
                                                            posts);
                                                        await getbidcompletecount(
                                                            posts);
                                                        checkbidacpt ==
                                                                    "Bid Accepted" ||
                                                                checkbidcomp ==
                                                                    "Bid Completed"
                                                            ? Fluttertoast.showToast(
                                                                msg:
                                                                    "${users.username} unable to continue this bid",
                                                                fontSize: 17,
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                backgroundColor:
                                                                    Constants
                                                                        .thaartheme)
                                                            : bidAccepted(
                                                                posts,
                                                                truckModal,
                                                                bidpost,
                                                                users);
                                                      },
                                                      child: const Text(
                                                          "Accept Bid")),
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                Expanded(
                                                  child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                              primary: Constants
                                                                  .alert),
                                                      onPressed: () async {
                                                        bidaceceptcount();
                                                        await postUser(bidpost);
                                                        await truckUser(
                                                            bidpost);
                                                        await postbidCount(
                                                            posts);
                                                        await truckbidCount(
                                                            truckModal);
                                                        await getbidacceptcount(
                                                            posts);
                                                        await getbidcompletecount(
                                                            posts);

                                                        checkbidacpt ==
                                                                    "Bid Accepted" ||
                                                                checkbidcomp ==
                                                                    "Bid Completed"
                                                            ? Fluttertoast.showToast(
                                                                msg:
                                                                    "${users.username} unable to continue this bid",
                                                                fontSize: 17,
                                                                gravity: ToastGravity
                                                                    .SNACKBAR,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                backgroundColor:
                                                                    Constants
                                                                        .thaartheme)
                                                            : _onRejectBid(
                                                                bidpost,
                                                                users,
                                                                posts);
                                                      },
                                                      child: const Text(
                                                          "Reject Bid")),
                                                )
                                              ],
                                            )
                                          : bidpost.bidresponse ==
                                                  "Bid Rejected"
                                              ? Container()
                                              : Container(),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Card(
                            elevation: 0,
                            color: const Color.fromARGB(31, 141, 126, 126),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(100.0)),
                                child: CachedNetworkImage(
                                    height: 50,
                                    width: 50,
                                    imageUrl: users.photourl.toString(),
                                    placeholder: (context, url) =>
                                        Transform.scale(
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
                                users.username == ''
                                    ? ''
                                    : users.username.toString(),
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w800),
                              ),
                              trailing: bidpost.bidresponse == "Bid Accepted"
                                  ? InkWell(
                                      onTap: () {
                                        callNow(users);
                                      },
                                      child: Container(
                                          width: 130,
                                          height: 35,
                                          color: Constants.thaartheme,
                                          alignment: Alignment.center,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: const [
                                              Icon(
                                                Icons.call,
                                                color: Colors.white,
                                              ),
                                              Text(
                                                "CALL NOW",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )
                                            ],
                                          )),
                                    )
                                  : bidpost.bidresponse == "Bid Rejected"
                                      ? Container(
                                          width: 130,
                                          height: 35,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Constants.alert)),
                                          child: Text(
                                            'Bid Rejected',
                                            style: TextStyle(
                                                color: Constants.alert,
                                                fontSize: 17),
                                          ),
                                        )
                                      : bidpost.bidresponse == ""
                                          ? Container(
                                              width: 130,
                                              height: 35,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors
                                                          .indigo.shade900)),
                                              child: const Text(
                                                "Bidding",
                                                style: TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 17),
                                              ),
                                            )
                                          : Container(
                                              width: 130,
                                              height: 35,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors
                                                          .blue.shade900)),
                                              child: const Text(
                                                'Bid Completed',
                                                style: TextStyle(
                                                    color: Color(0XFF142438),
                                                    fontSize: 17),
                                              ),
                                            ),
                            )),
                      ],
                    )),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          );
        });
  }

  int postuserAmt = 0;
  int truckuserAmt = 0;
  List postbidcount = [];
  List truckbidcount = [];

  postUser(BidModal bidpost) async {
    await usersRef.doc(bidpost.loadpostid).get().then((value) {
      postuserAmt = value.get('amount');
      print("postuserAmt$postuserAmt");
    });
  }

  truckUser(BidModal bidpost) async {
    await usersRef.doc(bidpost.truckownerid).get().then((value) {
      truckuserAmt = value.get('amount');
      print("truckuserAmt$truckuserAmt");
    });
  }

  postbidCount(PostModal posts) async {
    await bidRef
        .where('loadpostid', isEqualTo: posts.ownerId)
        .where('bidresponse', isEqualTo: "Bid Accepted")
        .get()
        .then((value) {
      postbidcount = value.docs;
      print("postbidcount${postbidcount.length}");
    });
  }

  truckbidCount(TruckModal truckModal) async {
    await bidRef
        .where('truckownerid', isEqualTo: truckModal.id)
        .where('bidresponse', isEqualTo: "Bid Accepted")
        .get()
        .then((value) {
      truckbidcount = value.docs;
      print("truckbidcount${truckbidcount.length}");
    });
  }

  getbidacceptcount(PostModal posts) async {
    await bidRef
        .where('loadid', isEqualTo: posts.postid)
        .where('bidresponse', isEqualTo: 'Bid Accepted')
        .get()
        .then((value) {
      getbidaccpetcountList = value.docs;
      print("getbidaccpetcountList${getbidaccpetcountList.length}");
      getbidaccpetcountList.forEach((element) {
        checkbidacpt = element['bidresponse'];

        print("checkbidacpt $checkbidacpt");
      });
    });
  }

  getbidcompletecount(PostModal posts) async {
    await bidRef
        .where('loadid', isEqualTo: posts.postid)
        .where('bidresponse', isEqualTo: 'Bid Completed')
        .get()
        .then((value) {
      getbidcompletecountList = value.docs;

      print("getbidcompletecountList${getbidcompletecountList.length}");
      getbidcompletecountList.forEach((element) {
        checkbidcomp = element['bidresponse'];

        print("checkbidcomp $checkbidcomp");
      });
    });
  }

  List getbidaccpetcountList = [];
  String checkbidacpt = '';
  List getbidcompletecountList = [];
  String checkbidcomp = '';
  bidAccepted(PostModal posts, TruckModal truckModal, BidModal bidpost,
      UserModel users) async {
    biddocs.length >= 5
        ? amount < 100
            ? addMoneyAlert(context)
            : callacptFunction(posts, truckModal, bidpost, users)
        : callacptFunction(posts, truckModal, bidpost, users);
  }

  callacptFunction(PostModal posts, TruckModal truckModal, BidModal bidpost,
      UserModel users) async {
    final amt = postuserAmt - 100;
    final truckamt = truckuserAmt - 100;
    int leftcapacity = int.parse(truckModal.leftcapacity.toString());
    int postcapacity = int.parse(posts.quantity.toString());
    final intcapacity = max(0, leftcapacity - postcapacity);

    String capacity = intcapacity.toString();
    int alreadyload = int.parse(truckModal.alcapacity.toString());
    final intalreadycap = alreadyload + postcapacity;
    String alreadyloaded = intalreadycap.toString();
    print(leftcapacity);
    print(postcapacity);
    print(capacity);

    try {
      postbidcount.length >= 5
          ? await usersRef.doc(posts.ownerId).update({'amount': amt})
          : null;
      truckbidcount.length >= 5
          ? await usersRef.doc(truckModal.id).update({'amount': truckamt})
          : null;
      await bidRef.doc(bidpost.id).update({
        'bidresponse': "Bid Accepted",
        'bidtime': FieldValue.serverTimestamp(),
        'shipperpmt': postbidcount.length >= 5 ? amt.toString() : '',
        'transpmt': truckbidcount.length >= 5 ? truckamt.toString() : '',
        'bidid': posts.ownerId.toString(),
        'notificationuser': UserService().currentUid(),
      });
      await postRef.doc(posts.postid).update({
        'loadstatus': "InTransit",
        'loadorderstatus': "InTransit",
      });
      await truckRef.doc(bidpost.truckid).update({
        'leftcapacity': capacity.toString(),
        "alcapacity": alreadyloaded.toString()
      });

      await truckRef
          .doc(bidpost.truckid)
          .collection('changeslorry')
          .where('truckposttime', isEqualTo: bidpost.truckposttime)
          .get()
          .then((value) {
        List doc = value.docs;
        doc.forEach((element) {
          print(element['id']);
          truckRef
              .doc(bidpost.truckid)
              .collection('changeslorry')
              .doc(element['id'])
              .update({
            'leftcapacity': capacity.toString(),
            'alcapacity': alreadyloaded.toString()
          });
        });
      });
    } catch (e) {
      print(e);
      bidloading = false;
    }
  }

  _onRejectBid(BidModal bidpost, UserModel users, PostModal posts) async {
    try {
      print(posts.ownerId);
      await bidRef.doc(bidpost.id).update({
        'bidresponse': "Bid Rejected",
        'bidtime': FieldValue.serverTimestamp(),
        'bidid': posts.ownerId.toString(),
        'notificationuser': UserService().currentUid(),
      });
    } catch (e) {
      print(e);
    }
  }

  callNow(UserModel users) async {
    launch('tel://$user.usernumber!');
    await FlutterPhoneDirectCaller.callNumber(users.usernumber!);
  }

  addMoneyAlert(
    BuildContext context,
  ) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (_, __, ___) {
        return Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              Container(
                  width: 330,
                  margin: EdgeInsets.all(10.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                  padding: const EdgeInsets.only(
                      top: 25, left: 25, right: 25, bottom: 20),
                  child: Column(
                    children: [
                      const Text(
                        "Payment Alert",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "You do not have sufficient amount for bid.",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: DialogButton(
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                // Navigator.push(context,
                                //     MaterialPageRoute(builder: (context) => TruckHomePage(2)));
                              },
                              color: Constants.alert,
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: DialogButton(
                              child: const Text(
                                "Add Money",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            TruckHomePage(2)));
                              },
                              color: Constants.thaartheme,
                            ),
                          )
                        ],
                      )
                    ],
                  ))
            ]));
      },
      transitionBuilder: (_, anim, __, child) {
        Tween<Offset> tween;
        if (anim.status == AnimationStatus.reverse) {
          tween = Tween(begin: Offset(-1, 0), end: Offset.zero);
        } else {
          tween = Tween(begin: Offset(1, 0), end: Offset.zero);
        }

        return SlideTransition(
          position: tween.animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: child,
          ),
        );
      },
    );
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          value,
          style: const TextStyle(
            fontSize: 16,
          ),
        )));
  }

  _onCompletedBid(BidModal bidpost, PostModal posts, UserModel users) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                color: const Color(0xFF737373),
                // height: 300,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: _buildCompletedBidSheet(bidpost, posts, users),
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

  Widget _buildCompletedBidSheet(
      BidModal bidpost, PostModal posts, UserModel users) {
    var now = DateTime.now();
    var month = now.month.toString().padLeft(2, '0');
    var day = now.day.toString().padLeft(2, '0');
    var bidCompletedTime = '${now.year}-$month-$day ${now.hour}:${now.minute}';

    return StatefulBuilder(builder: (context, setstate) {
      return WillPopScope(
        onWillPop: () async {
          clearController();
          return true;
        },
        child: SingleChildScrollView(
            child: Wrap(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Update Bid response",
                      style: GoogleFonts.ibmPlexSerif(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                          clearController();
                        },
                        icon: const Icon(Icons.close))
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Text("Bid complete time",
                    style: GoogleFonts.lato(fontSize: 20)),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  bidCompletedTime.toString(),
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(
                  height: 10,
                ),
                Card(
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextFormField(
                      controller: bidMessageController,
                      inputFormatters: [],
                      maxLength: 100,
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        hintText: "Write something about bid complete..!",
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text("Please share the proof",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    InkWell(
                        onTap: () async {
                          try {
                            final image = await ImagePicker()
                                .pickImage(source: ImageSource.camera);
                            if (image == null) return;

                            final imageTemporary = File(image.path);
                            setstate(() {});
                            setState(() {
                              image1 = imageTemporary;
                            });
                          } on PlatformException catch (e) {
                            print("Failed to pick image: $e");
                          }

                          final ref1 = FirebaseStorage.instance
                              .ref()
                              .child('completedProofImages')
                              .child(DateTime.now().toIso8601String() +
                                  p.basename(image1!.path));
                          final result1 =
                              await ref1.putFile(File(image1!.path));
                          imgurl1 = await result1.ref.getDownloadURL();
                        },
                        child: Container(
                          height: 70,
                          width: 80,
                          decoration: BoxDecoration(border: Border.all()),
                          child: image1 != null
                              ? Image.file(image1!, fit: BoxFit.fill)
                              : const Icon(Icons.add),
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                        onTap: () async {
                          try {
                            final image = await ImagePicker()
                                .pickImage(source: ImageSource.camera);
                            if (image == null) return;

                            final imageTemporary = File(image.path);
                            setstate(() {});
                            setState(() {
                              image2 = imageTemporary;
                            });
                          } on PlatformException catch (e) {
                            print("Failed to pick image: $e");
                          }
                          final ref2 = FirebaseStorage.instance
                              .ref()
                              .child('completedProofImages')
                              .child(DateTime.now().toIso8601String() +
                                  p.basename(image2!.path));
                          final result2 =
                              await ref2.putFile(File(image2!.path));
                          imgurl2 = await result2.ref.getDownloadURL();
                        },
                        child: Container(
                          height: 70,
                          width: 80,
                          decoration: BoxDecoration(border: Border.all()),
                          child: image2 != null
                              ? Image.file(
                                  image1!,
                                  fit: BoxFit.fill,
                                )
                              : const Icon(Icons.add),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 20,
                ),
                FlatButton(
                    color: Constants.thaartheme,
                    textColor: Colors.white,
                    onPressed: () async {
                      if (bidMessageController.text.isEmpty) {
                        Fluttertoast.showToast(
                            gravity: ToastGravity.CENTER,
                            msg: 'Please write something');
                      } else if (image1 == null) {
                        Fluttertoast.showToast(
                            gravity: ToastGravity.CENTER,
                            msg: 'Please upload proof image1');
                      } else if (image2 == null) {
                        Fluttertoast.showToast(
                            gravity: ToastGravity.CENTER,
                            msg: 'Please upload proof image2');
                      } else {
                        setstate(() {});
                        setState(() {
                          submit == true;
                        });

                        print(submit);
                        var collectionid = bidRef
                            .doc(bidpost.id)
                            .collection('bidcomplete')
                            .doc();
                        try {
                          setState(() {
                            submit == true;
                          });

                          bidRef
                              .doc(bidpost.id)
                              .collection('bidcomplete')
                              .doc(collectionid.id)
                              .set({
                            'bidresponse': "Bid Completed",
                            'bidcompletedtime': FieldValue.serverTimestamp(),
                            'bidcompletedmsg': bidMessageController.text,
                            'proofimg1': imgurl1,
                            'bidid': posts.ownerId,
                            'proofimg2': imgurl2,
                            'id': collectionid.id
                          }).catchError((e) {
                            print(e);
                            setState(() {
                              submit == false;
                            });
                          });
                          bidRef.doc(bidpost.id).update({
                            'bidresponse': "Bid Completed",
                            'bidid': posts.ownerId.toString(),
                            'notificationuser': UserService().currentUid(),
                          });
                          setState(() {
                            submit == true;
                          });

                          postRef.doc(posts.postid).update({
                            'loadstatus': "Completed",
                            'loadorderstatus': "Completed",
                          }).catchError((e) {
                            print(e);
                            setState(() {
                              submit == false;
                            });
                          });
                          Navigator.pop(context);
                          clearController();

                          setstate(() {});
                          setState(() {
                            submit == false;
                          });

                          print(submit);
                        } catch (e) {
                          setstate(() {});
                          setState(() {
                            submit == false;
                          });
                          print(e);
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 40,
                      alignment: Alignment.center,
                      child: submit == false
                          ? const Text(
                              "SUBMIT",
                              style: TextStyle(fontSize: 18),
                            )
                          : circularProgress(context),
                    ))
              ],
            )
          ],
        )),
      );
    });
  }

  clearController() {
    bidMessageController.clear();
  }
}

import 'dart:math';

import 'package:blinking_text/blinking_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thaartransport/NEW/postloaduser/shipperhomepage.dart';
import 'package:thaartransport/addnewload/orderpostconfirmed.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/bidmodal.dart';
import 'package:thaartransport/modal/truckmodal.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/screens/chat/chat.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../services/userservice.dart';

class getBidResponse extends StatefulWidget {
  BidModal bidpost;
  int amount;
  List bidacptcount;
  PostModal posts;
  getBidResponse(this.bidpost, this.amount, this.bidacptcount, this.posts);

  @override
  State<getBidResponse> createState() => _getBidResponseState();
}

class _getBidResponseState extends State<getBidResponse> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: usersRef
            .where('id', isEqualTo: widget.bidpost.truckownerid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          print(widget.bidpost.truckownerid);
          if (snapshot.hasError) {
            return const Text("Somthing went Wrong");
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center();
          }
          return ListView.builder(
              clipBehavior: Clip.antiAlias,
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              padding: const EdgeInsets.all(0),
              physics: const ScrollPhysics(),
              itemBuilder: (context, index) {
                UserModel user = UserModel.fromJson(
                    snapshot.data!.docs[index].data() as Map<String, dynamic>);
                return details(
                  user,
                );
              });
        });
  }

  Widget details(
    UserModel user,
  ) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return StreamBuilder(
        stream: truckRef
            .doc(widget.bidpost.truckid)
            .collection('changeslorry')
            .where('truckposttime', isEqualTo: widget.bidpost.truckposttime)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Somthing went Wrong");
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center();
          }

          print(widget.bidpost.truckid);
          return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              shrinkWrap: true,
              padding: const EdgeInsets.all(0),
              physics: const ScrollPhysics(),
              itemBuilder: (context, index) {
                TruckModal truckModal = TruckModal.fromJson(
                    snapshot.data!.docs[index].data() as Map<String, dynamic>);

                return Padding(
                  padding: const EdgeInsets.only(left: 5, right: 5, top: 10),
                  child: InkWell(
                    onTap: () async {
                      // widget.bidacptcount.length >= 5
                      //     ? widget.amount < 500
                      //         ? addMoneyAlert(context)
                      //         : Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //                 builder: (context) => Chat(
                      //                     user,
                      //                     widget.posts,
                      //                     widget.bidpost,
                      //                     truckModal),
                      //                 fullscreenDialog: true))
                      //     : Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //                 builder: (context) => Chat(
                      //                     user,
                      //                     widget.posts,
                      //                     widget.bidpost,
                      //                     truckModal),
                      //                 fullscreenDialog: true))
                      //         .then((value) {
                      //         setState(() {});
                      //       });
                    },
                    child: Card(
                        elevation: 5,
                        shape: Border.all(),
                        shadowColor: Colors.cyan,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl: user.photourl!,
                                                height: height,
                                                width: width,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: width * 0.02,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.username!,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 18),
                                              ),
                                              Text(
                                                user.companyname!.isEmpty
                                                    ? ''
                                                    : user.companyname
                                                        .toString(),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    widget.bidpost.bidresponse ==
                                                "Bid Accepted" ||
                                            widget.bidpost.bidresponse ==
                                                "Bid Completed"
                                        ? ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                                primary: Constants.thaartheme),
                                            onPressed: () {
                                              callNow(user);
                                            },
                                            icon: const Icon(Icons.call),
                                            label: const Text("CALL NOW"))
                                        : Container()
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.circle,
                                      color: Colors.green, size: 13),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    truckModal.sourcelocation.toString(),
                                    style: GoogleFonts.lato(fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.circle,
                                      color: Colors.red, size: 13),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    truckModal.destinationlocation.toString(),
                                    style: GoogleFonts.lato(fontSize: 15),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Truck Capacity",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "${truckModal.capacity} tonne",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600),
                                      )
                                    ],
                                  ),
                                  Container(
                                      height: 30,
                                      child: const VerticalDivider(
                                          color: Colors.black)),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      child: const VerticalDivider(
                                          color: Colors.black)),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const Text(
                                    'Biding Amount:',
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/rupee-indian.png',
                                        height: 16,
                                        width: 16,
                                      ),
                                      BlinkText(widget.bidpost.rate!,
                                          beginColor: Constants.thaartheme,
                                          endColor: Colors.green,
                                          style:
                                              GoogleFonts.lato(fontSize: 18)),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      BlinkText(
                                          widget.posts.priceunit == 'tonne'
                                              ? "per ${widget.posts.priceunit}"
                                              : widget.posts.priceunit!,
                                          endColor: Colors.green,
                                          beginColor: Constants.thaartheme,
                                          style: const TextStyle(fontSize: 17))
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        const Icon(
                                          LineIcons.truck,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(
                                          width: 7,
                                        ),
                                        Text(
                                          truckModal.routes!.length.toString(),
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        const Text("Routes")
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      routesSheet(truckModal.routes!);
                                    },
                                    child: Container(
                                        child: NeumorphicIcon(
                                      Icons.arrow_forward,
                                      size: 40,
                                    )),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 15,
                              ),
                              widget.bidpost.biduserid !=
                                          UserService().currentUid() &&
                                      widget.bidpost.bidresponse == ""
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary:
                                                      Constants.thaartheme),
                                              onPressed: () {
                                                bidAccepted(
                                                    widget.posts,
                                                    truckModal,
                                                    widget.bidpost,
                                                    user);
                                              },
                                              child: const Text("Accept Bid")),
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Expanded(
                                          child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  primary: Constants.alert),
                                              onPressed: () {
                                                _onRejectBid(widget.bidpost,
                                                    user, truckModal);
                                              },
                                              child: const Text("Reject Bid")),
                                        )
                                      ],
                                    )
                                  : widget.bidpost.bidresponse == "Bid Rejected"
                                      ? Container(
                                          child: Row(
                                            children: [
                                              const Icon(Icons.close),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                "Bid Rejected",
                                                style: TextStyle(
                                                    color: Constants.alert,
                                                    fontSize: 20),
                                              )
                                            ],
                                          ),
                                        )
                                      : widget.bidpost.bidresponse ==
                                              "Bid Accepted"
                                          ? Container(
                                              child: Row(
                                                children: const [
                                                  Icon(Icons
                                                      .check_circle_outline),
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
                                            )
                                          : widget.bidpost.bidresponse ==
                                                  "Bid Completed"
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Text(
                                                      "Bid Completed",
                                                      style: TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 20),
                                                    ),
                                                    const SizedBox(
                                                      width: 25,
                                                    ),
                                                    Expanded(
                                                      child: ElevatedButton(
                                                          onPressed: () async {
                                                            await fetchcompletedata();
                                                            _viewcompleted(
                                                                widget.bidpost);
                                                          },
                                                          child: Text("View")),
                                                    )
                                                  ],
                                                )
                                              : widget.bidpost.biduserid ==
                                                          UserService()
                                                              .currentUid() &&
                                                      widget.bidpost
                                                              .bidresponse ==
                                                          ""
                                                  ? Container(
                                                      child: Row(
                                                        children: const [
                                                          Icon(Icons
                                                              .access_time_filled_sharp),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Text(
                                                            "Waiting for response",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .orange,
                                                                fontSize: 20),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  : Container(),
                            ],
                          ),
                        )),
                  ),
                );
              });
        });
  }

  int postuserAmt = 0;
  int truckuserAmt = 0;
  List postbidcount = [];
  List truckbidcount = [];
  List fetchtrucksid = [];
  bool bidloading = false;

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

  truckbidCount(TruckModal truckModal, BidModal bidpost) async {
    print(truckModal.id);
    bidRef
        .where('truckownerid', isEqualTo: bidpost.truckownerid)
        .where('bidresponse', isEqualTo: "Bid Accepted")
        .get()
        .then((value) {
      truckbidcount = value.docs;
      print("truckbidcount${truckbidcount.length}");
    });
  }

  bidAccepted(PostModal posts, TruckModal truckModal, BidModal bidpost,
      UserModel users) async {
    postUser(bidpost);
    truckUser(bidpost);
    postbidCount(posts);
    truckbidCount(truckModal, bidpost);

    widget.bidacptcount.length >= 5
        ? widget.amount < 100
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

    setState(() {
      bidloading = true;
    });
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
        'bidid': truckModal.ownerId,
        'notificationuser': UserService().currentUid(),
      });
      await postRef.doc(posts.postid).update({
        'loadstatus': "InTransit",
        'loadorderstatus': "InTransit",
      });
      await truckRef.doc(bidpost.truckid).update({
        'leftcapacity': capacity.toString(),
        'alcapacity': alreadyloaded.toString()
      });
      await truckRef
          .doc(bidpost.truckid)
          .collection('changeslorry')
          .where('truckposttime', isEqualTo: bidpost.truckposttime)
          .get()
          .then((value) {
        List doc = value.docs;
        doc.forEach((element) {
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

      Navigator.pop(
        context,
      );
    } catch (e) {
      print(e);
      setState(() {
        bidloading = false;
      });
    }
  }

  _onRejectBid(BidModal bidpost, UserModel users, TruckModal truckModal) async {
    try {
      // print(truckModal.ownerId);
      await bidRef.doc(bidpost.id).update({
        'bidresponse': "Bid Rejected",
        'bidtime': FieldValue.serverTimestamp(),
        'bidid': bidpost.truckownerid,
        'notificationuser': UserService().currentUid(),
      });

      Navigator.pop(context);
    } catch (e) {
      print(e);
    }
  }

  callNow(UserModel user) async {
    launch('tel://$user.usernumber!');
    await FlutterPhoneDirectCaller.callNumber(user.usernumber!);
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
                          margin: const EdgeInsets.only(
                              top: 10, left: 15, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Truck Routes",
                                style: GoogleFonts.ibmPlexSerif(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Icon(Icons.close),
                              )
                            ],
                          )),
                      const SizedBox(
                        height: 20,
                      ),
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
                                            ShipperHomePage(2)));
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

  fetchcompletedata() async {
    await bidRef
        .doc(widget.bidpost.id)
        .collection('bidcomplete')
        .get()
        .then((value) {
      getcompletebid = value.docs;
      getcompletebid.forEach((element) {
        setState(() {
          print(element['id']);
        });
      });
    });
  }

  List getcompletebid = [];
  _viewcompleted(BidModal bidpost) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              // height: 300,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25))),
              child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: getcompletebid.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Bid completed time:",
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 16),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            getcompletebid[index]['bidcompletedtime'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 19),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            'Bid Remarks:',
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 16),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            getcompletebid[index]['bidcompletedmsg'],
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 17),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "Proof",
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 16),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                height: 100,
                                width: 130,
                                child: Image.network(
                                  getcompletebid[index]['proofimg1'].toString(),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Container(
                                height: 100,
                                width: 130,
                                child: Image.network(
                                  getcompletebid[index]['proofimg2'].toString(),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          widget.bidpost.postuserfeedback == ''
                              ? Row(
                                  children: [
                                    Expanded(
                                        child: Container(
                                      height: 45,
                                      child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                              primary: Constants.thaartheme),
                                          onPressed: () async {
                                            await bidRef
                                                .doc(widget.bidpost.id)
                                                .update({
                                              'postuserfeedback': "Agree"
                                            }).then((value) {
                                              EasyLoading.showToast(
                                                  'Thanks for sharing your feedback');
                                              Navigator.pop(context);
                                            });
                                          },
                                          icon: const Icon(Icons.thumb_up),
                                          label: const Text("Agree")),
                                    )),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                        child: Container(
                                      height: 45,
                                      child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                              primary: Constants.alert),
                                          onPressed: () async {
                                            await disagreesheet(context);
                                            // Navigator.pop(context);
                                          },
                                          icon: const Icon(Icons.thumb_down),
                                          label: const Text("DisAgree")),
                                    ))
                                  ],
                                )
                              : Container()
                        ],
                      ),
                    );
                  }));
        });
  }

  TextEditingController disagreeController = TextEditingController();
  disagreesheet(
    BuildContext context,
  ) {
    showGeneralDialog(
      context: context,
      barrierLabel: "Barrier",
      barrierDismissible: false,
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
                        "Please share your disagree reason to improve our services",
                        style: TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Card(
                        color: Colors.grey[200],
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: TextFormField(
                            controller: disagreeController,
                            inputFormatters: [],
                            maxLength: 100,
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              hintText: "Write something..!",
                            ),
                          ),
                        ),
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
                                "UPDATE",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                              ),
                              onPressed: () async {
                                if (disagreeController.text.isEmpty) {
                                  EasyLoading.showToast(
                                      "Please write disagree reason");
                                } else {
                                  await bidRef.doc(widget.bidpost.id).update({
                                    'postuserfeedback': "NotAgree",
                                    'postuserfeedbackmsg':
                                        disagreeController.text
                                  }).then((value) {
                                    EasyLoading.showToast(
                                        'Thanks for sharing your feedback');
                                    Navigator.pop(context);
                                  });
                                }
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
}

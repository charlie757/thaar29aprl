import 'package:blinking_text/blinking_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:thaartransport/NEW/postloaduser/loadpagedata.dart';
import 'package:thaartransport/NEW/postloaduser/shipperhomepage.dart';
import 'package:thaartransport/addnewload/PostLoad.dart';
import 'package:thaartransport/addnewload/orderpostconfirmed.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/widget/flickerwidget.dart';
import 'package:thaartransport/widget/indicatiors.dart';

class MyLoadPage extends StatefulWidget {
  final currentuser;
  MyLoadPage({required this.currentuser});

  @override
  _MyLoadPageState createState() => _MyLoadPageState();
}

class _MyLoadPageState extends State<MyLoadPage> {
  var link = '';
  bool allCheckbox = false;
  bool activeCheckbox = false;
  bool expiredCheckbox = false;
  bool intransitCheckbox = false;
  bool completedCheckbox = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _filterPost(),
    );
  }

  retriveCurrentUser() {
    usersRef.doc(UserService().currentUid()).get().then((value) {
      if (mounted) {
        totalAmount = value.get('amount');
      }
    });
  }

  int totalAmount = 0;

  List<DocumentSnapshot> loadcount = [];
  postloadcount() async {
    await postRef
        .where('ownerId', isEqualTo: UserService().currentUid())
        .get()
        .then((value) {
      loadcount = value.docs;
      print("Loadcount ${loadcount.length}");
    });
  }

  @override
  void initState() {
    super.initState();
    postloadcount();
    retriveCurrentUser();
    fetchallBid();
  }

  fetchallBid() async {
    await postRef
        .where('ownerId', isEqualTo: UserService().currentUid())
        .get()
        .then((value) {
      value.docs.forEach((element) {
        print(element['postid']);
      });
    });
  }

  Widget filterPostIcon() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10, top: 5),
      child: InkWell(
        onTap: () {
          filterPost();
        },
        child: Row(
          children: const [
            Icon(Icons.filter_alt_sharp),
            SizedBox(
              width: 10,
            ),
            Text(
              "Filter",
              style: TextStyle(fontSize: 18),
            )
          ],
        ),
      ),
    );
  }

  Widget _filterPost() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return activeCheckbox
        ? StreamBuilder(
            stream: postRef
                .where('ownerId', isEqualTo: widget.currentuser)
                .where('loadstatus', isEqualTo: "Active")
                .orderBy('loadposttime', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text("Somthing went Wrong");
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return FlickerWidget();
              } else if (snapshot.data!.docs.isEmpty) {
                return Container(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    children: [
                      loadbutton(),
                      filterPostIcon(),
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height,
                          alignment: Alignment.center,
                          child: Text(
                            "No Active loads at the moment",
                            style: GoogleFonts.ibmPlexSerif(fontSize: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              }
              return Column(
                children: [
                  loadbutton(),
                  const SizedBox(
                    height: 5,
                  ),
                  filterPostIcon(),
                  Expanded(
                      child: ListView.builder(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, int index) {
                            PostModal posts = PostModal.fromJson(
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>);

                            link = posts.postid!;

                            return LoadPageData(posts);
                          }))
                ],
              );
            })
        : expiredCheckbox
            ? StreamBuilder(
                stream: postRef
                    .where('ownerId', isEqualTo: widget.currentuser)
                    .where('loadstatus', isEqualTo: 'Expired')
                    .orderBy('loadposttime', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text("Somthing went Wrong");
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return FlickerWidget();
                  } else if (snapshot.data!.docs.isEmpty) {
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      child: Column(
                        children: [
                          loadbutton(),
                          filterPostIcon(),
                          Expanded(
                            child: Container(
                              height: MediaQuery.of(context).size.height,
                              alignment: Alignment.center,
                              child: Text(
                                "No Expired loads at the moment",
                                style: GoogleFonts.ibmPlexSerif(fontSize: 18),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: [
                      loadbutton(),
                      const SizedBox(
                        height: 5,
                      ),
                      filterPostIcon(),
                      Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: ScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, int index) {
                                PostModal posts = PostModal.fromJson(
                                    snapshot.data!.docs[index].data()
                                        as Map<String, dynamic>);

                                link = posts.postid!;

                                return LoadPageData(posts);
                              }))
                    ],
                  );
                })
            : intransitCheckbox
                ? StreamBuilder(
                    stream: postRef
                        .where('ownerId', isEqualTo: widget.currentuser)
                        .where('loadstatus', isEqualTo: 'InTransit')
                        .orderBy('loadposttime', descending: true)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text("Somthing went Wrong");
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return FlickerWidget();
                      } else if (snapshot.data!.docs.isEmpty) {
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          child: Column(
                            children: [
                              loadbutton(),
                              filterPostIcon(),
                              Expanded(
                                child: Container(
                                  height: MediaQuery.of(context).size.height,
                                  alignment: Alignment.center,
                                  child: Text(
                                    "No Transit loads at the moment",
                                    style:
                                        GoogleFonts.ibmPlexSerif(fontSize: 18),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: [
                          loadbutton(),
                          const SizedBox(
                            height: 5,
                          ),
                          filterPostIcon(),
                          Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, int index) {
                                    PostModal posts = PostModal.fromJson(
                                        snapshot.data!.docs[index].data()
                                            as Map<String, dynamic>);

                                    link = posts.postid!;

                                    return LoadPageData(posts);
                                  }))
                        ],
                      );
                    })
                : completedCheckbox
                    ? StreamBuilder(
                        stream: postRef
                            .where('ownerId', isEqualTo: widget.currentuser)
                            .where('loadstatus', isEqualTo: 'Completed')
                            .orderBy('loadposttime', descending: true)
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text("Somthing went Wrong");
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return FlickerWidget();
                          } else if (snapshot.data!.docs.isEmpty) {
                            return Container(
                              height: MediaQuery.of(context).size.height,
                              child: Column(
                                children: [
                                  loadbutton(),
                                  filterPostIcon(),
                                  Expanded(
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height,
                                      alignment: Alignment.center,
                                      child: Text(
                                        "No Completed loads at the moment",
                                        style: GoogleFonts.ibmPlexSerif(
                                            fontSize: 18),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                          return Column(
                            children: [
                              loadbutton(),
                              const SizedBox(
                                height: 5,
                              ),
                              filterPostIcon(),
                              Expanded(
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, int index) {
                                        PostModal posts = PostModal.fromJson(
                                            snapshot.data!.docs[index].data()
                                                as Map<String, dynamic>);

                                        link = posts.postid!;

                                        return LoadPageData(posts);
                                      }))
                            ],
                          );
                        })
                    : StreamBuilder(
                        stream: postRef
                            .where('ownerId', isEqualTo: widget.currentuser)
                            .orderBy('loadposttime', descending: true)
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return const Text("Somthing went Wrong");
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return FlickerWidget();
                          } else if (snapshot.data!.docs.isEmpty) {
                            return Container(
                              height: MediaQuery.of(context).size.height,
                              child: Column(
                                children: [
                                  loadbutton(),
                                  filterPostIcon(),
                                  Expanded(
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.height,
                                      alignment: Alignment.center,
                                      child: Text(
                                        "No Active loads at the moment",
                                        style: GoogleFonts.ibmPlexSerif(
                                            fontSize: 18),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                          return Column(
                            children: [
                              loadbutton(),
                              const SizedBox(
                                height: 5,
                              ),
                              filterPostIcon(),
                              Expanded(
                                  child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      itemCount: snapshot.data!.docs.length,
                                      itemBuilder: (context, int index) {
                                        PostModal posts = PostModal.fromJson(
                                            snapshot.data!.docs[index].data()
                                                as Map<String, dynamic>);

                                        link = posts.postid!;

                                        return Column(
                                          children: [
                                            LoadPageData(posts),
                                            // LoadPosts(
                                            //     posts.loadstatus!,
                                            //     posts.loadposttime!,
                                            //     posts.sourcelocation!,
                                            //     posts.destinationlocation!,
                                            //     posts.material!,
                                            //     posts.quantity!,
                                            //     posts.expectedprice!,
                                            //     posts,
                                            //     posts.priceunit!,
                                            //     posts.postexpiretime!),
                                            const SizedBox(
                                              height: 5,
                                            )
                                          ],
                                        );
                                      }))
                            ],
                          );
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
      PostModal posts,
      String priceunit,
      String postexpiretime) {
    var ref = posts.postid;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final currenttime = DateTime.now();
    final backendtime = DateTime.parse(postexpiretime);
    final differencehours = backendtime.difference(currenttime).inHours;
    final checkdifference = differencehours >= 1 ? differencehours : 1;

    final differenceinmin = backendtime.difference(currenttime).inMinutes;
    final checkdifferenceinmin =
        differenceinmin >= 60 ? checkdifference : differenceinmin;

    final differenceinsec = backendtime.difference(currenttime).inSeconds;
    final checkdifferenceinsec =
        differenceinsec >= 1 ? differenceinmin : differenceinsec;

    checkdifferenceinsec == 0
        ? postRef.doc(posts.postid).update({'loadstatus': 'Expired'})
        : null;

    print("expiretime ${posts.postid}");
    print("checkdifferenceinsec $checkdifferenceinsec");
    print("checkdifference $checkdifference");

    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => OrderPostConfirmed(ref!)));
        },
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Card(
              elevation: 7,
              child: Container(
                child: Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            posts.loadstatus == "Active"
                                ? const SizedBox()
                                : const SizedBox(
                                    height: 8,
                                  ),
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
                                    posts.loadorderstatus == "InTransit" ||
                                            posts.loadorderstatus == "Completed"
                                        ? posts.loadorderstatus!.toUpperCase()
                                        : status.toUpperCase(),
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                        color: status == "Active"
                                            ? Constants.cursorColor
                                            : posts.loadorderstatus !=
                                                        "InTransit" &&
                                                    posts.loadorderstatus !=
                                                        "Completed" &&
                                                    posts.loadorderstatus ==
                                                        "Active" &&
                                                    status == "Expired"
                                                ? Constants.alert
                                                : posts.loadorderstatus ==
                                                        "InTransit"
                                                    ? Colors.purple
                                                    : posts.loadorderstatus ==
                                                            "InProgress"
                                                        ? Colors.indigo
                                                        : Colors.blue),
                                  ),
                                ),
                                // const BlinkText(
                                //   'Bid received',
                                //   style: TextStyle(
                                //       fontStyle: FontStyle.italic,
                                //       fontSize: 16.0,
                                //       color: Color(0XFF142438)),
                                //   endColor: Colors.orange,
                                // ),
                                posts.loadstatus == "Active"
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
                                          // const PopupMenuItem(
                                          //     value: 2,
                                          //     enabled: true,
                                          //     child: Text(
                                          //       "Share on WhatsApp",
                                          //     )),
                                        ],
                                        onSelected: (menu) {
                                          if (menu == 1) {
                                            postRef.doc(posts.postid).update({
                                              'loadstatus': "Expired",
                                              // 'loadorderstatus': "Expired"
                                            });
                                          }
                                          if (menu == 2) {
                                            print(link);
                                            // Share.shareFiles(user.photoURL!)
                                            // FlutterShare.share(
                                            //     title: 'Share Post',
                                            //     text: 'Book the Load',
                                            //     chooserTitle: 'Share with');
                                            // Share.share(
                                            //   // link.toString(),
                                            //   _linkMessage.toString(),
                                            // subject: _linkMessage.toString(),
                                            // );
                                          }
                                        },
                                      )
                                    : Container()
                              ],
                            ),
                            posts.loadstatus == "Active"
                                ? const SizedBox()
                                : const SizedBox(
                                    height: 8,
                                  ),
                            Row(
                              children: [
                                Container(
                                  child: const Text(
                                    "Posted on:",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  postTime.split(',')[1] +
                                      postTime.split(',')[2],
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.01),
                            Row(
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
                                  source,
                                  style: GoogleFonts.lato(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.circle,
                                  size: 13,
                                  color: Colors.red,
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  destination,
                                  style: GoogleFonts.lato(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/product.png',
                                          height: 20,
                                          width: 20,
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          material,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 3,
                                    ),
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/quantity.png',
                                          height: 20,
                                          width: 20,
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        Text(
                                          "$quantity Tons",
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/rupee-indian.png',
                                          height: 20,
                                          width: 20,
                                          color: Colors.blue,
                                        ),
                                        Text(expectedPrice,
                                            style: GoogleFonts.lato(
                                                fontSize: 19,
                                                fontWeight: FontWeight.w800)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(priceunit == 'tonne' ? " per" : '',
                                            style: TextStyle(fontSize: 18)),
                                        SizedBox(
                                          width: width * 0.02,
                                        ),
                                        Text(priceunit,
                                            style:
                                                GoogleFonts.lato(fontSize: 18)),
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            posts.loadstatus == "Active"
                                ? Text.rich(TextSpan(
                                    text: "Expire After:  ",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                        fontSize: 16),
                                    children: [
                                      TextSpan(
                                          text: differenceinmin >= 60
                                              ? checkdifference.toString()
                                              : differenceinsec >= 1
                                                  ? differenceinmin.toString()
                                                  : differenceinsec.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 17,
                                              color: differenceinmin >= 60
                                                  ? Colors.green.shade900
                                                  : differenceinsec >= 1
                                                      ? Colors.orange
                                                      : Colors.orange),
                                          children: [
                                            TextSpan(
                                                text: differenceinmin >= 60
                                                    ? " Hours"
                                                    : differenceinsec >= 1
                                                        ? " Min"
                                                        : " Sec",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 15,
                                                    color: differenceinmin >= 60
                                                        ? Colors.green.shade900
                                                        : differenceinsec >= 1
                                                            ? Colors.orange
                                                            : Colors.orange))
                                          ]),
                                    ],
                                  ))
                                : Container()
                          ],
                        )),
                    SizedBox(
                      height: height * 0.02,
                    ),
                    posts.loadorderstatus != "InTransit" &&
                            posts.loadorderstatus != "Completed" &&
                            posts.loadorderstatus == "Active" &&
                            status == "Expired"
                        ? InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    fullscreenDialog: true,
                                    pageBuilder: (c, a1, a2) =>
                                        OrderPostConfirmed(ref!),
                                    transitionsBuilder: (c, anim, a2, child) =>
                                        FadeTransition(
                                            opacity: anim, child: child),
                                    transitionDuration:
                                        const Duration(milliseconds: 400),
                                  ));
                            },
                            child: Container(
                                color: Color(0xffe8e8f0),
                                alignment: Alignment.center,
                                height: 40,
                                width: width,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.refresh,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Repost Load",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 18),
                                    ),
                                  ],
                                )))
                        : InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          OrderPostConfirmed(ref!)));
                            },
                            child: Container(
                              color: Color(0xffe8e8f0),
                              alignment: Alignment.center,
                              height: 40,
                              width: width,
                              child: const Text(
                                "View Details",
                                style: TextStyle(
                                    color: Colors.black, fontSize: 18),
                              ),
                            ))
                  ],
                ),
              )),
        ));
  }

  Widget loadbutton() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
      child: RaisedButton(
          color: const Color(0XFF142438),
          onPressed: () async {
            loadcount.length >= 5
                ? totalAmount < 100
                    ? addMoneyAlert(context)
                    : Navigator.push(
                        context,
                        PageRouteBuilder(
                          fullscreenDialog: true,
                          pageBuilder: (c, a1, a2) => PostLoad(),
                          transitionsBuilder: (c, anim, a2, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration: const Duration(milliseconds: 400),
                        ))
                : Navigator.push(
                    context,
                    PageRouteBuilder(
                      fullscreenDialog: true,
                      pageBuilder: (c, a1, a2) => PostLoad(),
                      transitionsBuilder: (c, anim, a2, child) =>
                          FadeTransition(opacity: anim, child: child),
                      transitionDuration: const Duration(milliseconds: 200),
                    ));
          },
          child: Shimmer(
              duration: const Duration(seconds: 3),
              interval: Duration(seconds: 3),
              color: Colors.white,
              colorOpacity: 0,
              enabled: true,
              direction: ShimmerDirection.fromLTRB(),
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
                      Icon(Icons.arrow_forward_ios,
                          size: 18, color: Colors.white)
                    ],
                  )))),
    );
  }

  filterPost() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (
          context,
        ) {
          return Container(
            // color: Color(0xFF737373),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: StatefulBuilder(builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(
                    top: 15, bottom: 30, left: 15, right: 15),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select your filter feed",
                            style: GoogleFonts.ibmPlexSerif(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: CircleAvatar(
                                backgroundColor: Constants.btninactive,
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.black,
                                ),
                              ))
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          "All",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 19),
                        ),
                        value: allCheckbox,
                        onChanged: (val) {
                          state(() {});
                          setState(() {
                            allCheckbox = val!;
                            activeCheckbox = false;
                            expiredCheckbox = false;
                            intransitCheckbox = false;
                            completedCheckbox = false;
                            Navigator.pop(context);
                          });
                        }),
                    CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          "Active",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 19),
                        ),
                        value: activeCheckbox,
                        onChanged: (val) {
                          state(() {});
                          setState(() {
                            activeCheckbox = val!;
                            allCheckbox = false;
                            expiredCheckbox = false;
                            intransitCheckbox = false;
                            completedCheckbox = false;
                            Navigator.pop(context);
                          });
                        }),
                    CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          "Expired",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 19),
                        ),
                        value: expiredCheckbox,
                        onChanged: (val) {
                          state(() {});
                          setState(() {
                            expiredCheckbox = val!;
                            activeCheckbox = false;
                            allCheckbox = false;
                            intransitCheckbox = false;
                            completedCheckbox = false;
                            Navigator.pop(context);
                          });
                        }),
                    CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          "InTransit",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 19),
                        ),
                        value: intransitCheckbox,
                        onChanged: (val) {
                          state(() {});
                          setState(() {
                            intransitCheckbox = val!;
                            activeCheckbox = false;
                            expiredCheckbox = false;
                            allCheckbox = false;
                            completedCheckbox = false;
                            Navigator.pop(context);
                          });
                        }),
                    CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          "Completed",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 19),
                        ),
                        value: completedCheckbox,
                        onChanged: (val) {
                          state(() {});
                          setState(() {
                            completedCheckbox = val!;
                            activeCheckbox = false;
                            expiredCheckbox = false;
                            intransitCheckbox = false;
                            allCheckbox = false;
                            Navigator.pop(context);
                          });
                        }),
                    const SizedBox(
                      height: 15,
                    )
                  ],
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
}

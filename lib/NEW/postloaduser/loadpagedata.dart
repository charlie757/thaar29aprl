import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';

import '../../addnewload/orderpostconfirmed.dart';

class LoadPageData extends StatefulWidget {
  PostModal posts;
  LoadPageData(this.posts);

  @override
  State<LoadPageData> createState() => _LoadPageDataState();
}

class _LoadPageDataState extends State<LoadPageData>
    with WidgetsBindingObserver {
  int differenceinmin = 0;
  int checkdifference = 0;
  int differenceinsec = 0;

  timerFunction() {
    final currenttime = DateTime.now();

    final backendtime = DateTime.parse(widget.posts.postexpiretime.toString());
    print("backen ${backendtime}");
    final differencehours = backendtime.difference(currenttime).inHours;
    checkdifference = differencehours >= 1 ? differencehours : 1;

    differenceinmin = backendtime.difference(currenttime).inMinutes;
    final checkdifferenceinmin =
        differenceinmin >= 60 ? checkdifference : differenceinmin;

    differenceinsec = backendtime.difference(currenttime).inSeconds;
    final checkdifferenceinsec = differenceinsec >= 1
        ? differenceinmin
        : differenceinsec < 1
            ? 0
            : differenceinsec;

    differenceinsec == 1 || differenceinsec <= 1 || differenceinsec == 0
        ? postRef.doc(widget.posts.postid).update({'loadstatus': 'Expired'})
        : null;

    print("expiretime ${widget.posts.postid}");
    print("checkdifferenceinsec $checkdifferenceinsec");
    print("checkdifference $checkdifference");
  }

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

  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (state == AppLifecycleState.paused) {
      Future.delayed(Duration(minutes: 1)).then((value) {
        postRef.doc(widget.posts.postid).update({'loadstatus': 'Expired'});
        print("sccess");
      });
    } else if (state == AppLifecycleState.inactive) {
      Future.delayed(Duration(minutes: 1)).then((value) {
        postRef.doc(widget.posts.postid).update({'loadstatus': 'Expired'});
        print("sccess");
      });
    } else if (state == AppLifecycleState.resumed) {
      Future.delayed(Duration(minutes: 1)).then((value) {
        postRef.doc(widget.posts.postid).update({'loadstatus': 'Active'});
        print("sccess");
      });
    } else if (state == AppLifecycleState.detached) {
      Future.delayed(Duration(minutes: 1)).then((value) {
        postRef.doc(widget.posts.postid).update({'loadstatus': 'Active'});
        print("sccess");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    timerFunction();
    var ref = widget.posts.postid;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

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
                            widget.posts.loadstatus == "Active"
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
                                    widget.posts.loadorderstatus ==
                                                "InTransit" ||
                                            widget.posts.loadorderstatus ==
                                                "Completed"
                                        ? widget.posts.loadorderstatus!
                                            .toUpperCase()
                                        : widget.posts.loadstatus
                                            .toString()
                                            .toUpperCase(),
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                        color: widget.posts.loadstatus ==
                                                "Active"
                                            ? Constants.cursorColor
                                            : widget.posts
                                                            .loadorderstatus !=
                                                        "InTransit" &&
                                                    widget.posts
                                                            .loadorderstatus !=
                                                        "Completed" &&
                                                    widget.posts
                                                            .loadorderstatus ==
                                                        "Active" &&
                                                    widget.posts.loadstatus ==
                                                        "Expired"
                                                ? Constants.alert
                                                : widget.posts
                                                            .loadorderstatus ==
                                                        "InTransit"
                                                    ? Colors.purple
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
                                widget.posts.loadstatus == "Active"
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
                                            postRef
                                                .doc(widget.posts.postid)
                                                .update({
                                              'loadstatus': "Expired",
                                              // 'loadorderstatus': "Expired"
                                            });
                                          }
                                          if (menu == 2) {
                                            // print(link);
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
                            widget.posts.loadstatus == "Active"
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
                                  widget.posts.loadposttime
                                          .toString()
                                          .split(',')[1] +
                                      widget.posts.loadposttime
                                          .toString()
                                          .split(',')[2],
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
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
                                  widget.posts.sourcelocation.toString(),
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
                                  widget.posts.destinationlocation.toString(),
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
                                          widget.posts.material.toString(),
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
                                          "${widget.posts.quantity} Tons",
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
                                        Text(
                                            widget.posts.expectedprice
                                                .toString(),
                                            style: GoogleFonts.lato(
                                                fontSize: 19,
                                                fontWeight: FontWeight.w800)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                            widget.posts.priceunit == 'tonne'
                                                ? " per"
                                                : '',
                                            style: TextStyle(fontSize: 18)),
                                        SizedBox(
                                          width: width * 0.02,
                                        ),
                                        Text(widget.posts.priceunit.toString(),
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
                            widget.posts.loadstatus == "Active"
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
                    widget.posts.loadorderstatus != "InTransit" &&
                            widget.posts.loadorderstatus != "Completed" &&
                            widget.posts.loadorderstatus == "Active" &&
                            widget.posts.loadstatus == "Expired"
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
}

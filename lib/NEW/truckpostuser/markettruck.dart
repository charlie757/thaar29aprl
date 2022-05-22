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
import 'package:thaartransport/NEW/truckpostuser/martetdata.dart';
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

  @override
  void initState() {
    super.initState();
  }

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
                    unselectedLabelColor: const Color(0xffb8b0b8),
                    labelStyle: const TextStyle(fontSize: 18),
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
                          // .where('ownerId',
                          //     isNotEqualTo: UserService().currentUid())
                          .where('truckstatus', isEqualTo: "ACTIVE")
                          .where('leftcapacity', isGreaterThan: '0')
                          .orderBy('leftcapacity')
                          .orderBy('time', descending: false)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text("Somthing went Wrong");
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return FlickerWidget();
                        } else if (snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              "No trucks in market",
                              style: GoogleFonts.ibmPlexSerif(fontSize: 18),
                            ),
                          );
                        } else if (snapshot.hasData) {
                          return ScrollWrapper(
                              scrollController: scrollController,
                              scrollToTopCurve: Curves.easeInOut,
                              promptAlignment: Alignment.bottomRight,
                              child: RefreshIndicator(
                                color: Colors.white,
                                backgroundColor: Constants.kYellowColor,
                                triggerMode:
                                    RefreshIndicatorTriggerMode.anywhere,
                                onRefresh: () async {
                                  Future.delayed(const Duration(seconds: 5));
                                  setState(() {});
                                },
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
                                          return Markettruckdata(truckModal);
                                        }),
                                    const SizedBox(height: 30),
                                  ],
                                ),
                              ));
                        }
                        return circularProgress(context);
                      }),
                ],
              ),
            ),
          );
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

}

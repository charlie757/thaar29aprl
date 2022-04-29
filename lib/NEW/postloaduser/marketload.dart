import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scroll_to_top/flutter_scroll_to_top.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/postloaduser/loaddata.dart';
import 'package:thaartransport/addnewload/PostLoad.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/widget/flickerwidget.dart';
import 'package:thaartransport/widget/indicatiors.dart';
import 'package:thaartransport/widget/internetmsg.dart';

import '../../utils/constants.dart';
import '../../utils/firebase.dart';

class MarketLoad extends StatefulWidget {
  const MarketLoad({Key? key}) : super(key: key);

  @override
  State<MarketLoad> createState() => _MarketLoadState();
}

class _MarketLoadState extends State<MarketLoad> {
  bool isLoading = false;

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
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
                    "BOOK LOADS",
                  ),
                )
              ]),
        ),
        body: TabBarView(children: [
          StreamBuilder<QuerySnapshot>(
              stream: postRef
                  .where('ownerId', isNotEqualTo: UserService().currentUid())
                  .where('loadstatus', isEqualTo: 'Active')
                  .orderBy('ownerId')
                  .orderBy('posttime', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text("Somthing went Wrong");
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return FlickerWidget();
                } else if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No loads in market",
                      style: TextStyle(fontSize: 20),
                    ),
                  );
                } else if (snapshot.hasData) {
                  return !isOnline
                      ? internetchecker()
                      : ScrollWrapper(
                          scrollController: scrollController,
                          scrollToTopCurve: Curves.easeInOut,
                          promptAlignment: Alignment.bottomRight,
                          child: ListView(
                            controller: scrollController,
                            shrinkWrap: true,
                            children: [
                              ListView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.all(0),
                                  physics: ScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, int index) {
                                    PostModal posts = PostModal.fromJson(
                                        snapshot.data!.docs[index].data()
                                            as Map<String, dynamic>);

                                    return LoadData(
                                      posts: posts,
                                      // users: users,
                                    );
                                  }),
                            ],
                          ));
                }
                return circularProgress(context);
              }),
        ]),
      ),
    );
  }

  // Widget userData(PostModal posts) {
  //   return StreamBuilder(
  //       stream: usersRef.doc(posts.ownerId).snapshots(),
  //       builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
  //         if (snapshot.hasError) {
  //           return const Text("Somthing went Wrong");
  //         } else if (snapshot.connectionState == ConnectionState.waiting) {
  //           return Center();
  //         } else if (snapshot.hasData) {
  //           UserModel users = UserModel.fromJson(
  //               snapshot.data!.data() as Map<String, dynamic>);
  //           return
  //         } else {
  //           return circularProgress(context);
  //         }
  //       });
  // }
}

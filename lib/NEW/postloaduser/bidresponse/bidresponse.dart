import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/NEW/postloaduser/bidresponse/allreceivedbids.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/bidmodal.dart';

import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/widget/flickerwidget.dart';
import 'package:thaartransport/widget/indicatiors.dart';

class BidResponse extends StatefulWidget {
  PostModal posts;
  BidResponse({required this.posts});

  @override
  _BidResponseState createState() => _BidResponseState();
}

class _BidResponseState extends State<BidResponse> {
  postUser() async {
    await usersRef.doc(widget.posts.ownerId).get().then((value) {
      postuserAmt = value.get('amount');
      print(postuserAmt);
    });
  }

  postbidCount() async {
    await bidRef
        .where('loadpostid', isEqualTo: widget.posts.ownerId)
        .where('bidresponse', isEqualTo: "Bid Accepted")
        .get()
        .then((value) {
      postbidcount = value.docs;
      print(postbidcount);
    });
  }

  int postuserAmt = 0;
  List postbidcount = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: bidRef
                    .where('loadid', isEqualTo: widget.posts.postid)
                    .where('loadpostid', isEqualTo: UserService().currentUid())
                    // .orderBy('bidtime', descending: true)
                    .limit(1)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Somthing went Wrong");
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return FlickerWidget();
                  } else if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("Yet Not received bids",
                            style: TextStyle(fontSize: 18)));
                  }
                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(0),
                      physics: const ScrollPhysics(),
                      itemBuilder: (context, index) {
                        BidModal bidpost = BidModal.fromJson(
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>);
                        return AllReceivedBids(
                          posts: widget.posts,
                          bidpost: bidpost,
                          amount: postuserAmt,
                          bidacptcount: postbidcount,
                        );
                      });
                }),
          )
        ],
      ),
    );
  }
}

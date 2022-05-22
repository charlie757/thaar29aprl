import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thaartransport/NEW/postloaduser/bidresponse/getbidresponse.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/bidmodal.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/widget/flickerwidget.dart';
import 'package:thaartransport/widget/indicatiors.dart';

class BidAccept extends StatefulWidget {
  int amount;
  List bidacptcount;
  PostModal posts;
  BidAccept(this.amount, this.bidacptcount, this.posts);

  @override
  State<BidAccept> createState() => _BidAcceptState();
}

class _BidAcceptState extends State<BidAccept> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: bidRef
            .where('loadid', isEqualTo: widget.posts.postid)
            .where('loadpostid', isEqualTo: UserService().currentUid())
            .where('bidresponse', isEqualTo: "Bid Accepted")
            // .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Somthing went Wrong");
          } else if (snapshot.connectionState == ConnectionState.waiting) {
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
                    snapshot.data!.docs[index].data() as Map<String, dynamic>);
                return getBidResponse(
                    bidpost, widget.amount, widget.bidacptcount, widget.posts);
              });
        });
  }
}

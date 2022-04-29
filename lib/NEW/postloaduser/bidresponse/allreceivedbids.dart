import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/currentuserprovider.dart';
import 'package:thaartransport/NEW/postloaduser/bidresponse/bidaccept.dart';
import 'package:thaartransport/NEW/postloaduser/bidresponse/bidcomplete.dart';
import 'package:thaartransport/NEW/postloaduser/bidresponse/getbidresponse.dart';
import 'package:thaartransport/NEW/postloaduser/bidresponse/seeall.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/bidmodal.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/firebase.dart';

class AllReceivedBids extends StatefulWidget {
  PostModal posts;
  BidModal bidpost;
  int amount;
  List bidacptcount;
  AllReceivedBids(
      {required this.posts,
      required this.bidpost,
      required this.amount,
      required this.bidacptcount});

  @override
  _AllReceivedBidsState createState() => _AllReceivedBidsState();
}

class _AllReceivedBidsState extends State<AllReceivedBids> {
  bool validate = false;
  bool loading = false;

  TextEditingController Negotiate = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchacceptbid();
    fetchcompletebid();
  }

  fetchacceptbid() async {
    await bidRef
        .where('loadid', isEqualTo: widget.posts.postid)
        .where('loadpostid', isEqualTo: UserService().currentUid())
        .where('bidresponse', isEqualTo: "Bid Accepted")
        .get()
        .then((value) {
      biddoc = value.docs;
      biddoc.forEach((element) {
        setState(() {
          print(element['bidresponse']);
          bidaccepted = element['bidresponse'];
        });
      });
    });
  }

  fetchcompletebid() async {
    await bidRef
        .where('loadid', isEqualTo: widget.posts.postid)
        .where('loadpostid', isEqualTo: UserService().currentUid())
        .where('bidresponse', isEqualTo: "Bid Completed")
        .get()
        .then((value) {
      bidcomdoc = value.docs;
      bidcomdoc.forEach((element) {
        setState(() {
          print(element['bidresponse']);
          bidcomplete = element['bidresponse'];
        });
      });
    });
  }

  List biddoc = [];
  String bidaccepted = '';

  List bidcomdoc = [];
  String bidcomplete = '';
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        bidaccepted == "Bid Accepted"
            ? BidAccept(widget.amount, widget.bidacptcount, widget.posts)
            : bidcomplete == "Bid Completed"
                ? BidComplete(widget.amount, widget.bidacptcount, widget.posts)
                : getBidResponse(widget.bidpost, widget.amount,
                    widget.bidacptcount, widget.posts),
        const SizedBox(
          height: 15,
        ),
        bidaccepted == "Bid Accepted" || bidcomplete == "Bid Completed"
            ? Container()
            : Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: FlatButton(
                    color: Colors.grey,
                    textColor: Colors.white,
                    onPressed: () {
                      _onSeeAll();
                    },
                    child: Container(
                      height: 45,
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: const Text(
                        "See All Bid",
                        style: TextStyle(fontSize: 18),
                      ),
                    )))
      ],
    );
  }

  _onSeeAll() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                color: Color(0xFF737373),
                // height: 300,
                child: Container(
                  padding: EdgeInsets.all(15),
                  child:
                      SeeAll(widget.amount, widget.bidacptcount, widget.posts),
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

  // Widget _buildSeeAllSheet() {
  //   return StatefulBuilder(builder: (context, setState) {
  //     return StreamBuilder<QuerySnapshot>(
  //         stream: bidRef
  //             .where('loadid', isEqualTo: widget.posts.postid)
  //             .orderBy('bidtime', descending: true)
  //             .snapshots(),
  //         builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //           if (snapshot.hasError) {
  //             return const Text("Somthing went Wrong");
  //           } else if (snapshot.connectionState == ConnectionState.waiting) {
  //             return Center();
  //           } else if (snapshot.data!.docs.isEmpty) {
  //             return const Center(
  //                 child: Text("Yet Not received bids",
  //                     style: TextStyle(fontSize: 18)));
  //           }
  //           return Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   const Text(
  //                     "Bids Received",
  //                     style:
  //                         TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
  //                   ),
  //                   IconButton(
  //                       onPressed: () {
  //                         Navigator.pop(context);
  //                       },
  //                       icon: Icon(Icons.close))
  //                 ],
  //               ),
  //               ListView.builder(
  //                   itemCount: snapshot.data!.docs.length,
  //                   shrinkWrap: true,
  //                   padding: EdgeInsets.all(0),
  //                   physics: ScrollPhysics(),
  //                   itemBuilder: (context, index) {
  //                     BidModal bidpost = BidModal.fromJson(
  //                         snapshot.data!.docs[index].data()
  //                             as Map<String, dynamic>);

  //                     return getBidResponse(bidpost);
  //                   })
  //             ],
  //           );
  //         });
  //   });
  // }
}

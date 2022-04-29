import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thaartransport/NEW/postloaduser/shipperhomepage.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/bidmodal.dart';
import 'package:thaartransport/modal/truckmodal.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/screens/chat/chat.dart';
import 'package:thaartransport/utils/firebase.dart';

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
                      widget.bidacptcount.length >= 5
                          ? widget.amount < 500
                              ? addMoneyAlert(context)
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Chat(
                                          user,
                                          widget.posts,
                                          widget.bidpost,
                                          truckModal),
                                      fullscreenDialog: true))
                          : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Chat(
                                          user,
                                          widget.posts,
                                          widget.bidpost,
                                          truckModal),
                                      fullscreenDialog: true))
                              .then((value) {
                              setState(() {});
                            });
                    },
                    child: Card(
                        elevation: 5,
                        shape: Border.all(),
                        shadowColor: Colors.cyan,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.circle,
                                      color: Colors.green, size: 15),
                                  const SizedBox(width: 5),
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
                                      color: Colors.red, size: 15),
                                  const SizedBox(width: 5),
                                  Text(
                                    truckModal.destinationlocation.toString(),
                                    style: GoogleFonts.lato(fontSize: 15),
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
                                  FlatButton(
                                      textColor: Colors.white,
                                      color: widget.bidpost.bidresponse ==
                                              "Bid Accepted"
                                          ? Colors.green.shade900
                                          : widget.bidpost.bidresponse ==
                                                  "Bid Rejected"
                                              ? Colors.red.shade900
                                              : widget.bidpost.bidresponse ==
                                                      "Bid Completed"
                                                  ? Colors.blue.shade900
                                                  : Colors.indigo.shade900,
                                      onPressed: () {},
                                      child: Text(
                                        widget.bidpost.bidresponse ==
                                                "Bid Accepted"
                                            ? "ACCEPTED"
                                            : widget.bidpost.bidresponse ==
                                                    "Bid Rejected"
                                                ? 'REJECTED'
                                                : widget.bidpost.bidresponse ==
                                                        "Bid Completed"
                                                    ? "COMPLETED"
                                                    : "IN-PROGRESS",
                                      ))
                                ],
                              )
                            ],
                          ),
                        )),
                  ),
                );
              });
        });
  }

  addMoneyAlert(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Insufficient Amount",
      desc: "Please add money in your wallet to continue bid",
      buttons: [
        DialogButton(
          child: const Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          onPressed: () => Navigator.pop(context),
          // color: Colors.,
        ),
        DialogButton(
          child: const Text(
            "Add Money",
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ShipperHomePage(2)));
          },
          color: Color(0XFF142438),
        )
      ],
    ).show();
  }
}

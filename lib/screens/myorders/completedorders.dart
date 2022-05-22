import 'package:blinking_text/blinking_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/truckmodal.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/screens/chat/chat.dart';
import 'package:thaartransport/modal/bidmodal.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/widget/flickerwidget.dart';
import 'package:thaartransport/widget/internetmsg.dart';

import '../../utils/constants.dart';

class CompletedOrders extends StatefulWidget {
  const CompletedOrders({Key? key}) : super(key: key);

  @override
  _CompletedOrdersState createState() => _CompletedOrdersState();
}

class _CompletedOrdersState extends State<CompletedOrders> {
  countDocuments() async {
    QuerySnapshot _myDoc = await bidRef
        .where('biduserid', isEqualTo: UserService().currentUid())
        .where('bidresponse', isEqualTo: "Bid Completed")
        .get();
    List myDocCount = _myDoc.docs;
    count = myDocCount.length.toString();
    return print(count);
  }

  var count = "";
  @override
  void initState() {
    countDocuments();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    return !isOnline
        ? internetchecker()
        : StreamBuilder<QuerySnapshot>(
            stream: bidRef
                .where('truckownerid', isEqualTo: UserService().currentUid())
                .where('bidresponse', isEqualTo: "Bid Completed")
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text("Somthing went Wrong");
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return FlickerWidget();
              } else if (snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text("Yet No Completed Bids",
                        style: TextStyle(fontSize: 18)));
              }
              return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(0),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    BidModal bidpost = BidModal.fromJson(
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>);
                    return getloadid(bidpost);
                  });
            });
  }

  Widget getloadid(BidModal bidpost) {
    return StreamBuilder(
        stream: postRef.where('postid', isEqualTo: bidpost.loadid).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Somthing went Wrong");
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center();
          }
          return ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(0),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, int index) {
                PostModal posts = PostModal.fromJson(
                    snapshot.data!.docs[index].data() as Map<String, dynamic>);

                return buidUser(posts, bidpost);
              });
        });
  }

  Widget buidUser(PostModal posts, BidModal bidpost) {
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
          TruckModal truckModal = TruckModal.fromJson(
              snapshot.data!.data() as Map<String, dynamic>);
          UserModel users =
              UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
          return InkWell(
            onTap: () {
              fetchcompletedata(bidpost);
              _viewcompleted(bidpost);
            },
            child: Card(
                // color: Colors.red,

                elevation: 1,
                child: Column(
                  children: [
                    Container(
                      // height: 20,
                      padding:
                          const EdgeInsets.only(top: 20, left: 10, right: 10),
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
                                    Text(posts.loadposttime!.split(',')[1] +
                                        posts.loadposttime!.split(',')[2]),
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
                          const Divider(),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          Divider(),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          style:
                                              GoogleFonts.lato(fontSize: 18)),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                          posts.priceunit == 'tonne'
                                              ? "per ${posts.priceunit}"
                                              : posts.priceunit!,
                                          style: const TextStyle(fontSize: 17)),
                                    ],
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Text(bidpost.rate!,
                                          style:
                                              GoogleFonts.lato(fontSize: 18)),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                          posts.priceunit == 'tonne'
                                              ? "per ${posts.priceunit}"
                                              : posts.priceunit!,
                                          style: const TextStyle(fontSize: 17)),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.black45,
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                            elevation: 0,
                            // color: Colors.pink,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    child: Flexible(
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100.0)),
                                        child: CachedNetworkImage(
                                            height: 50,
                                            width: 50,
                                            imageUrl: users.photourl.toString(),
                                            placeholder: (context, url) =>
                                                Transform.scale(
                                                  scale: 0.4,
                                                  child:
                                                      CircularProgressIndicator(
                                                    color:
                                                        Constants.kYellowColor,
                                                    strokeWidth: 3,
                                                  ),
                                                ),
                                            errorWidget: (context, url,
                                                    error) =>
                                                Container(
                                                    height: 40,
                                                    width: 40,
                                                    child: Image.asset(
                                                        'assets/images/account_profile.png')),
                                            fit: BoxFit.cover),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              users.username!,
                                              style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                                FlatButton(
                                    color: Colors.blue,
                                    textColor: Colors.white,
                                    onPressed: () {},
                                    child: Container(
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Completed Bid",
                                      ),
                                    ))
                              ],
                            )))
                  ],
                )),
          );
        });
  }

  fetchcompletedata(BidModal bidpost) async {
    await bidRef.doc(bidpost.id).collection('bidcomplete').get().then((value) {
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
        shape: const RoundedRectangleBorder(
          // <-- SEE HERE
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(25.0),
          ),
        ),
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
                      padding: const EdgeInsets.only(top: 20, left: 15),
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
                          bidpost.postuserfeedback == ''
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
                                                .doc(bidpost.id)
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
                                            // await disagreesheet(context);
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
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          Chat(users, posts, bidpost, truckModal)));
            },
            child: Card(
                // color: Colors.red,

                elevation: 4,
                child: Column(
                  children: [
                    Container(
                      // height: 20,
                      padding:
                          const EdgeInsets.only(top: 20, left: 10, right: 10),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(posts.loadposttime!.split(',')[1] +
                                  posts.loadposttime!.split(',')[2])
                            ],
                          ),
                          SizedBox(height: height * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                posts.sourcelocation!,
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          const Icon(Icons.arrow_downward),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                posts.destinationlocation!,
                                style: GoogleFonts.lato(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),

                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Column(
                          //       children: [
                          //         Text(
                          //           posts.sourcelocation!.split(',')[0],
                          //           style: GoogleFonts.lato(
                          //               fontWeight: FontWeight.bold,
                          //               fontSize: 16),
                          //         ),
                          //         Text(posts.sourcelocation!.split(',')[1]),
                          //       ],
                          //     ),
                          //     const Icon(Icons.arrow_right_alt_outlined),
                          //     Column(
                          //       children: [
                          //         Text(
                          //           posts.destinationlocation!.split(',')[0],
                          //           style: GoogleFonts.lato(
                          //               fontWeight: FontWeight.bold,
                          //               fontSize: 16),
                          //         ),
                          //         Text(posts.destinationlocation!.split(',')[1]),
                          //       ],
                          //     )
                          //   ],
                          // ),
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
                                children: [
                                  const Text("Original Amount ",
                                      style: TextStyle(fontSize: 18)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/rupee-indian.png',
                                        height: 20,
                                        width: 20,
                                      ),
                                      Text(posts.expectedprice!,
                                          style:
                                              GoogleFonts.lato(fontSize: 30)),
                                    ],
                                  ),
                                  Text(
                                      posts.priceunit == 'tonne'
                                          ? "per ${posts.priceunit}"
                                          : posts.priceunit!,
                                      style: const TextStyle(fontSize: 18)),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text("Bid Amount",
                                      style: TextStyle(fontSize: 18)),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/rupee-indian.png',
                                        height: 20,
                                        width: 20,
                                      ),
                                      Text(bidpost.rate!,
                                          style:
                                              GoogleFonts.lato(fontSize: 30)),
                                    ],
                                  ),
                                  Text(
                                      posts.priceunit == 'tonne'
                                          ? "per ${posts.priceunit}"
                                          : posts.priceunit!,
                                      style: const TextStyle(fontSize: 18)),
                                ],
                              )
                            ],
                          )
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
                                      users.photourl!.isNotEmpty
                                          ? CircleAvatar(
                                              radius: 20,
                                              backgroundColor:
                                                  const Color(0xff4D4D4D),
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      users.photourl ?? ""),
                                            )
                                          : const CircleAvatar(
                                              radius: 20.0,
                                              backgroundColor:
                                                  Color(0xff4D4D4D),
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
}

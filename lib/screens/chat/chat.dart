import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/chatmodal.dart';
import 'package:thaartransport/modal/truckmodal.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/screens/chat/currentuser.dart';
import 'package:thaartransport/modal/bidmodal.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:url_launcher/url_launcher.dart';

class Chat extends StatefulWidget {
  UserModel users;
  PostModal posts;
  BidModal bidpost;
  TruckModal truckModal;
  Chat(this.users, this.posts, this.bidpost, this.truckModal);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController messageController = TextEditingController();
  TextEditingController rate = TextEditingController();

  callNow() async {
    launch('tel://$user.usernumber!');
    await FlutterPhoneDirectCaller.callNumber(widget.users.usernumber!);
  }

  fetchbidaccept() async {
    await bidRef
        .where('loadid', isEqualTo: widget.posts.postid)
        // .where('loadpostid', isEqualTo: UserService().currentUid())
        .where('bidresponse', isEqualTo: "Bid Accepted")
        .get()
        .then((value) {
      bidaceptdoc = value.docs;
      print(bidaceptdoc.length);
      bidaceptdoc.forEach((element) {
        setState(() {
          print(element['bidresponse']);
          bidaccepted = element['bidresponse'];
        });
      });
    });
  }

  fetchbidcomplet() async {
    await bidRef
        .where('loadid', isEqualTo: widget.posts.postid)
        // .where('loadpostid', isEqualTo: UserService().currentUid())
        .where('bidresponse', isEqualTo: "Bid Completed")
        .get()
        .then((value) {
      bidcompletdoc = value.docs;
      print(bidcompletdoc.length);
      bidcompletdoc.forEach((element) {
        setState(() {
          print(element['bidresponse']);
          bidcomplet = element['bidresponse'];
        });
      });
    });
  }

  List bidaceptdoc = [];
  String bidaccepted = '';
  List bidcompletdoc = [];
  String bidcomplet = '';

  // fetchTruck() async {
  //   await truckRef
  //       .collection('changeslorry')
  //       .where('truckposttime', isEqualTo: widget.bidpost.truckposttime)
  //       .get()
  //       .then((value) {
  //     print(value);
  //   });
  // }

  @override
  void initState() {
    super.initState();
    fetchbidaccept();
  }

  truckdata() {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LineIcons.truck),
              const SizedBox(
                width: 10,
              ),
              Text(
                widget.truckModal.lorrynumber.toString(),
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            children: [
              const Icon(
                Icons.circle,
                color: Colors.green,
                size: 15,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(widget.truckModal.sourcelocation.toString()),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              const Icon(
                Icons.circle,
                color: Colors.red,
                size: 15,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(widget.truckModal.destinationlocation.toString()),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Original Price",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text.rich(TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      text: "${widget.posts.expectedprice} ",
                      children: [
                        TextSpan(
                            text:
                                widget.posts.priceunit == "tonne" ? "per" : "",
                            children: [
                              TextSpan(
                                text: " ${widget.posts.priceunit}",
                              )
                            ])
                      ]))
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Capacity",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    "${widget.truckModal.capacity} tonne",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Routes",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    widget.truckModal.routes!.length.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  postdata() {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.circle,
                color: Colors.green,
                size: 15,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(widget.posts.sourcelocation.toString()),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            children: [
              const Icon(
                Icons.circle,
                color: Colors.red,
                size: 15,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(widget.posts.destinationlocation.toString()),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Original Price",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  // Text(widget.posts.expectedprice.toString()),
                  Text.rich(TextSpan(
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      text: "${widget.posts.expectedprice} ",
                      children: [
                        TextSpan(
                            text:
                                widget.posts.priceunit == "tonne" ? "per" : "",
                            children: [
                              TextSpan(
                                text: " ${widget.posts.priceunit}",
                              )
                            ])
                      ]))
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Material",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    widget.posts.material.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Quantity",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    widget.posts.quantity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  String bidresponse = '';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
        titleSpacing: 0,
        title: ListTile(
          contentPadding: const EdgeInsets.all(0),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(widget.users.photourl.toString()),
          ),
          title: Text(
            widget.users.username.toString(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            widget.posts.loadorderstatus == "Completed"
                ? widget.posts.loadorderstatus.toString()
                : widget.posts.loadorderstatus == "Active"
                    ? widget.posts.loadorderstatus.toString()
                    : widget.posts.loadorderstatus == "InTransit"
                        ? widget.posts.loadorderstatus.toString()
                        : widget.posts.loadorderstatus.toString(),
            style: TextStyle(
                fontSize: 16,
                color: widget.posts.loadorderstatus == "Active"
                    ? Colors.green.shade900
                    : widget.posts.loadorderstatus == "Completed"
                        ? Colors.blue.shade900
                        : widget.posts.loadorderstatus == "InTransit"
                            ? Colors.purple.shade900
                            : Colors.indigo.shade900),
          ),
        ),
        actions: [
          FlatButton.icon(
              onPressed: () {
                widget.bidpost.bidresponse == "Bid Accepted"
                    ? callNow()
                    : widget.bidpost.bidresponse == "Bid Completed"
                        ? callNow()
                        : null;
              },
              icon: Icon(Icons.call,
                  color: widget.bidpost.bidresponse == "Bid Accepted"
                      ? Colors.black
                      : widget.bidpost.bidresponse == "Bid Completed"
                          ? Colors.black
                          : Colors.black12),
              label: Text(
                "Call Now",
                style: TextStyle(
                    color: widget.bidpost.bidresponse == "Bid Accepted"
                        ? Colors.black
                        : widget.bidpost.bidresponse == "Bid Completed"
                            ? Colors.black
                            : Colors.black12),
              ))
        ],
      ),
      body: Column(
        children: [
          Container(
            // color: Colors.red,
            child: ExpansionTileCard(
              baseColor: Colors.cyan[50],
              // expandedColor: Colors.red[50],
              title: Text("View Details"),
              children: [
                widget.bidpost.truckownerid == UserService().currentUid()
                    ? postdata()
                    : truckdata()
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: bidRef
                    .doc(widget.bidpost.id)
                    .collection('bidmessage')
                    .orderBy('bidtime')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Container();
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center();
                  }
                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      physics: const ScrollPhysics(),
                      padding: const EdgeInsets.all(8),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        ChatModal chatModal = ChatModal.fromJson(
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>);

                        return messages(
                            chatModal,
                            chatModal.biduserid == UserService().currentUid(),
                            context);
                      });
                }),
          ),
          Container(
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white, border: Border.all(color: Colors.black)),
            child: Card(
              elevation: 10,
              child: StreamBuilder<DocumentSnapshot>(
                  stream: bidRef.doc(widget.bidpost.id).snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text("Somthing went  wrong");
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center();
                    }
                    return CurrentUser(
                        snapshot.data!.get('negotiateprice'),
                        snapshot.data!.get('rate'),
                        snapshot.data!.get('bid'),
                        snapshot.data!.get('id'),
                        snapshot.data!.get('bidresponse'),
                        widget.posts,
                        snapshot.data!.get('loaderimage'),
                        snapshot.data!.get('truckownerid'),
                        snapshot.data!.get('truckimage'),
                        snapshot.data!.get('bidid'),
                        bidaccepted,
                        widget.users,
                        bidcomplet);
                    // : NotCurrentUser(
                    //     snapshot.data!.get('negotiateprice'),
                    //     snapshot.data!.get('rate'),
                    //     snapshot.data!.get('bid'),
                    //     snapshot.data!.get('id'),
                    //     snapshot.data!.get('bidresponse'),
                    //     widget.posts,
                    //     snapshot.data!.get('loaderimage'));
                  }),
            ),
          )
        ],
      ),
    );
  }

  Widget messages(ChatModal chatModal, bool sendBy, BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return chatModal.type == "text"
        ? Container(
            width: size.width,
            alignment: sendBy ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.cyan.shade300,
                    ),
                    child: Text.rich(TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        text: "${chatModal.rate} ",
                        children: [
                          TextSpan(
                              text: widget.posts.priceunit == "tonne"
                                  ? "per"
                                  : "",
                              children: [
                                TextSpan(
                                  text: " ${widget.posts.priceunit}",
                                )
                              ])
                        ]))),
                // Text(DateTime.now().toString())
              ],
            ),
          )
        : chatModal.type == 'reject'
            ? Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.red,
                ),
                child: Text(
                  chatModal.rate.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ))
            : chatModal.type == 'accept'
                ? Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.green,
                    ),
                    child: Text(
                      chatModal.rate.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ))
                : chatModal.type == "complete"
                    ? Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Color(0XFF142438),
                        ),
                        child: Column(
                          children: [
                            Text(
                              chatModal.rate.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text.rich(TextSpan(
                                text: 'Remakrs: ',
                                style: const TextStyle(
                                    fontSize: 17, color: Colors.white),
                                children: [
                                  TextSpan(
                                      text: chatModal.completeremarks,
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.white))
                                ]))
                          ],
                        ))
                    : Container(
                        height: size.height / 2.5,
                        width: size.width,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
                        alignment: sendBy
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ShowImage(
                                imageUrl: chatModal.rate.toString(),
                              ),
                            ),
                          ),
                          child: Container(
                            height: size.height / 2.5,
                            width: size.width / 2,
                            decoration: BoxDecoration(border: Border.all()),
                            alignment:
                                chatModal.rate != "" ? null : Alignment.center,
                            child: chatModal.rate != ""
                                ? Image.network(
                                    chatModal.rate.toString(),
                                    fit: BoxFit.cover,
                                  )
                                : const CircularProgressIndicator(),
                          ),
                        ),
                      );
  }
}

class ShowImage extends StatelessWidget {
  final String imageUrl;

  const ShowImage({required this.imageUrl, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        color: Colors.black,
        child: Image.network(imageUrl),
      ),
    );
  }
}

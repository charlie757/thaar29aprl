import 'package:blinking_text/blinking_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/truckmodal.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/screens/chat/chat.dart';
import 'package:thaartransport/modal/bidmodal.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/widget/flickerwidget.dart';
import 'package:thaartransport/widget/internetmsg.dart';
import '../../NEW/truckpostuser/truckhomepage.dart';

class OnGoingOrders extends StatefulWidget {
  const OnGoingOrders({Key? key}) : super(key: key);

  @override
  _OnGoingOrdersState createState() => _OnGoingOrdersState();
}

class _OnGoingOrdersState extends State<OnGoingOrders> {
  TextEditingController rate = TextEditingController();

  final bidMessageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool validate = false;

  bool submitLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  var count = "";

  bool loading = false;

  int amount = 0;
  retriveCurrentUser() {
    usersRef.doc(UserService().currentUid()).get().then((value) {
      if (mounted) {}

      amount = value.get('amount');
      print(amount);
    });
  }

  List biddocs = [];
  bidaceceptcount() async {
    await bidRef
        .where('truckownerid', isEqualTo: UserService().currentUid())
        .where('bidresponse', isEqualTo: 'Bid Accepted')
        .get()
        .then((value) {
      biddocs = value.docs;
      print("bidaceceptcount ${biddocs.length}");
    });
  }

  fetchtruckidfrombid() async {
    bidRef
        .where('truckownerid', isEqualTo: UserService().currentUid())
        .get()
        .then((value) {
      bidtruckdoc = value.docs;
      bidtruckdoc.forEach((element) {
        truckdata(element['truckid'], element['truckposttime']);
      });
    });
  }

  String truckid = '';
  List truckdoc = [];
  List bidtruckdoc = [];
  truckdata(String ownerid, String truckposttime) async {
    await truckRef.where('id', isEqualTo: ownerid).get().then((value) {
      truckdoc = value.docs;
      truckdoc.forEach((element) {
        truckid = element['id'];
        truckchangesdata(element['id'], truckposttime);
        print(truckid);
      });
    });
  }

  truckchangesdata(String truckid, String trucktime) async {
    await truckRef
        .doc(truckid)
        .collection('changeslorry')
        .where('truckposttime', isEqualTo: trucktime)
        .get()
        .then((value) {
      truckchangesdoc = value.docs;
      truckchangesdoc.forEach((element) {
        print(element['truckposttime']);
      });
    });
  }

  List truckchangesdoc = [];

  @override
  void initState() {
    bidaceceptcount();
    retriveCurrentUser();
    fetchtruckidfrombid();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    return !isOnline
        ? internetchecker()
        : StreamBuilder<QuerySnapshot>(
            stream: bidRef
                .where('truckownerid', isEqualTo: UserService().currentUid())
                .where('bidresponse', isNotEqualTo: "Bid Completed")
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text("Somthing went Wrong");
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return FlickerWidget();
              } else if (snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text("Yet No Bids", style: TextStyle(fontSize: 18)));
              }
              return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(top: 15),
                  physics: const ScrollPhysics(),
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
    return StreamBuilder<QuerySnapshot>(
        stream: postRef.where('postid', isEqualTo: bidpost.loadid).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text("Somthing went Wrong");
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center();
          }
          return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.all(0),
              physics: const ScrollPhysics(),
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
          // not role of this
          TruckModal truckModal = TruckModal.fromJson(
              snapshot.data!.data() as Map<String, dynamic>);
          UserModel users =
              UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
          return Column(
            children: [
              InkWell(
                onTap: () {
                  bidpost.bidresponse == ""
                      ? biddocs.length >= 5
                          ? amount < 500
                              ? addMoneyAlert(context)
                              : Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Chat(
                                          users, posts, bidpost, truckModal)))
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Chat(users, posts, bidpost, truckModal)))
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  Chat(users, posts, bidpost, truckModal)));
                },
                child: Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        Container(
                          // height: 20,
                          padding: const EdgeInsets.only(left: 8, right: 10),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        const Text(
                                          "posted on:",
                                          style: TextStyle(fontSize: 12),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    posts.sourcelocation!,
                                    style: GoogleFonts.lato(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("Original Amount",
                                      style: TextStyle(fontSize: 17)),
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/rupee-indian.png',
                                        height: 18,
                                        width: 18,
                                      ),
                                      Text(posts.expectedprice!,
                                          style:
                                              GoogleFonts.lato(fontSize: 20)),
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
                        ),
                        Card(
                            elevation: 0,
                            color: const Color.fromARGB(31, 141, 126, 126),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(0),
                              leading: users.photourl!.isNotEmpty
                                  ? CircleAvatar(
                                      radius: 20,
                                      backgroundColor: const Color(0xff4D4D4D),
                                      backgroundImage: NetworkImage(
                                          users.photourl.toString()))
                                  : const CircleAvatar(
                                      radius: 20.0,
                                      backgroundColor: Color(
                                        0xff4D4D4D,
                                      ),
                                      child: Icon(
                                        Icons.people_alt,
                                        size: 50,
                                      ),
                                    ),
                              title: Text(
                                users.username == ''
                                    ? ''
                                    : users.username.toString(),
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w800),
                              ),
                              trailing: bidpost.bidresponse == "Bid Accepted"
                                  ? Container(
                                      width: 130,
                                      height: 35,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.green.shade900)),
                                      child: BlinkText(
                                        'Bid Accepted',
                                        endColor: Colors.green.shade900,
                                        style: const TextStyle(
                                            color: Color(0XFF142438),
                                            fontSize: 17),
                                      ),
                                    )
                                  : bidpost.bidresponse == "Bid Rejected"
                                      ? Container(
                                          width: 130,
                                          height: 35,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Constants.alert)),
                                          child: BlinkText(
                                            'Bid Rejected',
                                            endColor: Constants.alert,
                                            style: const TextStyle(
                                                color: Color(0XFF142438),
                                                fontSize: 17),
                                          ),
                                        )
                                      : bidpost.bidresponse == ""
                                          ? Container(
                                              width: 130,
                                              height: 35,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors
                                                          .indigo.shade900)),
                                              child: BlinkText(
                                                "In-Progress",
                                                endColor:
                                                    Colors.indigo.shade900,
                                                style: const TextStyle(
                                                    color: Colors.orange,
                                                    fontSize: 17),
                                              ),
                                            )
                                          : Container(
                                              width: 130,
                                              height: 35,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors
                                                          .blue.shade900)),
                                              child: BlinkText(
                                                'Bid Completed',
                                                endColor: Colors.blue.shade900,
                                                style: const TextStyle(
                                                    color: Color(0XFF142438),
                                                    fontSize: 17),
                                              ),
                                            ),
                            )),
                      ],
                    )),
              ),
              const SizedBox(
                height: 20,
              )
            ],
          );
        });
  }

  addMoneyAlert(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Payment Alert",
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
                MaterialPageRoute(builder: (context) => TruckHomePage(2)));
          },
          color: Constants.maincolor,
        )
      ],
    ).show();
  }
}

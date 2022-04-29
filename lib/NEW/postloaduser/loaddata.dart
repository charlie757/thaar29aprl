// ignore_for_file: unrelated_type_equality_checks, prefer_const_constructors

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:jiffy/jiffy.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thaartransport/NEW/currentuserprovider.dart';
import 'package:thaartransport/NEW/truckpostuser/truckhomepage.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/truckmodal.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/screens/myorders/mybidorder.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/controllers.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/widget/cached_image.dart';
import 'package:thaartransport/widget/indicatiors.dart';
//import 'package:flutter_icons/flutter_icons.dart';
import 'package:timeago/timeago.dart' as timeago;

class LoadData extends StatefulWidget {
  final PostModal posts;
  // final UserModel users;

  LoadData({
    required this.posts,
  });

  @override
  State<LoadData> createState() => _LoadDataState();
}

class _LoadDataState extends State<LoadData> {
  final DateTime timestamp = DateTime.now();

  final _formKey = GlobalKey<FormState>();

  bool validate = false;

  bool isLoading = false;
  bool readOnly = false;

  retriveCurrentUser() {
    usersRef.doc(UserService().currentUid()).get().then((value) {
      if (mounted) {
        setState(() {
          isTruck = value.get('isTruck');
          totalAmount = value.get('amount');
        });
      }
    });
  }

  bool? isTruck;
  int totalAmount = 0;

  void initState() {
    super.initState();
    postusers();
    haveBid();
    retriveCurrentUser();
    bidaceceptcount();
  }

  List biddocs = [];
  bidaceceptcount() async {
    await bidRef
        .where('truckownerid', isEqualTo: UserService().currentUid())
        .where('bidresponse', isEqualTo: 'Bid Accepted')
        .get()
        .then((value) {
      setState(() {
        biddocs = value.docs;
      });
      print("bidaceceptcount ${biddocs.length}");
    });
  }

  postusers() async {
    await usersRef.doc(widget.posts.ownerId).get().then((value) {
      setState(() {
        username = value.get('username');
        companyName = value.get('companyname');
        userdp = value.get('photourl');
      });
    });
  }

  haveBid() async {
    await bidRef
        .where('truckownerid', isEqualTo: UserService().currentUid())
        .where('loadid', isEqualTo: widget.posts.postid)
        .get()
        .then((value) {
      setState(() {
        havebidCount = value.docs;
      });
    });
  }

  List havebidCount = [];
  String username = '';
  String companyName = '';
  String userdp = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LoadPosts(
          context,
          widget.posts.loadstatus!,
          widget.posts.loadposttime!,
          widget.posts.sourcelocation!,
          widget.posts.destinationlocation!,
          widget.posts.material!,
          widget.posts.quantity!,
          widget.posts.expectedprice!,
          widget.posts,
          widget.posts.priceunit!,
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  Widget LoadPosts(
    BuildContext context,
    String status,
    String postTime,
    String source,
    String destination,
    String material,
    String quantity,
    String expectedPrice,
    PostModal posts,
    String priceunit,
  ) {
    var ref = posts.postid;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: () async {
        print(isTruck);
        print(havebidCount.length);
        isTruck == false
            ? alertDialog(context)
            : biddocs.length >= 5
                ? totalAmount < 500
                    ? addMoneyAlert(context)
                    : havebidCount.isEmpty
                        ? selectLorry(context, posts)
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MyBidOrder()))
                : havebidCount.isEmpty
                    ? selectLorry(context, posts)
                    : Navigator.push(context,
                        MaterialPageRoute(builder: (context) => MyBidOrder()));
      },
      child: Card(
          // color: Colors.red,

          elevation: 8,
          child: Column(
            children: [
              Container(
                // height: 20,
                padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                child: Column(
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Posted on:",
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(postTime.split(',')[1] + postTime.split(',')[2])
                      ],
                    ),
                    SizedBox(height: height * 0.02),
                    Container(
                      color: Color.fromARGB(31, 146, 131, 131),
                      height: 35,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                Text("From:"),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  source.split(',')[0],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          ),
                          Container(
                            child: Row(
                              children: [
                                Text("To:"),
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  destination.split(',')[0],
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Divider(),
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
                                material,
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                                "$quantity Tons",
                                style: TextStyle(fontWeight: FontWeight.bold),
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
                      children: [
                        Image.asset(
                          'assets/images/rupee-indian.png',
                          height: 20,
                          width: 20,
                        ),
                        Text(expectedPrice,
                            style: GoogleFonts.lato(fontSize: 18)),
                        Text(priceunit == 'tonne' ? " per" : '',
                            style: const TextStyle(fontSize: 18)),
                        SizedBox(
                          width: width * 0.02,
                        ),
                        Text(priceunit, style: GoogleFonts.lato(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: height * 0.01),
              Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Card(
                      elevation: 0,
                      child: Container(
                          width: width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                  child: Container(
                                child: Row(
                                  children: [
                                    userdp.isNotEmpty
                                        ? CircleAvatar(
                                            radius: 20,
                                            backgroundColor:
                                                const Color(0xff4D4D4D),
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                                    userdp),
                                          )
                                        : const CircleAvatar(
                                            radius: 20.0,
                                            backgroundColor: Color(0xff4D4D4D),
                                          ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Flexible(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(username,
                                            style: GoogleFonts.roboto(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18)),
                                        Text(companyName.isNotEmpty
                                            ? ''
                                            : companyName.toString())
                                      ],
                                    )),
                                  ],
                                ),
                              )),
                              Flexible(
                                  child: Container(
                                child: havebidCount.length < 1
                                    ? FlatButton(
                                        color: Colors.black,
                                        onPressed: () {
                                          isTruck == false
                                              ? alertDialog(context)
                                              : biddocs.length >= 5
                                                  ? totalAmount < 500
                                                      ? addMoneyAlert(context)
                                                      : havebidCount.isEmpty
                                                          ? selectLorry(
                                                              context,
                                                              posts,
                                                            )
                                                          : Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          MyBidOrder()))
                                                  : havebidCount.isEmpty
                                                      ? selectLorry(
                                                          context, posts)
                                                      : Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  MyBidOrder()));
                                        },
                                        child: Container(
                                            width: 120,
                                            alignment: Alignment.center,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Icon(
                                                  Icons.call,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                Text(
                                                  "Bid",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20),
                                                )
                                              ],
                                            )))
                                    : FlatButton(
                                        color: Color(0XFFF77F00),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MyBidOrder()));
                                        },
                                        child: Container(
                                            width: 120,
                                            alignment: Alignment.center,
                                            child: Text(
                                              "Biding",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20),
                                            ))),
                              ))
                            ],
                          ))))
            ],
          )),
    );
  }

  selectLorry(BuildContext context, PostModal post) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                color: const Color(0xFF737373),
                height: MediaQuery.of(context).size.height / 1.3,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  child: widgetsheet(post),
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

  widgetsheet(PostModal post) {
    return StatefulBuilder(builder: (context, setstate) {
      return StreamBuilder(
          stream: truckRef
              .where('ownerId', isEqualTo: UserService().currentUid())
              .where('truckstatus', isEqualTo: 'ACTIVE')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              // return const Scaffold(body: Text("Somthing went Wrong"));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: circularProgress(context));
            } else if (snapshot.data!.docs.isEmpty) {
              return Container(
                  alignment: Alignment.center,
                  child: const Text(
                    "You have no active truck at the moment",
                  ));
            }

            return SingleChildScrollView(
              child: Wrap(
                children: [
                  Column(
                    children: [
                      Container(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select your lorry to Bid",
                            style: GoogleFonts.lato(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close))
                        ],
                      )),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            TruckModal truckModal = TruckModal.fromJson(
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>);

                            return InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                bidSheet(context, post, truckModal);
                              },
                              child: Card(
                                elevation: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                            width: 100,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.black12),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Text(
                                              truckModal.truckstatus.toString(),
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: truckModal
                                                              .truckstatus ==
                                                          "ACTIVE"
                                                      ? Constants.cursorColor
                                                      : Constants.alert),
                                            )),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.all(0),
                                        leading: const Icon(
                                          LineIcons.truck,
                                          color: Colors.red,
                                        ),
                                        title: Text(
                                          truckModal.lorrynumber.toString(),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 18),
                                        ),
                                        subtitle: Text(
                                            "posted on ${truckModal.truckposttime!.split(',')[1] + truckModal.truckposttime!.split(',')[2]}"),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.circle,
                                              size: 10, color: Colors.green),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            truckModal.sourcelocation
                                                .toString(),
                                            style: TextStyle(fontSize: 15),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.circle,
                                              size: 10, color: Colors.red),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Text(
                                            truckModal.destinationlocation
                                                .toString(),
                                            style:
                                                const TextStyle(fontSize: 15),
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(LineIcons.truck,
                                                      size: 15,
                                                      color: Colors.black26),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Text(
                                                    '${truckModal.capacity} Tonne',
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  )
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(Icons.location_on,
                                                      size: 15,
                                                      color: Colors.black26),
                                                  const SizedBox(
                                                    width: 15,
                                                  ),
                                                  Text(
                                                    truckModal.routes!.length
                                                        .toString(),
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })
                    ],
                  )
                ],
              ),
            );
          });
    });
  }

  ////Bid
  bidSheet(BuildContext context, PostModal post, TruckModal truckModal) {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (
          context,
        ) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                color: Color(0xFF737373),
                child: Container(
                  child: _buildBidSheet(context, post, truckModal
                      // user,
                      ),
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

  _buildBidSheet(BuildContext context, PostModal posts, TruckModal truckModal) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return StatefulBuilder(builder: (context, state) {
      return Form(
          key: _formKey,
          child: Wrap(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(username.toString()),
                    subtitle: Row(
                      children: [
                        Image.asset(
                          'assets/images/rupee-indian.png',
                          height: 16,
                          width: 16,
                        ),
                        Text(posts.expectedprice.toString(),
                            style: GoogleFonts.lato(fontSize: 18)),
                        Text(posts.priceunit == 'tonne' ? " per" : '',
                            style: const TextStyle(fontSize: 16)),
                        SizedBox(
                          width: width * 0.02,
                        ),
                        Text(posts.priceunit.toString(),
                            style: GoogleFonts.lato(fontSize: 16)),
                      ],
                    ),
                    trailing: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.close_rounded),
                    ),
                    leading: CircleAvatar(
                      child: ClipOval(
                        child: cachedNetworkImage(userdp),
                      ),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(left: 8),
                      color: Constants.h2lhbg,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 60,
                                child: Text("From:"),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(posts.sourcelocation.toString())
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              Container(
                                width: 60,
                                child: Text("To:"),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(posts.destinationlocation.toString())
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    Text("Material:"),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(posts.material.toString()),
                                  ],
                                ),
                              ),
                              Container(
                                height: 15,
                                child: VerticalDivider(
                                  color: Colors.black,
                                  // thickness: 2,
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: [
                                    Text("Tonne:"),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(posts.quantity.toString())
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      )),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  Container(
                    height: 30,
                    alignment: Alignment.center,
                    width: 100,
                    color: Colors.grey[300],
                    child: Text(posts.loadposttime!.split(',')[1]),
                  ),
                  SizedBox(height: height * 0.02),
                  Card(
                      elevation: 8,
                      child: Container(
                        margin: EdgeInsets.all(15),
                        padding: EdgeInsets.only(bottom: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text.rich(TextSpan(
                                style: GoogleFonts.robotoSlab(fontSize: 16),
                                text: "Send Response to ",
                                children: [
                                  TextSpan(
                                      style: GoogleFonts.robotoSlab(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500),
                                      text: companyName.isEmpty
                                          ? companyName.toString()
                                          : username.toString())
                                ])),
                            TextFormField(
                              cursorColor: Constants.cursorColor,
                              readOnly: readOnly,
                              controller: rateController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                  hintText: "INR 800",
                                  labelStyle:
                                      GoogleFonts.kanit(color: Colors.black),
                                  labelText: "Please enter your rate",
                                  suffix: Container(
                                    margin: EdgeInsets.only(right: 10),
                                    child: Text(posts.priceunit!,
                                        style:
                                            TextStyle(color: Constants.alert)),
                                  )),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter your rate';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: height * 0.02,
                            ),
                            TextFormField(
                              controller: remakrsController,
                              readOnly: readOnly,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                  hintText: "Enter your remarks",
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder()),
                            )
                          ],
                        ),
                      )),
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: RaisedButton(
                        color: Color(0XFF142438),
                        onPressed: () async {
                          FormState? form = _formKey.currentState;
                          form!.save();
                          if (!form.validate()) {
                            validate = true;
                          } else {
                            try {
                              state(() {});
                              if (this.mounted) {
                                setState(() {
                                  isLoading = true;
                                  readOnly = true;
                                });
                              }
                              var id = bidRef.doc().id;
                              await bidRef.doc(id).set({
                                'rate': rateController.text,
                                'remarks': remakrsController.text,
                                'bidtime': Jiffy(DateTime.now()).yMMMMEEEEdjm,
                                'biduserid': UserService().currentUid(),
                                'bidresponse': "",
                                'loadid': posts.postid,
                                'loadpostid': posts.ownerId,
                                'negotiateprice': "",
                                'truckownerid': UserService().currentUid(),
                                'truckid': truckModal.id,
                                'id': id,
                                'loaderimage': false,
                                'truckimage': false,
                                'bid': true,
                                'transpmt': '',
                                'shipperpmt': '',
                                'bidid': UserService().currentUid(),
                                "truckposttime": truckModal.truckposttime,
                              }).catchError((e) {
                                print(e);
                              });

                              await postRef.doc(posts.postid).update({
                                'loadorderstatus': 'InProgress',
                              });
                              await bidRef
                                  .doc(id)
                                  .collection('bidmessage')
                                  .doc()
                                  .set({
                                'rate': rateController.text,
                                'bidtime': FieldValue.serverTimestamp(),
                                'biduserid': UserService().currentUid(),
                                'type': "text",
                              });

                              state(() {});
                              if (mounted) {
                                setState(() {
                                  isLoading = false;
                                  readOnly = false;
                                });
                              }
                              await CoolAlert.show(
                                  context: context,
                                  type: CoolAlertType.loading,
                                  text:
                                      'Your bid has been placed successfully, Please wait for the transporter to respond',
                                  lottieAsset: 'assets/1708-success.json',
                                  autoCloseDuration: Duration(seconds: 2),
                                  animType: CoolAlertAnimType.slideInUp,
                                  title: 'Bidding Successfully');

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyBidOrder()));
                              rateController.clear();
                              remakrsController.clear();
                              state(() {});
                              setState(() {
                                isLoading = false;
                              });
                            } catch (e) {
                              print(e);
                            }
                            state(() {});
                            if (mounted) {
                              setState(() {
                                isLoading = false;
                                readOnly = false;
                              });
                            }
                          }
                        },
                        child: Container(
                            alignment: Alignment.center,
                            height: 45,
                            width: width,
                            child: isLoading
                                ? circularProgress(context)
                                : Text(
                                    "Bid Now",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ))),
                  )
                ],
              )
            ],
          ));
    });
  }

  addMoneyAlert(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Payment Alert",
      desc: "You do not have sufficient amount for next bid.",
      buttons: [
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          onPressed: () => Navigator.pop(context),
          // color: Colors.,
        ),
        DialogButton(
          child: Text(
            "Add Money",
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TruckHomePage(2)));
          },
          color: Color(0XFF142438),
        )
      ],
    ).show();
  }

  alertDialog(BuildContext context) {
    return CoolAlert.show(
      onConfirmBtnTap: () {
        Navigator.pop(context);
      },
      context: context,
      type: CoolAlertType.warning,
      lottieAsset: 'assets/42833-oops-animation.json',
      text: 'You do not have an Truck',
      animType: CoolAlertAnimType.slideInUp,
      // title: 'Sorry!!'
    );
  }
}

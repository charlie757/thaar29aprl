// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/currentuserprovider.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/bidmodal.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/widget/indicatiors.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class CurrentUser extends StatefulWidget {
  String negotiateprice;
  String rate;
  bool bid;
  String id;
  String bidresponse;
  PostModal posts;
  bool loaderimage;
  String truckownerid;
  bool truckimage;
  String bidid;
  String bidaccepted;
  UserModel users;
  String bidcomplete;
  CurrentUser(
      this.negotiateprice,
      this.rate,
      this.bid,
      this.id,
      this.bidresponse,
      this.posts,
      this.loaderimage,
      this.truckownerid,
      this.truckimage,
      this.bidid,
      this.bidaccepted,
      this.users,
      this.bidcomplete);

  @override
  State<CurrentUser> createState() => _CurrentUserState();
}

class _CurrentUserState extends State<CurrentUser> {
  TextEditingController rate = TextEditingController();

  TextEditingController remakrsController = TextEditingController();
  bool isLoading = false;
  bool imageLoading = false;
  File? imageFile;
  bool bidloading = false;

  Future getImage(ImageSource source) async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: source).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = Uuid().v1();
    int status = 1;
    setState(() {
      imageLoading = true;
    });
    await bidRef.doc(widget.id).collection('bidmessage').doc(fileName).set({
      "biduserid": UserService().currentUid(),
      "bidtime": FieldValue.serverTimestamp(),
      "type": "img",
      "rate": ""
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await bidRef
          .doc(widget.id)
          .collection('bidmessage')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await bidRef
          .doc(widget.id)
          .collection('bidmessage')
          .doc(fileName)
          .update({"rate": imageUrl});

      await bidRef.doc(widget.id).update({"loaderimage": true});

      print(imageUrl);

      setState(() {
        imageLoading = false;
      });
    }
  }

  Future truckimage(ImageSource source) async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: source).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadtruckimage();
      }
    });
  }

  Future uploadtruckimage() async {
    String fileName = Uuid().v1();
    int status = 1;

    await bidRef.doc(widget.id).collection('bidmessage').doc(fileName).set({
      "biduserid": UserService().currentUid(),
      "bidtime": FieldValue.serverTimestamp(),
      "type": "img",
      "rate": ""
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await bidRef
          .doc(widget.id)
          .collection('bidmessage')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await bidRef
          .doc(widget.id)
          .collection('bidmessage')
          .doc(fileName)
          .update({"rate": imageUrl});

      await bidRef.doc(widget.id).update({
        "truckimage": true,
      });

      print(imageUrl);
    }
  }

  postUser() async {
    await usersRef.doc(widget.posts.ownerId).get().then((value) {
      postuserAmt = value.get('amount');
    });
  }

  postbidCount() async {
    await bidRef
        .where('loadpostid', isEqualTo: widget.posts.ownerId)
        .where('bidresponse', isEqualTo: "Bid Accepted")
        .get()
        .then((value) {
      postbidcount = value.docs;
    });
  }

  truckbidCount() async {
    await bidRef
        .where('truckownerid', isEqualTo: widget.truckownerid)
        .where('bidresponse', isEqualTo: "Bid Accepted")
        .get()
        .then((value) {
      truckbidcount = value.docs;
    });
  }

  truckUser() async {
    await usersRef.doc(widget.truckownerid).get().then((value) {
      truckuserAmt = value.get('amount');
    });
  }

  int postuserAmt = 0;
  int truckuserAmt = 0;
  List postbidcount = [];
  List truckbidcount = [];
  @override
  Widget build(BuildContext context) {
    CurrentUserProvider currentUserProvider =
        Provider.of<CurrentUserProvider>(context);
    currentUserProvider.bidaceceptcount();
    truckUser();
    postUser();
    postbidCount();
    truckbidCount();
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const Text(
            //   "Original price",
            //   style: TextStyle(fontStyle: FontStyle.italic, fontSize: 16),
            // ),
            // const SizedBox(
            //   height: 5,
            // ),
            // Row(
            //   children: [
            //     Image.asset(
            //       'assets/images/rupee-indian.png',
            //       height: 20,
            //       width: 20,
            //     ),
            //     Text(
            //       widget.posts.expectedprice.toString(),
            //       style: const TextStyle(fontSize: 18),
            //     ),
            //     const SizedBox(
            //       width: 2,
            //     ),
            //     Text(
            //       widget.posts.priceunit == "tonne" ? "per" : "",
            //       style: const TextStyle(fontSize: 18),
            //     ),
            //     const SizedBox(
            //       width: 2,
            //     ),
            //     Text(
            //       widget.posts.priceunit.toString(),
            //       style: const TextStyle(fontSize: 18),
            //     )
            //   ],
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            widget.bidresponse == "Bid Accepted"
                ? widget.posts.ownerId == UserService().currentUid()
                    ? Row(
                        children: [
                          widget.loaderimage == false
                              ? Flexible(
                                  child: FlatButton(
                                      color: widget.loaderimage == true
                                          ? Colors.black12
                                          : Constants.btnBG,
                                      textColor: Colors.white,
                                      onPressed: () async {
                                        widget.loaderimage == true
                                            ? null
                                            : !imageLoading
                                                ? getImage(ImageSource.gallery)
                                                : Fluttertoast.showToast(
                                                    gravity:
                                                        ToastGravity.CENTER,
                                                    msg:
                                                        "Please wait while uploadig image");
                                      },
                                      child: Container(
                                          height: 40,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "Upload product Image",
                                          ))),
                                )
                              : Container(),
                          const SizedBox(
                            width: 8,
                          ),
                          widget.loaderimage == true
                              ? Flexible(
                                  child: FlatButton(
                                      color: Colors.green,
                                      textColor: Colors.white,
                                      onPressed: () async {},
                                      child: Container(
                                          height: 40,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "Bid Accepted",
                                          ))),
                                )
                              : Container()
                        ],
                      )
                    : widget.loaderimage == true &&
                            widget.truckownerid == UserService().currentUid()
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: FlatButton(
                                    color: widget.truckimage == false
                                        ? Constants.btnBG
                                        : Colors.black12,
                                    textColor: Colors.white,
                                    onPressed: () async {
                                      widget.truckimage == false
                                          ? truckimage(ImageSource.camera)
                                          : null;
                                    },
                                    child: Container(
                                        height: 40,
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "Upload Image",
                                        ))),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: FlatButton(
                                    color: Colors.blue,
                                    textColor: Colors.white,
                                    onPressed: () async {
                                      if (widget.truckimage == false) {
                                        Fluttertoast.showToast(
                                            msg: "Please upload image",
                                            gravity: ToastGravity.CENTER);
                                      } else {
                                        buildcompletedSheet();
                                      }
                                    },
                                    child: Container(
                                        height: 40,
                                        alignment: Alignment.center,
                                        child: const Text(
                                          "Complete Bid",
                                        ))),
                              ),
                            ],
                          )
                        : FlatButton(
                            color: Colors.green,
                            textColor: Colors.white,
                            onPressed: () async {},
                            child: Container(
                                height: 40,
                                alignment: Alignment.center,
                                child: const Text(
                                  "Bid Accepted",
                                )))
                : widget.bidresponse == "Bid Rejected"
                    ? FlatButton(
                        color: Constants.trucktheme,
                        textColor: Colors.white,
                        onPressed: () async {},
                        child: Container(
                            height: 40,
                            alignment: Alignment.center,
                            child: const Text(
                              "Bid Rejected",
                            )))
                    : widget.bidresponse == "Bid Completed"
                        ? FlatButton(
                            color: Colors.blue,
                            textColor: Colors.white,
                            onPressed: () async {},
                            child: Container(
                                height: 40,
                                alignment: Alignment.center,
                                child: const Text(
                                  "Bid Completed",
                                )))
                        : widget.bid == true &&
                                widget.bidid == UserService().currentUid()
                            ? Flexible(
                                child: FlatButton(
                                    color: Colors.orange,
                                    textColor: Colors.white,
                                    onPressed: () {},
                                    child: Container(
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: const Text(
                                        "Waiting for response",
                                      ),
                                    )))
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                      child: FlatButton(
                                          color: Colors.green,
                                          textColor: Colors.white,
                                          onPressed: () async {
                                            postbidcount.length >= 5 &&
                                                    widget.posts.ownerId ==
                                                        UserService()
                                                            .currentUid()
                                                ? postuserAmt > 500
                                                    ? Fluttertoast.showToast(
                                                        msg: "Add Money")
                                                    : null
                                                : truckbidcount.length >= 5 &&
                                                        widget.truckownerid ==
                                                            UserService()
                                                                .currentUid()
                                                    ? truckuserAmt > 500
                                                        ? Fluttertoast
                                                            .showToast(
                                                                msg:
                                                                    "Add Money")
                                                        : null
                                                    : widget.truckownerid ==
                                                                UserService()
                                                                    .currentUid() &&
                                                            (widget.bidaccepted ==
                                                                    "Bid Accepted" ||
                                                                widget.bidcomplete ==
                                                                    "Bid Completed")
                                                        ? showInSnackBar(
                                                            "${widget.users.username} is unable to continue this bid",
                                                            context)
                                                        : bidAccepted();
                                          },
                                          child: Container(
                                              height: 40,
                                              alignment: Alignment.center,
                                              child: bidloading
                                                  ? circularProgress(context)
                                                  : const Text(
                                                      "Accept Bid",
                                                    )))),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                      child: FlatButton(
                                          color: Colors.purple[600],
                                          textColor: Colors.white,
                                          onPressed: () {
                                            widget.truckownerid ==
                                                        UserService()
                                                            .currentUid() &&
                                                    (widget.bidaccepted ==
                                                            "Bid Accepted" ||
                                                        widget.bidcomplete ==
                                                            "Bid Completed")
                                                ? showInSnackBar(
                                                    "${widget.users.username} is unable to continue this bid",
                                                    context)
                                                : _onReBid();
                                          },
                                          child: Container(
                                            height: 40,
                                            alignment: Alignment.center,
                                            child: const Text(
                                              "Negotiate price",
                                            ),
                                          )))
                                ],
                              ),
            const SizedBox(
              height: 15,
            ),
            widget.bid
                ? Container()
                : Flexible(
                    child: InkWell(
                    onTap: () {
                      widget.bidresponse == "Bid Rejected"
                          ? null
                          : _onRejectBid();
                    },
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 45,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            border: Border.all(width: 2, color: Colors.red)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Reject Bid",
                              style: TextStyle(color: Colors.red, fontSize: 17),
                            ),
                          ],
                        )),
                  ))
          ],
        ),
      ),
    );
  }

  bidAccepted() async {
    final amt = postuserAmt - 500;
    final truckamt = truckuserAmt - 500;
    setState(() {
      bidloading = true;
    });
    try {
      postbidcount.length >= 5
          ? await usersRef.doc(widget.posts.ownerId).update({'amount': amt})
          : null;
      truckbidcount.length >= 5
          ? await usersRef.doc(widget.truckownerid).update({'amount': truckamt})
          : null;
      await bidRef.doc(widget.id).update({
        'bidresponse': "Bid Accepted",
        'bidtime': Jiffy(DateTime.now()).yMMMMEEEEdjm,
        'shipperpmt': postbidcount.length >= 5 ? amt.toString() : '',
        'transpmt': truckbidcount.length >= 5 ? truckamt.toString() : '',
      });
      await bidRef.doc(widget.id).collection('bidmessage').doc().set({
        'rate': "Bid Accepted",
        'bidtime': FieldValue.serverTimestamp(),
        'biduserid': UserService().currentUid(),
        'type': 'accept'
      });
      await postRef.doc(widget.posts.postid).update({
        'loadstatus': "InTransit",
        'loadorderstatus': "InTransit",
      });
    } catch (e) {
      print(e);
      setState(() {
        bidloading = false;
      });
    }
  }

  _onReBid() {
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
                  child: _buildReBidSheet(),
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

  _onRejectBid() async {
    try {
      await bidRef.doc(widget.id).update({
        'bidresponse': "Bid Rejected",
        'bidtime': Jiffy(DateTime.now()).yMMMMEEEEdjm,
      });
      await bidRef.doc(widget.id).collection('bidmessage').doc().set({
        'rate': "Bid Rejected",
        'bidtime': FieldValue.serverTimestamp(),
        'biduserid': UserService().currentUid(),
        'type': 'reject'
      });

      // await postRef.doc(widget.posts.postid).update({
      //   'loadstatus': "InTransit",
      //   'loadorderstatus': "InTransit",
      // });

    } catch (e) {
      print(e);
    }
  }

  Widget _buildReBidSheet() {
    return StatefulBuilder(builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Enter your new bid amount",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close))
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          TextFormField(
            controller: rate,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(hintText: "Price"),
          ),
          const SizedBox(
            height: 20,
          ),
          FlatButton(
              color: isLoading ? Constants.btninactive : Color(0XFF142438),
              textColor: Colors.white,
              onPressed: () async {
                if (rate.text.isEmpty) {
                  Fluttertoast.showToast(
                      gravity: ToastGravity.CENTER,
                      // textColor: Colors.orange,
                      fontSize: 15,
                      msg: "Please enter new bid price");
                } else {
                  try {
                    state(() {});
                    if (mounted) {
                      setState(() {
                        isLoading = true;
                      });
                    }

                    await bidRef.doc(widget.id).update({
                      'rate': rate.text,
                      'bidtime': Jiffy(DateTime.now()).yMMMMEEEEdjm,
                      'negotiateprice': widget.negotiateprice,
                      'bid': true,
                      'bidid': UserService().currentUid()
                    }).catchError((e) {
                      print(e);
                    });
                    await bidRef
                        .doc(widget.id)
                        .collection('bidmessage')
                        .doc()
                        .set({
                      'rate': rate.text,
                      'bidtime': FieldValue.serverTimestamp(),
                      'biduserid': UserService().currentUid(),
                      'bidresponse': '',
                      'negotiateprice': widget.negotiateprice,
                      'type': 'text'
                    });

                    Navigator.pop(context);
                    state(() {});
                    if (mounted) {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  } catch (e) {
                    state(() {});
                    if (mounted) {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                }
              },
              child: Container(
                width: double.infinity,
                height: 45,
                alignment: Alignment.center,
                child:
                    isLoading ? circularProgress(context) : Text("Negotiate"),
              ))
        ],
      );
    });
  }

  buildcompletedSheet() {
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
                  child: _buildCompletedSheet(),
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

  _buildCompletedSheet() {
    return StatefulBuilder(builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Submit your review",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.close),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: remakrsController,
            maxLines: 2,
            decoration: const InputDecoration(
                hintText: "Enter your remarks",
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder()),
          ),
          const SizedBox(
            height: 20,
          ),
          // RatingBar.builder(
          //     minRating: 1,
          //     maxRating: 5,
          //     itemBuilder: (context, _) {
          //       return const Icon(
          //         Icons.star,
          //         color: Colors.orange,
          //       );
          //     },
          //     onRatingUpdate: (rating) {
          //       state(() {});
          //       setState(() {
          //         this.rating = rating;
          //       });
          //     }),
          // const SizedBox(
          //   height: 20,
          // ),
          Container(
            width: MediaQuery.of(context).size.width,
            height: 45,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Color(0XFF142438)),
                onPressed: () async {
                  if (remakrsController.text.isEmpty) {
                    Fluttertoast.showToast(
                        msg: "Enter your remarks",
                        gravity: ToastGravity.CENTER);
                  } else {
                    try {
                      if (mounted) {
                        setState(() {
                          bidloading = true;
                        });
                      }
                      await bidRef.doc(widget.id).update({
                        'bidresponse': "Bid Completed",
                        'bidtime': Jiffy(DateTime.now()).yMMMMEEEEdjm,
                      });
                      await bidRef
                          .doc(widget.id)
                          .collection('bidmessage')
                          .doc()
                          .set({
                        'rate': "Bid Completed",
                        'completeremarks': remakrsController.text,
                        'bidtime': FieldValue.serverTimestamp(),
                        'biduserid': UserService().currentUid(),
                        'type': 'complete'
                      });
                      await postRef.doc(widget.posts.postid).update({
                        'loadstatus': "Completed",
                        'loadorderstatus': "Completed",
                      });
                    } catch (e) {
                      print(e);
                    }
                    Navigator.pop(context);
                    if (mounted) {
                      setState(() {
                        bidloading = false;
                      });
                    }
                  }
                },
                child: bidloading
                    ? circularProgress(context)
                    : const Text("SUBMIT")),
          )
        ],
      );
    });
  }

  completedFunction() async {
    if (remakrsController.text.isEmpty) {
      Fluttertoast.showToast(
          msg: "Enter your remarks", gravity: ToastGravity.CENTER);
    } else {
      try {
        if (mounted) {
          setState(() {
            bidloading = true;
          });
        }
        await bidRef.doc(widget.id).update({
          'bidresponse': "Bid Completed",
          'bidtime': Jiffy(DateTime.now()).yMMMMEEEEdjm,
        });
        await bidRef.doc(widget.id).collection('bidmessage').doc().set({
          'rate': "Bid Completed",
          'completeremarks': remakrsController.text,
          'bidtime': FieldValue.serverTimestamp(),
          'biduserid': UserService().currentUid(),
          'type': 'complete'
        });
        await postRef.doc(widget.posts.postid).update({
          'loadstatus': "Completed",
          'loadorderstatus': "Completed",
        });
      } catch (e) {
        print(e);
      }
      Navigator.pop(context);
      if (mounted) {
        setState(() {
          bidloading = false;
        });
      }
    }
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          value,
          style: TextStyle(
            fontSize: 16,
          ),
        )));
  }
}

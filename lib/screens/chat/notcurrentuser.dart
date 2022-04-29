import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jiffy/jiffy.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/bidmodal.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/widget/indicatiors.dart';
import 'package:uuid/uuid.dart';
import '../../utils/constants.dart';

class NotCurrentUser extends StatefulWidget {
  String negotiateprice;
  String rate;
  bool bid;
  String id;
  String bidresponse;
  PostModal posts;
  bool loaderimage;
  NotCurrentUser(this.negotiateprice, this.rate, this.bid, this.id,
      this.bidresponse, this.posts, this.loaderimage);

  @override
  State<NotCurrentUser> createState() => _NotCurrentUserState();
}

class _NotCurrentUserState extends State<NotCurrentUser> {
  TextEditingController rate = TextEditingController();
  bool isLoading = false;
  File? imageFile;
  bool bidloading = false;

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
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

      await bidRef.doc(widget.id).update({"loaderimage": true});
      await bidRef
          .doc(widget.id)
          .collection('bidmessage')
          .doc(fileName)
          .update({"rate": imageUrl});

      print(imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.bid == false ? "My New Price" : "My Old Price",
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 18),
            ),
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
                Text(
                  widget.negotiateprice,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  width: 2,
                ),
                Text(
                  widget.posts.priceunit == "tonne" ? "per" : "",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  width: 2,
                ),
                Text(
                  widget.posts.priceunit.toString(),
                  style: const TextStyle(fontSize: 18),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            widget.bidresponse == "Bid Accepted"
                ? Flexible(
                    child: InkWell(
                        onTap: () async {
                          widget.loaderimage == true ? null : getImage();
                        },
                        child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 45,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 2, color: Colors.green)),
                            alignment: Alignment.center,
                            child: Text(
                              widget.loaderimage == true
                                  ? "Thanks for sharing image"
                                  : "Upload Image (product iamge)",
                              style: TextStyle(fontSize: 16),
                            ))),
                  )
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
                        : widget.bid == false
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
                                            bidAccepted();
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
                                            _onReBid();
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
            widget.bidresponse == ""
                ? Flexible(
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
                : Container(),
          ],
        ),
      ),
    );
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

  bidAccepted() async {
    try {
      setState(() {
        bidloading = true;
      });
      await bidRef.doc(widget.id).update({
        'bidresponse': "Bid Accepted",
        'bidtime': Jiffy(DateTime.now()).yMMMMEEEEdjm,
      });
      await bidRef.doc(widget.id).collection('bidmessage').doc().set({
        'rate': "Bid Accepted",
        'bidtime': FieldValue.serverTimestamp(),
        'biduserid': UserService().currentUid(),
        'type': 'accept'
      });
      await postRef.doc(widget.posts.postid).update({
        'loadstatus': "Intransit",
        'loadorderstatus': "Intransit",
      });
      setState(() {
        bidloading = false;
      });
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
              color: isLoading ? Constants.btninactive : Constants.btnBG,
              textColor: Colors.white,
              onPressed: () async {
                if (rate.text.isEmpty) {
                  Fluttertoast.showToast(msg: "Please enter your price");
                } else {
                  // state(() {});
                  // setState(() {
                  //   isLoading = true;
                  // });
                  await bidRef.doc(widget.id).update({
                    'rate': widget.rate,
                    'bidtime': Jiffy(DateTime.now()).yMMMMEEEEdjm,
                    'negotiateprice': rate.text,
                    'bid': false
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
                    'type': 'text'
                  });

                  Navigator.pop(context);
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
}

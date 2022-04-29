import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:thaartransport/admin/fullimage.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/widget/flickerwidget.dart';

class documents extends StatefulWidget {
  String name;
  String ownerid;
  documents(this.name, this.ownerid);

  @override
  State<documents> createState() => _documentsState();
}

class _documentsState extends State<documents> {
  var controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        actions: [
          TextButton(
              onPressed: () async {
                await usersRef
                    .doc(widget.ownerid)
                    .update({'userkycstatus': "Verified"});
              },
              child: const Text("Verify")),
          TextButton(
              onPressed: () async {
                showSheet();
              },
              child: const Text("Non-ver"))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder(
            stream: usersRef.where('id', isEqualTo: widget.ownerid).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Scaffold(body: Text("Somthing went Wrong"));
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return FlickerWidget();
              } else if (snapshot.data!.docs.isEmpty) {
                return Container(
                    alignment: Alignment.center,
                    child: const Text(
                      "You have not active truck at the moment",
                    ));
              }
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    if (snapshot.hasError) {
                      return const Text("Somthing went Wrong");
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return FlickerWidget();
                    }
                    UserModel userModel = UserModel.fromJson(
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>);

                    return Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Aadhaar details",
                              style: TextStyle(fontSize: 15),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const Text("Aadhaar No:-"),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(userModel.AadhaarKyc!.aadhaarnumber
                                    .toString())
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                userModel.AadhaarKyc!.aadhaarfrontimg == ''
                                    ? const Icon(
                                        Icons.people,
                                        size: 50,
                                      )
                                    : Flexible(
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullImage(
                                                            userModel
                                                                .AadhaarKyc!
                                                                .aadhaarfrontimg
                                                                .toString(),
                                                          )));
                                            },
                                            child: Image.network(
                                              userModel
                                                  .AadhaarKyc!.aadhaarfrontimg
                                                  .toString(),
                                              height: 150,
                                              fit: BoxFit.cover,
                                            ))),
                                const SizedBox(
                                  width: 10,
                                ),
                                userModel.AadhaarKyc!.aadhaarbackimg == ''
                                    ? const Icon(
                                        Icons.people,
                                        size: 50,
                                      )
                                    : Flexible(
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullImage(userModel
                                                              .AadhaarKyc!
                                                              .aadhaarbackimg
                                                              .toString())));
                                            },
                                            child: Image.network(
                                              userModel
                                                  .AadhaarKyc!.aadhaarbackimg
                                                  .toString(),
                                              height: 150,
                                              fit: BoxFit.cover,
                                            ))),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text("PAN Details"),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const Text("PAN No:-"),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(userModel.PANKyc!.pannumber.toString())
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                userModel.PANKyc!.panfrontimg == ''
                                    ? const Icon(
                                        Icons.people,
                                        size: 50,
                                      )
                                    : Flexible(
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullImage(
                                                            userModel.PANKyc!
                                                                .panfrontimg
                                                                .toString(),
                                                          )));
                                            },
                                            child: Image.network(
                                              userModel.PANKyc!.panfrontimg
                                                  .toString(),
                                              height: 150,
                                              fit: BoxFit.cover,
                                            ))),
                                const SizedBox(
                                  width: 10,
                                ),
                                userModel.PANKyc!.panbackimg == ''
                                    ? const Icon(
                                        Icons.people,
                                        size: 50,
                                      )
                                    : Flexible(
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullImage(
                                                            userModel.PANKyc!
                                                                .panbackimg
                                                                .toString(),
                                                          )));
                                            },
                                            child: Image.network(
                                              userModel.PANKyc!.panbackimg
                                                  .toString(),
                                              height: 150,
                                              fit: BoxFit.cover,
                                            ))),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text("GST Details"),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                const Text("GST No:-"),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(userModel.GstKyc!.gstnumber.toString())
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                userModel.GstKyc!.gstimg1 == ''
                                    ? const Icon(
                                        Icons.people,
                                        size: 50,
                                      )
                                    : Flexible(
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullImage(
                                                            userModel
                                                                .GstKyc!.gstimg1
                                                                .toString(),
                                                          )));
                                            },
                                            child: Image.network(
                                              userModel.GstKyc!.gstimg1
                                                  .toString(),
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ))),
                                const SizedBox(
                                  width: 10,
                                ),
                                userModel.GstKyc!.gstimg2 == ''
                                    ? const Icon(
                                        Icons.people,
                                        size: 50,
                                      )
                                    : Flexible(
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullImage(
                                                            userModel
                                                                .GstKyc!.gstimg2
                                                                .toString(),
                                                          )));
                                            },
                                            child: Image.network(
                                              userModel.GstKyc!.gstimg2
                                                  .toString(),
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ))),
                                const SizedBox(
                                  width: 10,
                                ),
                                userModel.GstKyc!.gstimg3 == ''
                                    ? const Icon(
                                        Icons.people,
                                        size: 50,
                                      )
                                    : Flexible(
                                        child: InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          FullImage(
                                                            userModel
                                                                .GstKyc!.gstimg3
                                                                .toString(),
                                                          )));
                                            },
                                            child: Image.network(
                                              userModel.GstKyc!.gstimg3
                                                  .toString(),
                                              height: 100,
                                              fit: BoxFit.cover,
                                            ))),
                              ],
                            ),
                          ],
                        ));
                  });
            }),
      ),
    );
  }

  showSheet() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                color: const Color(0xFF737373),
                // height: 300,
                child: Container(
                  padding: EdgeInsets.all(15),
                  child: _buildSheet(),
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

  _buildSheet() {
    return StatefulBuilder(builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Enter Non-Verified comment",
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
          Card(
            child: Container(
              padding: const EdgeInsets.only(left: 15),
              decoration: const BoxDecoration(color: Colors.black12),
              child: TextFormField(
                controller: controller,
                maxLines: 2,
                decoration: const InputDecoration(
                    hintText: "Enter Somthing..", border: InputBorder.none),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          FlatButton(
              color: Color(0XFF142438),
              textColor: Colors.white,
              onPressed: () async {
                await usersRef
                    .doc(widget.ownerid)
                    .update({'kycerror': controller.text});
              },
              child: Container(
                width: double.infinity,
                height: 45,
                alignment: Alignment.center,
                child: Text("update"),
              ))
        ],
      );
    });
  }
}

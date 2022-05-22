import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';

class AddMoney extends StatefulWidget {
  const AddMoney({Key? key}) : super(key: key);

  @override
  _AddMoneyState createState() => _AddMoneyState();
}

class _AddMoneyState extends State<AddMoney> {
  static const platform = const MethodChannel("razorpay_flutter");

  late Razorpay razorpay;
  TextEditingController textEditingController = new TextEditingController();

  TextEditingController controller = TextEditingController();
  String username = '';
  String userNumber = '';
  String useremail = '';
  int remainingAmount = 0;
  List paymentHistory = [];
  String paymentid = '';
  String addmoney = '';
  Timestamp? timestamp;

  currentuser() async {
    await usersRef.doc(UserService().currentUid()).get().then((value) {
      if (mounted) {
        setState(() {
          username = value.get('username');
          userNumber = value.get('usernumber');
          useremail = value.get('useremail');
          remainingAmount = value.get('amount');
          print(remainingAmount);
        });
      }
    });
  }

  userpaymentHistory() async {
    await usersRef
        .doc(UserService().currentUid())
        .collection('payment')
        .doc()
        .get()
        .then((value) {
      // print(value);
      paymentHistory.add(value);
      print(paymentHistory);
      paymentHistory.forEach((element) {
        setState(() {
          // paymentid = element['paymentid'];
          // addmoney = element['amount'];
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    currentuser();
    userpaymentHistory();
    razorpay = new Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    razorpay.clear();
  }

  void openCheckout() {
    var options = {
      "key": "rzp_test_FOtHSOhU8OwQ1j",
      "amount": num.parse(controller.text) * 100,
      "name": "Thaar Transport",
      "description": "Payment for the some random product",
      "prefill": {"contact": userNumber, "email": useremail},
      "external": {
        "wallets": ["paytm"]
      }
    };

    try {
      razorpay.open(options);
    } catch (e) {
      print(e.toString());
    }
  }

  void handlerPaymentSuccess(
    PaymentSuccessResponse response,
  ) async {
    print("Pament success${response.orderId}");
    await usersRef
        .doc(UserService().currentUid())
        .update({'amount': remainingAmount + num.parse(controller.text)});

    var doc =
        usersRef.doc(UserService().currentUid()).collection('payment').doc();
    await usersRef
        .doc(UserService().currentUid())
        .collection('payment')
        .doc(doc.id)
        .set({
      'paymentid': response.paymentId,
      'sigunator': response.signature,
      'id': doc.id,
      "status": "Success",
      'amount': num.parse(controller.text),
      'time': FieldValue.serverTimestamp()
    });
    currentuser();
    Fluttertoast.showToast(msg: "Pament success");
  }

  void handlerErrorFailure(PaymentFailureResponse response) async {
    print("Pament error");
    var doc =
        usersRef.doc(UserService().currentUid()).collection('payment').doc();
    await usersRef
        .doc(UserService().currentUid())
        .collection('payment')
        .doc(doc.id)
        .set({
      'failurepaymentmsg': response.message,
      'paymentstatus': "Failure",
      'sigunator': response.code,
      "status": "Failed",
      'id': doc.id,
      'amount': controller.text,
      'time': FieldValue.serverTimestamp()
    });
    currentuser();
    Fluttertoast.showToast(msg: "Pament error");
  }

  void handlerExternalWallet() {
    print("External Wallet");
    Fluttertoast.showToast(msg: "External Wallet");
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: InkWell(
          onTap: () {
            _buildmoney();
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Constants.thaartheme,
                borderRadius: BorderRadius.circular(20)),
            width: 150,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Add Money",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  width: 5,
                ),
                Icon(
                  Icons.add,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 30, left: 20, right: 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        "My Wallet",
                        style: GoogleFonts.ibmPlexSerif(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text(
                    "Balance",
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.currency_rupee,
                        size: 40,
                      ),
                      Text(
                        remainingAmount.toString(),
                        style: const TextStyle(
                            fontSize: 35, fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Container(
              padding: EdgeInsets.only(right: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      _buildfilersheet();
                    },
                    child: Image.asset(
                      'assets/images/fittler.png',
                      height: 30,
                      width: 30,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Expanded(
                child: Container(
                    padding: EdgeInsets.only(left: 10, right: 10),
                    child: value == "successfully"
                        ? successadd()
                        : value == "failed"
                            ? failedadd()
                            : alladd()))
          ],
        ));
  }

  Widget alladd() {
    return StreamBuilder(
        stream: usersRef
            .doc(UserService().currentUid())
            .collection('payment')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center();
          } else if (snapshot.hasError) {
            return Center();
          }
          return ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DateTime date = snapshot.data!.docs[index]['time'].toDate();

                String formattedDate = DateFormat.yMMMEd().format(date);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 8, bottom: 10, left: 5, right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.orange,
                                child: Icon(
                                  Icons.currency_rupee,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data!.docs[index]['status'] ==
                                            "Success"
                                        ? "Successfully Added"
                                        : "Failed Added",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: snapshot.data!.docs[index]
                                                    ['status'] ==
                                                "Success"
                                            ? Colors.green.shade500
                                            : Constants.alert),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(formattedDate.toString()),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.currency_rupee),
                            Text(
                              snapshot.data!.docs[index]['amount'].toString(),
                              style: TextStyle(
                                  color: snapshot.data!.docs[index]['status'] ==
                                          "Success"
                                      ? Colors.green.shade500
                                      : Constants.alert,
                                  fontSize: 22),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              });
        });
  }

  Widget successadd() {
    return StreamBuilder(
        stream: usersRef
            .doc(UserService().currentUid())
            .collection('payment')
            .where('status', isEqualTo: 'Success')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center();
          } else if (snapshot.hasError) {
            return Center();
          }
          return ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DateTime date = snapshot.data!.docs[index]['time'].toDate();

                String formattedDate = DateFormat.yMMMEd().format(date);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 8, bottom: 10, left: 5, right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.orange,
                                child: Icon(
                                  Icons.currency_rupee,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data!.docs[index]['status'] ==
                                            "Success"
                                        ? "Successfully Added"
                                        : "Failed Added",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: snapshot.data!.docs[index]
                                                    ['status'] ==
                                                "Success"
                                            ? Colors.green.shade500
                                            : Constants.alert),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(formattedDate.toString()),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.currency_rupee),
                            Text(
                              snapshot.data!.docs[index]['amount'].toString(),
                              style: TextStyle(
                                  color: snapshot.data!.docs[index]['status'] ==
                                          "Success"
                                      ? Colors.green.shade500
                                      : Constants.alert,
                                  fontSize: 22),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              });
        });
  }

  Widget failedadd() {
    return StreamBuilder(
        stream: usersRef
            .doc(UserService().currentUid())
            .collection('payment')
            .where('status', isNotEqualTo: 'Success')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center();
          } else if (snapshot.data!.docs.isEmpty) {
            return Center();
          }
          return ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DateTime date = snapshot.data!.docs[index]['time'].toDate();

                String formattedDate = DateFormat.yMMMEd().format(date);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 8, bottom: 10, left: 5, right: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.orange,
                                child: Icon(
                                  Icons.currency_rupee,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    snapshot.data!.docs[index]['status'] ==
                                            "Success"
                                        ? "Successfully Added"
                                        : "Failed Added",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: snapshot.data!.docs[index]
                                                    ['status'] ==
                                                "Success"
                                            ? Colors.green.shade500
                                            : Constants.alert),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(formattedDate.toString()),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(Icons.currency_rupee),
                            Text(
                              snapshot.data!.docs[index]['amount'].toString(),
                              style: TextStyle(
                                  color: snapshot.data!.docs[index]['status'] ==
                                          "Success"
                                      ? Colors.green.shade500
                                      : Constants.alert,
                                  fontSize: 22),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              });
        });
  }

  _buildmoney() {
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
                  child: addmoneySheet(),
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

  _buildfilersheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setstate) {
            return Container(
              child: Container(
                decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(30))),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 15, left: 10, right: 10, bottom: 60),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Filter Payment",
                              style: GoogleFonts.ibmPlexSerif(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
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
                        height: 40,
                      ),
                      RadioListTile(
                          title: const Text(
                            "Successfully Added",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18),
                          ),
                          value: 'successfully',
                          groupValue: value,
                          onChanged: (val) {
                            setstate(() {});
                            setState(() {
                              value = val as String;
                              Navigator.pop(context);
                            });
                          }),
                      RadioListTile(
                          title: const Text(
                            "Failed Added",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18),
                          ),
                          value: 'failed',
                          groupValue: value,
                          onChanged: (val) {
                            setstate(() {});
                            setState(() {
                              value = val as String;
                              Navigator.pop(context);
                            });
                          })
                    ],
                  ),
                ),
              ),
            );
          });
        });
  }

  String value = '';
  Widget addmoneySheet() {
    return StatefulBuilder(builder: (context, state) {
      return SingleChildScrollView(
        child: Wrap(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    // margin: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Add Money",
                          style: GoogleFonts.ibmPlexSerif(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.close_outlined),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 10),
                    decoration: BoxDecoration(
                        color: Colors.black12,
                        border: Border.all(color: Colors.black12)),
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                          hintText: "rs 8000", border: InputBorder.none),
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  RaisedButton(
                    color: Color(0XFF142438),
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    onPressed: () {
                      if (controller.text.isEmpty) {
                        Fluttertoast.showToast(msg: "Please enter your amount");
                      } else if (int.parse(controller.text) < 500) {
                        Fluttertoast.showToast(msg: "Please enter 500 above");
                      } else {
                        openCheckout();
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      height: 45,
                      child: const Text(
                        "ADD MONEY",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

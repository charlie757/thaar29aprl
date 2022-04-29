import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:thaartransport/services/userservice.dart';
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
      print(value);
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
    await usersRef.doc(UserService().currentUid()).collection('payment').add({
      'paymentid': response.paymentId,
      'sigunator': response.signature,
      'amount': num.parse(controller.text),
      'time': FieldValue.serverTimestamp()
    });
    currentuser();
    Fluttertoast.showToast(msg: "Pament success");
  }

  void handlerErrorFailure(PaymentFailureResponse response) async {
    print("Pament error");
    await usersRef.doc(UserService().currentUid()).collection('payment').add({
      'failurepaymentmsg': response.message,
      'paymentstatus': "Failure",
      'sigunator': response.code,
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
        body: Container(
      height: height,
      width: width,
      child: Column(
        children: [
          Container(
            height: 250,
            width: width,
            color: const Color(0XFF142438),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Current Balance",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.currency_rupee,
                      color: Colors.white,
                    ),
                    Text(
                      remainingAmount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 22),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    _onReBid();
                  },
                  child: Card(
                    color: Colors.black12,
                    child: Container(
                      width: 150,
                      height: 40,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Add Money",
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(
                            Icons.add,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: Container(
                  // color: Colors.red,
                  child: ListView.builder(
                      itemCount: paymentHistory.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text(addmoney),
                          ),
                        );
                      })))
        ],
      ),
    ));
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

  Widget addmoneySheet() {
    return StatefulBuilder(builder: (context, state) {
      return SingleChildScrollView(
        child: Wrap(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  // margin: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Add Money",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18),
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
                  height: 20,
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
                  height: 10,
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
          ],
        ),
      );
    });
  }
}

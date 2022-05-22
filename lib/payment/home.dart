import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay razorpay;
  TextEditingController textEditingController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    razorpay = new Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlerPaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlerErrorFailure);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handlerExternalWallet);
  }

// I/flutter ( 7533): Tuesday, April 26, 2022 3:30 PM
// I/flutter ( 7533): 0uh3Gl3oPcEsDXYbYZPd
// I/flutter ( 7533): Tuesday, April 26, 2022 3:17 PM
// I/flutter ( 7533): 1gWev5LDDPXh3cmiAklx
// I/flutter ( 7533): Tuesday, April 26, 2022 3:35 PM
// I/flutter ( 7533): 6uswUujfD30dT1DCq7NP
// I/flutter ( 7533): Sunday, May 8, 2022 9:08 AM
// I/flutter ( 7533): 9ugjk7Gb8q1izrcr5HSA
// I/flutter ( 7533): Sunday, May 1, 2022 10:54 AM
// I/flutter ( 7533): KLISIiS8zYuMA93UiFGZ
// I/flutter ( 7533): Saturday, May 7, 2022 2:32 PM
// I/flutter ( 7533): LQmNEhUUzWhR1ZX4A678
// I/flutter ( 7533): Saturday, April 23, 2022 12:06 PM
// I/flutter ( 7533): M9Oyy2yvRP24O2eJSZkb
// I/flutter ( 7533): Monday, May 2, 2022 6:24 PM
// I/flutter ( 7533): PxOYO2eURg1284fJhaGm
// I/flutter ( 7533): Saturday, May 7, 2022 2:30 PM
// I/flutter ( 7533): R7kjvHSEdCFa8RgLZqkl
// I/flutter ( 7533): Wednesday, April 27, 2022 10:41 AM
// I/flutter ( 7533): Vo1pBzVuLwNR9S3xvZLl
// I/flutter ( 7533): Sunday, May 1, 2022 8:58 PM
// I/flutter ( 7533): Yuh6jihJhXCK1jYWDee1
// I/flutter ( 7533): Sunday, May 8, 2022 8:43 AM
// I/flutter ( 7533): YzqdhIo1PUfrYSgKhtnp
// I/flutter ( 7533): Friday, April 15, 2022 10:49 AM
// I/flutter ( 7533): ahyRkAHHyyO0OQ8aBAvQ
// I/flutter ( 7533): Tuesday, April 26, 2022 3:16 PM
// I/flutter ( 7533): d2qB4jI95sQjFGNXqgLy
// I/flutter ( 7533): Tuesday, April 26, 2022 3:32 PM
// I/flutter ( 7533): e0BeYnMcF97eqcCvNClH
// I/flutter ( 7533): Saturday, April 23, 2022 12:03 PM
// I/flutter ( 7533): hMQ7asZgHfFiB3fEpvGC
// I/flutter ( 7533): Saturday, April 16, 2022 3:29 PM
// I/flutter ( 7533): i3S1YyzkAlrYIul7rnMK
// I/flutter ( 7533): Tuesday, April 26, 2022 3:32 PM
// I/flutter ( 7533): jDmhwgKU9NYfPtlDilPS
// I/flutter ( 7533): Wednesday, April 27, 2022 10:42 AM
// I/flutter ( 7533): oxZKG9PY4ZzCp5Tx8Gqp
// I/flutter ( 7533): Saturday, May 7, 2022 7:03 PM
// I/flutter ( 7533): xOpd2cO9AA1L6LuVMbMo
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    razorpay.clear();
  }

  void openCheckout() {
    var options = {
      "key": "rzp_test_So9TL4998XggEq",
      "amount": num.parse(textEditingController.text) * 100,
      "name": "Sample App",
      "description": "Payment for the some random product",
      "prefill": {"contact": "9782485409", "email": "rraviggupta15@gmail.com"},
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

  void handlerPaymentSuccess() {
    print("Pament success");
    Fluttertoast.showToast(msg: "Pament success");
  }

  void handlerErrorFailure() {
    print("Pament error");
    Fluttertoast.showToast(msg: "Pament error");
  }

  void handlerExternalWallet() {
    print("External Wallet");
    Fluttertoast.showToast(msg: "External Wallet");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thaar payment portal"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            TextField(
              controller: textEditingController,
              decoration: InputDecoration(hintText: "amount to pay"),
            ),
            const SizedBox(
              height: 12,
            ),
            RaisedButton(
              color: Colors.blue,
              child: const Text(
                "Donate Now",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                openCheckout();
              },
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:thaartransport/screens/kyc/aadhaar/aadhaarkyc.dart';
import 'package:thaartransport/screens/kyc/registerkyc.dart';

class KycVerified extends StatefulWidget {
  const KycVerified({Key? key}) : super(key: key);

  @override
  _KycVerifiedState createState() => _KycVerifiedState();
}

class _KycVerifiedState extends State<KycVerified> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: () async {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const RegisterKYC()));
          return true;
        },
        child: Scaffold(
            body: SingleChildScrollView(
                child: Container(
          height: height,
          child: Column(
            children: [
              Container(
                height: 300,
                width: width,
                child: Stack(
                  children: [
                    Container(
                      child: Container(
                          alignment: Alignment.topLeft,
                          height: 250,
                          color: Color(0XFF142438),
                          padding: const EdgeInsets.only(top: 50, left: 10),
                          child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => RegisterKYC()));
                              },
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ))),
                    ),
                    Container(
                      margin: const EdgeInsets.only(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Become a Verified Business",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.verified_rounded,
                                color: Colors.green,
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Don't worry! Verfying is Quick & Paperless.",
                            style: TextStyle(color: Colors.white60),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                        top: 200,
                        child: Container(
                            width: width,
                            alignment: Alignment.center,
                            child: const CircleAvatar(
                              radius: 40,
                              child: Icon(
                                Icons.security,
                                size: 50,
                              ),
                            )))
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        color: Colors.orange,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.circle,
                              color: Color(0XFF142438),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                                "ID details are needed for one-time verification.")
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      const Text("KYC Benefits"),
                      const ListTile(
                        leading: Icon(Icons.verified),
                        title: Text("Get verified Business Tags"),
                      ),
                      const ListTile(
                        leading: Icon(Icons.verified),
                        title: Text("Get move Business Leads"),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: RichText(
                          text: const TextSpan(
                              text: "By Proceding you agree",
                              style: TextStyle(color: Colors.black),
                              children: [
                                TextSpan(
                                    text: "Terms & Conditions",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.black,
                                        fontSize: 15))
                              ]),
                        ),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Color(0XFF142438)),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AadhaarKyc()));
                          },
                          child: Container(
                            height: 50,
                            alignment: Alignment.center,
                            child: const Text("START KYC VERIFICATION"),
                          ))
                    ],
                  ))
            ],
          ),
        ))));
  }
}

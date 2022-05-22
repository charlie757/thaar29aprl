import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/currentuserprovider.dart';
import 'package:thaartransport/NEW/homepage.dart';
import 'package:thaartransport/NEW/postloaduser/shipperhomepage.dart';
import 'package:thaartransport/NEW/truckpostuser/truckhomepage.dart';
import 'package:thaartransport/screens/kyc/aadhaar/aadhaarkyc.dart';
import 'package:thaartransport/utils/constants.dart';

class RegisterKYC extends StatefulWidget {
  const RegisterKYC({Key? key}) : super(key: key);

  @override
  _RegisterKYCState createState() => _RegisterKYCState();
}

class _RegisterKYCState extends State<RegisterKYC> {
  // String userType = '';

  // currentUser() async {
  //   await usersRef.doc(UserService().currentUid()).get().then((value) {
  //     setState(() {
  //       userType = value.get('usertype');
  //     });
  //     print("main$userType");
  //   });
  // }

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    CurrentUserProvider currentUserProvider =
        Provider.of<CurrentUserProvider>(context);
    currentUserProvider.currentuser();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Constants.thaartheme,
        centerTitle: true,
        title: Text(
          "Thaar Transport",
          style: GoogleFonts.charm(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellow, width: 2),
                        borderRadius: BorderRadius.circular(30)),
                    child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          'assets/images/kyc.png',
                          height: 25,
                          width: 25,
                          color: Colors.black,
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Want to restart KYC?",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    "Just a few more steps to get verfiied by Thaar",
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: FlatButton(
                  color: Constants.alert,
                  height: 40,
                  textColor: Colors.white,
                  onPressed: () async {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => AadhaarKyc()));
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: Text("RESTART KYC"),
                  )),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: FlatButton(
                  color: const Color(0XFF142438),
                  textColor: Colors.white,
                  height: 40,
                  onPressed: () async {
                    // currentUserProvider.usertype == "Transporator"
                    //     ? Navigator.pushReplacement(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => const TruckHomePage()))
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePage()));
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: const Text("CONTINUE LATER"),
                  )),
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:share_plus/share_plus.dart';
import 'package:thaartransport/screens/kyc/kycverfied.dart';
import 'package:thaartransport/services/auth_service.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/widget/indicatiors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

class SideBar extends StatefulWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  String? userkycstatus;
  String? usertype;
  double rating = 3.0;
  bool loading = false;
  bool checkbox1 = false;
  bool checkbox2 = false;
  bool checkbox3 = false;
  bool checkbox4 = false;
  bool checkbox5 = false;
  TextEditingController contactuscontroller = TextEditingController();
  TextEditingController feedbackcontroller = TextEditingController();
  TextEditingController paymentissuecontroller = TextEditingController();
  String url =
      'https://thaarprivacypolicy.blogspot.com/2022/04/thaar-transport-privacy-policy_11.html';
  retriveCurrentUser() {
    usersRef.doc(UserService().currentUid()).get().then((value) {
      setState(() {
        userkycstatus = value.get('userkycstatus');
        usertype = value.get('usertype');
      });
    });
  }

  @override
  void initState() {
    super.initState();
    retriveCurrentUser();
  }

  void getData() async {
    List<QuerySnapshot> futures = [];

    var firstquery = FirebaseFirestore.instance.collection("listofprods").where(
        'usernumber',
        isEqualTo: FirebaseAuth.instance.currentUser!.phoneNumber);

    await firstquery.get().then<dynamic>((QuerySnapshot snapshot) async {
      setState(() {
        futures.add(snapshot);
      });
    });
  }

  final RateMyApp rateMyApp = RateMyApp(
      // minDays: 0,
      // minLaunches: 0,
      // remindDays: ,
      googlePlayIdentifier: 'thaar.app.thaartransport');

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0XFF142438),
          title: const Text("Menu"),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return buildSheet();
                      });
                },
                child: const Icon(
                  Icons.logout_outlined,
                  color: Colors.red,
                  size: 25,
                ),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const ListTile(
                  leading: Icon(Icons.contact_support),
                  title: Text("Help Guide"),
                  subtitle:
                      Text("A help guide for your to get loads & lorries"),
                ),
                // const ListTile(
                //   leading: Icon(Icons.settings),
                //   title: Text("Settings"),
                //   subtitle: Text("Fine tune your Vahak experience"),
                // ),
                ListTile(
                  onTap: () {
                    buildrateSheet();
                  },
                  leading: const Icon(Icons.star),
                  title: const Text("Rate us on Playstore"),
                  subtitle: const Text("We would love to hear from you"),
                ),
                ListTile(
                  onTap: () async {
                    final bytes =
                        await rootBundle.load('assets/images/thaar.png');
                    final list = bytes.buffer.asUint8List();

                    final tempDir = await getTemporaryDirectory();
                    final file =
                        await File('${tempDir.path}/thaar.png').create();
                    file.writeAsBytesSync(list);

                    await Share.shareFiles([file.path],
                        text:
                            'Download this app to book load and truck \nhttps://play.google.com/store/apps/details?id=thaar.app.thaartransport');
                  },
                  leading: const Icon(Icons.speaker),
                  title: const Text("Refer a Friend"),
                  subtitle: const Text("Invite your friennd"),
                ),
                // ignore: prefer_const_constructors

                const ListTile(
                  leading: Icon(Icons.folder),
                  title: Text("Terms & Conditions"),
                  subtitle: Text("Read what you've signed"),
                ),
                ListTile(
                  onTap: () {
                    _launchURL();
                  },
                  leading: const Icon(Icons.privacy_tip),
                  title: const Text("Privacy Policy"),
                  subtitle: const Text("Compliance and regulations"),
                ),
                ListTile(
                  onTap: () {
                    feedbackSheet();
                  },
                  leading: const Icon(Icons.feedback),
                  title: const Text("Share Feedback"),
                  subtitle: const Text(
                      "Any trouble with our services? share you feedback"),
                ),
                ListTile(
                  onTap: () {
                    contactUs();
                  },
                  leading: const Icon(Icons.contact_support_sharp),
                  title: const Text("Contact us"),
                  subtitle:
                      const Text("Facing an issue? We're there to help you"),
                ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          ),
        ));
  }

  buildrateSheet() async {
    rateMyApp.init().then((value) {
      rateMyApp.conditions.forEach((condition) {
        if (condition is DebuggableCondition) {
          print(condition.valuesAsString);
        }
      });
      if (rateMyApp.shouldOpenDialog) {
        rateMyApp.showStarRateDialog(context,
            title: 'Rate this app',
            message:
                'You like this app ? Then take a little bit of you t ime to leave a rating :',
            ignoreNativeDialog: true,
            dialogStyle: const DialogStyle(
                titleAlign: TextAlign.center,
                messageAlign: TextAlign.center,
                messagePadding: EdgeInsets.only(bottom: 20)),
            actionsBuilder: (context, stars) {
              return [
                TextButton(
                    onPressed: () async {
                      stars = stars ?? 0;
                      print(
                          'Thank you for the : ${stars.toString()} stars rating');
                      if (stars! < 4) {
                        print('Would you like to leave a feedback');
                      } else {
                        Navigator.pop<RateMyAppDialogButton>(
                            context, RateMyAppDialogButton.rate);
                        await rateMyApp
                            .callEvent(RateMyAppEventType.rateButtonPressed);
                        if ((await rateMyApp.isNativeReviewDialogSupported) ??
                            false) {
                          await rateMyApp.launchNativeReviewDialog();
                        }
                        rateMyApp.launchStore();
                      }
                    },
                    child: const Text('Ok'))
              ];
            },
            starRatingOptions: StarRatingOptions(),
            onDismissed: () =>
                rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed));
      }
    });
  }

  void _launchURL() async {
    if (!await launch(url)) throw 'Could not launch $url';
  }

  feedbackSheet() {
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
                  child: feedbackWidget(),
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

  Widget feedbackWidget() {
    return StatefulBuilder(builder: (context, state) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Share Feedback",
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
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Card(
              child: Container(
                padding: const EdgeInsets.only(left: 15),
                decoration: const BoxDecoration(color: Colors.black12),
                child: TextFormField(
                  controller: feedbackcontroller,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      hintText: "Enter Somthing..", border: InputBorder.none),
                ),
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              direction: Axis.horizontal,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  this.rating = rating;
                });
                print(rating);
              },
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              children: [
                Expanded(
                    child: Container(
                  height: 45,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Constants.kYellowColor),
                      onPressed: () {
                        clearController();
                        loading == true ? null : Navigator.pop(context);
                      },
                      child: const Text("Back")),
                )),
                const SizedBox(
                  width: 15,
                ),
                Expanded(
                    child: Container(
                  height: 45,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: const Color(0XFF142438)),
                      onPressed: () {
                        if (feedbackcontroller.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: "Please share your feedback");
                        } else {
                          state(() {});
                          setState(() {
                            loading = true;
                          });
                          feedbackRef.add({
                            'userid': UserService().currentUid(),
                            'posttime': FieldValue.serverTimestamp(),
                            'feedback': feedbackcontroller.text,
                            'rating': rating
                          }).then((value) {
                            state(() {});
                            setState(() {
                              loading = false;
                              EasyLoading.showToast(
                                  'Thanks for sharing feedback');
                            });
                            Navigator.pop(context);
                            clearController();
                            print("feedbackRef $value");
                          });
                        }
                      },
                      child:
                          loading ? circularProgress(context) : Text("Submit")),
                ))
              ],
            )
          ],
        ),
      );
    });
  }

  contactUs() {
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
                  decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: StatefulBuilder(builder: (context, state) {
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Contact Us",
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
                            height: 20,
                          ),
                          CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text("Unable to use thaar transport app?"),
                              value: checkbox1,
                              onChanged: (val) {
                                setState(() {
                                  state(() {});
                                  checkbox1 = val!;
                                  checkbox2 = false;
                                  checkbox3 = false;
                                  checkbox4 = false;
                                  checkbox5 = false;
                                });
                              }),
                          CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text("Unable to attach lorry in market?"),
                              value: checkbox2,
                              onChanged: (val) {
                                setState(() {
                                  state(() {});
                                  checkbox2 = val!;
                                  checkbox1 = false;
                                  checkbox3 = false;
                                  checkbox4 = false;
                                  checkbox5 = false;
                                });
                              }),
                          CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text("Unable to post load in market?"),
                              value: checkbox3,
                              onChanged: (val) {
                                setState(() {
                                  state(() {});
                                  checkbox3 = val!;
                                  checkbox2 = false;
                                  checkbox1 = false;
                                  checkbox4 = false;
                                  checkbox5 = false;
                                });
                              }),
                          CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text("Any payment issue?"),
                              value: checkbox4,
                              onChanged: (val) {
                                state(() {});
                                setState(() {
                                  checkbox4 = val!;
                                  checkbox2 = false;
                                  checkbox3 = false;
                                  checkbox1 = false;
                                  checkbox5 = false;
                                });
                              }),
                          checkbox4 == true
                              ? Card(
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 15),
                                    decoration: const BoxDecoration(
                                        color: Colors.black12),
                                    child: TextFormField(
                                      controller: paymentissuecontroller,
                                      maxLines: 2,
                                      decoration: const InputDecoration(
                                          hintText: "describle payment issue..",
                                          border: InputBorder.none),
                                    ),
                                  ),
                                )
                              : Container(),
                          CheckboxListTile(
                              controlAffinity: ListTileControlAffinity.leading,
                              title: Text("Other"),
                              value: checkbox5,
                              onChanged: (val) {
                                state(() {});
                                setState(() {
                                  checkbox5 = val!;
                                  checkbox2 = false;
                                  checkbox3 = false;
                                  checkbox4 = false;
                                  checkbox1 = false;
                                });
                              }),
                          checkbox5 == true
                              ? Card(
                                  child: Container(
                                    padding: const EdgeInsets.only(left: 15),
                                    decoration: const BoxDecoration(
                                        color: Colors.black12),
                                    child: TextFormField(
                                      controller: contactuscontroller,
                                      maxLines: 2,
                                      decoration: const InputDecoration(
                                          hintText: "Enter Somthing..",
                                          border: InputBorder.none),
                                    ),
                                  ),
                                )
                              : Container(),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: Container(
                                height: 45,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Constants.kYellowColor),
                                    onPressed: () {
                                      clearController();
                                      loading == true
                                          ? null
                                          : Navigator.pop(context);
                                    },
                                    child: const Text("Back")),
                              )),
                              const SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                  child: Container(
                                height: 45,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: const Color(0XFF142438)),
                                    onPressed: () {
                                      if (checkbox1 == false &&
                                          checkbox2 == false &&
                                          checkbox3 == false &&
                                          checkbox4 == false &&
                                          checkbox5 == false) {
                                        EasyLoading.showToast(
                                            'Please select any one');
                                      } else if (checkbox5 == true &&
                                          contactuscontroller.text.isEmpty) {
                                        EasyLoading.showToast(
                                            'Please write somthing');
                                      } else if (checkbox4 == true &&
                                          paymentissuecontroller.text.isEmpty) {
                                        EasyLoading.showToast(
                                            'Please describle payment issue.');
                                      } else {
                                        state(() {});
                                        setState(() {
                                          loading = true;
                                        });
                                        contactRef.add({
                                          'userid': UserService().currentUid(),
                                          'posttime':
                                              FieldValue.serverTimestamp(),
                                          'reason': checkbox1 == true
                                              ? 'Unable to use thaar transport app?'
                                              : checkbox2 == true
                                                  ? 'Unable to attach lorry in market?'
                                                  : checkbox3 == true
                                                      ? 'Unable to post load in market?'
                                                      : checkbox4 == true
                                                          ? 'Any Payment issue?'
                                                          : 'other',
                                          'paymentissue': paymentissuecontroller
                                                  .text.isEmpty
                                              ? ''
                                              : paymentissuecontroller.text,
                                          'other':
                                              contactuscontroller.text.isEmpty
                                                  ? ''
                                                  : contactuscontroller.text
                                        }).then((value) {
                                          state(() {});
                                          setState(() {
                                            loading = false;
                                          });
                                          EasyLoading.showToast(
                                              'Thanks for sharing your concern');

                                          Navigator.pop(context);
                                          clearController();
                                        });
                                      }
                                    },
                                    child: loading
                                        ? circularProgress(context)
                                        : Text("Submit")),
                              ))
                            ],
                          )
                        ],
                      ),
                    );
                  }),
                ),
              ));
        });
  }

  clearController() {
    paymentissuecontroller.clear();
    contactuscontroller.clear();
    feedbackcontroller.clear();
  }

  Widget buildSheet() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
              alignment: Alignment.center,
              child: Container(
                height: 8,
                width: 50,
                decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(30)),
              )),
          const SizedBox(
            height: 20,
          ),
          Text(
            "Are you sure",
            style: GoogleFonts.ibmPlexSerif(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          const Text(
            'Do you want to logout?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: RaisedButton(
                      color: Constants.white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: height * 0.06,
                        decoration: BoxDecoration(),
                        alignment: Alignment.center,
                        child: const Text(
                          'GO BACK',
                          style: TextStyle(color: Colors.black),
                        ),
                      ))),
              SizedBox(
                width: width * 0.03,
              ),
              Expanded(
                  child: RaisedButton(
                      color: Color(0XFF142438),
                      onPressed: () async {
                        AuthService().logOut(context);
                      },
                      child: Container(
                        height: height * 0.06,
                        alignment: Alignment.center,
                        child: Text(
                          "YES LOGOUT",
                          style: TextStyle(
                            color: Constants.white,
                          ),
                        ),
                      )))
            ],
          )
        ],
      ),
    );
  }

  Widget verifyKYC() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return GestureDetector(
        onTap: () {
          // Navigator.pushNamed(context, PageRoutes.kycverified);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => KycVerified()));
        },
        child: Container(
          color: Colors.blueGrey,
          // padding: EdgeInsets.all(5),
          width: width,
          height: height * 0.2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  width: width * 0.7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                          text: const TextSpan(
                              text: "Complete your KYC and become a",
                              style: TextStyle(color: Colors.black),
                              children: [
                            TextSpan(
                                text: "VERIFIED BUSINESS",
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.black,
                                    fontSize: 20))
                          ])),
                      Container(
                        width: 200,
                        color: Colors.purple,
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Processed KYC",
                              style: TextStyle(color: Colors.white),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right_sharp,
                              color: Colors.white,
                            )
                          ],
                        ),
                      )
                    ],
                  )),
              Image.asset(
                'assets/images/phone.jpg',
                height: 80,
                width: 80,
              )
            ],
          ),
        ));
  }

  Widget completedKYC() {
    return Container(
      height: 120,
      color: Colors.blue[100],
      padding: EdgeInsets.only(left: 10, right: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Flexible(
                  child: Text(
                "You have successfully completed your KYC.",
                style: GoogleFonts.robotoSlab(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )),
              Container(
                width: 70,
                height: 70,
                child: Image.asset("assets/images/verified.jpeg"),
              )
            ],
          )
        ],
      ),
    );
  }
}

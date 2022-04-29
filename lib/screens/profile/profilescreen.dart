// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/screens/kyc/kycverfied.dart';
import 'package:thaartransport/screens/profile/yeardata.dart';
import 'package:thaartransport/screens/profile/editprofile.dart';
import 'package:thaartransport/screens/profile/yearsnotifiers.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:thaartransport/widget/indicatiors.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Stream<DocumentSnapshot> stream;

  void initState() {
    stream = usersRef.doc(UserService().currentUid()).snapshots();
  }

  TextEditingController selectyear = TextEditingController();
  TextEditingController companyBio = TextEditingController();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return StreamBuilder<DocumentSnapshot>(
        stream: stream,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Scaffold(body: Text("Somthing went Wrong"));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: circularProgress(context));
          }

          UserModel user =
              UserModel.fromJson(snapshot.data!.data() as Map<String, dynamic>);
          return Scaffold(
              appBar: appBar(
                user,
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 200,
                      child: Stack(
                        children: [
                          Container(
                            height: 150,
                            width: width,
                            child: Image.asset(
                              'assets/images/background.jpg',
                              height: height,
                              width: width,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                              bottom: 0,
                              left: 20,
                              child: Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Constants.borderColor,
                                          width: 2),
                                      borderRadius: BorderRadius.circular(60)),
                                  child: CircleAvatar(
                                      backgroundColor: Colors.black26,
                                      radius: 60,
                                      child: ClipOval(
                                          child: user.photourl == ''
                                              ? const Icon(
                                                  Icons.people_alt,
                                                  size: 60,
                                                )
                                              : Image.network(
                                                  user.photourl!,
                                                  fit: BoxFit.fill,
                                                  width: width,
                                                  height: height,
                                                ))))),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 20, right: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.username!,
                              style: GoogleFonts.robotoSlab(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Text(
                            user.usertype!,
                            style: GoogleFonts.kanit(
                                fontSize: 18, fontWeight: FontWeight.normal),
                          ),
                          SizedBox(
                            height: height * 0.01,
                          ),
                          Text(
                            user.location!.toUpperCase(),
                            style: GoogleFonts.balsamiqSans(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    user.usertype == "Transporator"
                        ? user.userkycstatus == 'Pending'
                            ? VerifyKYC()
                            : completedKYC()
                        : Container(),
                    SizedBox(
                      height: 30,
                    ),
                    user.usertype == "Transporator"
                        ? user.companybio!.bio! == ""
                            ? Container(
                                alignment: Alignment.center,
                                child: const Text(
                                  "Profile Looks empty!",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                            : Container(
                                alignment: Alignment.center,
                                child: Text(user.companybio!.bio!),
                              )
                        : Container(),
                    const SizedBox(
                      height: 10,
                    ),
                    user.usertype == "Transporator"
                        ? yearcontainer(user)
                        : Container(),
                    user.usertype == "Transporator"
                        ? container(user)
                        : Container(),
                  ],
                ),
              ));
        });
  }

  AppBar appBar(UserModel user) {
    return AppBar(
      elevation: 0.0,
      backgroundColor: Color(0XFF142438),
      title: Text(
        user.companyname == 'null' ? "Profile" : user.companyname.toString(),
        style: GoogleFonts.oswald(),
      ),
      actions: [
        Padding(
            padding: const EdgeInsets.only(right: 15),
            child: IconButton(
                splashRadius: 20,
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfile(user: user)));
                },
                icon: const Icon(
                  Icons.edit,
                  color: Colors.white,
                )))
      ],
    );
  }

  Widget yearcontainer(UserModel user) {
    int? currentYear = DateTime.now().year;

    int? userYear = int.tryParse(user.companybio!.esbmyear!) ?? 0;

    var result = currentYear - userYear;

    return user.companybio!.esbmyear! == ""
        ? Container()
        : Container(
            height: 25,
            color: Color(0xff183850),
            alignment: Alignment.center,
            child: Text(
              "${result.toString()}+ YEARS IN BUSINESS",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
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

  Widget VerifyKYC() {
    return InkWell(
        onTap: () {
          // Navigator.pushNamed(context, PageRoutes.kycverified);
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => KycVerified()));
        },
        child: Container(
            height: 120,
            color: Colors.brown[100],
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Complete your KYC and become"),
                      RichText(
                          text: const TextSpan(
                              text: "a",
                              style: TextStyle(
                                  color: Colors.black45, fontSize: 15),
                              children: [
                            TextSpan(
                              text: " VERIFIED BUSINESS",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                  fontSize: 16),
                            )
                          ])),
                      Container(
                        height: 30,
                        width: 130,
                        color: Colors.blue[900],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Proceed KYC",
                              style: TextStyle(color: Colors.white),
                            ),
                            Icon(
                              Icons.double_arrow,
                              color: Colors.white24,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    child: Image.asset("assets/images/phone.jpg"),
                  )
                ],
              ),
            )));
  }

  Widget container(UserModel user) {
    return Container(
      // height: 10,
      decoration: BoxDecoration(border: Border.all(color: Colors.white)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Image.asset(
            'assets/images/download.jpg',
            width: 80,
            height: 80,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(
                height: 10,
              ),
              InkWell(
                  onTap: () {
                    _onCompanyBio(user);
                  },
                  child: Container(
                    width: 250,
                    height: 40,
                    decoration:
                        BoxDecoration(border: Border.all(color: Colors.blue)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add),
                        Text("Add Company Bio")
                      ],
                    ),
                  )),
              const SizedBox(
                height: 10,
              )
            ],
          )
        ],
      ),
    );
  }

  _onCompanyBio(UserModel user) {
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
                  child: _buildCompanyBioSheet(user),
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

  Widget _buildCompanyBioSheet(UserModel user) {
    return StatefulBuilder(builder: (context, setState) {
      // selectyear.text = user.companybio!.esbmyear!;
      return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Add Company Bio",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              const Text("Year of Establishment"),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                onTap: () {
                  _showYearsDialog(context);
                },
                // initialValue: selectyear.text,
                controller: selectyear,
                readOnly: true,
                decoration: const InputDecoration(
                    hintText: "Select Year",
                    suffixIcon: Icon(Icons.file_copy_sharp)),
                validator: (val) {
                  if (val!.isEmpty) {
                    return "Please choose the year of establishment";
                  } else {
                    return null;
                  }
                },
              ),
              SizedBox(
                height: 10,
              ),
              Card(
                color: Colors.grey[200],
                child: TextFormField(
                  controller: companyBio,
                  maxLength: 100,
                  keyboardType: TextInputType.multiline,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    disabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    hintText: "Enter your Bio here..!",
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              FlatButton(
                  color: Constants.btnBG,
                  textColor: Colors.white,
                  onPressed: () async {
                    FormState? form = _formKey.currentState;
                    form!.save();
                    if (!form.validate()) {
                      validate = true;

                      showInSnackBar(
                          'Please fix the errors in red before submitting.',
                          context);
                    } else {
                      try {
                        await usersRef.doc(UserService().currentUid()).update({
                          "companybio": {
                            "esbmyear": selectyear.text,
                            "bio": companyBio.text
                          }
                        }).catchError((e) {
                          print(e);
                        });
                        Navigator.pop(context);
                      } catch (e) {
                        print(e);
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 40,
                    alignment: Alignment.center,
                    child: Text(
                      "Save Changes",
                      style: TextStyle(fontSize: 18),
                    ),
                  ))
            ],
          ));
    });
  }

  _showYearsDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          final _singleNotifier = Provider.of<singleNotifier>(context);
          return AlertDialog(
              title: const Text("Year of Establishment",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: years
                          .map((e) => RadioListTile(
                              title: Text(e),
                              value: e,
                              groupValue: _singleNotifier.currentYear,
                              onChanged: (String? value) {
                                _singleNotifier.updateYear(value!);
                                selectyear.text = e;
                                Navigator.pop(context);
                              }))
                          .toList()),
                ),
              ));
        });
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}

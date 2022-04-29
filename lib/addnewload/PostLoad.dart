// ignore: file_names
// ignore_for_file: file_names, prefer_const_constructors, unused_field
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jiffy/jiffy.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/homepage.dart';
import 'package:thaartransport/addnewload/expiretime.dart';
import 'package:thaartransport/addnewload/orderpostconfirmed.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/controllers.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/utils/states.dart';
import 'package:thaartransport/widget/inputtextfield.dart';

class PostLoad extends StatefulWidget {
  const PostLoad({Key? key}) : super(key: key);

  @override
  _PostLoadState createState() => _PostLoadState();
}

class _PostLoadState extends State<PostLoad> {
  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool validate = false;
  bool loading = false;
  String group = '';
  static List<String> cities = [];
  bool _value = false;
  String val = '';

  // To fetch all location and show source and destination location
  fetchlocationData() {
    for (int i = 0; i < locationData.length; i++) {
      cities.add(locationData[i]['city'] + ",  " + locationData[i]['state']);
    }
  }

  static List<String> getSuggestions(String query) {
    List<String> matches = [];
    matches.addAll(cities);
    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
//End

  void initState() {
    super.initState();
    fetchlocationData();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final text = isOnline ? "Internet" : "No Internet";
    final color = isOnline ? Colors.green : Colors.red;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: appBar(),
      body: WillPopScope(
          onWillPop: () async {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage()));
            postMATcont.clear();
            postQUTcont.clear();
            postPricecont.clear();
            postexpectedcont.clear();
            postpmtmodecont.clear();
            expireLoad.clear();
            postSLcont.clear();
            postDLcont.clear();
            return true;
          },
          child: Container(
              child: SingleChildScrollView(
            reverse: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: height * 0.04,
                ),
                postloadform(text, color, isOnline),
              ],
            ),
          ))),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Constants.btntextactive,
      title: const Text("Post Load"),
      centerTitle: false,
    );
  }

  Widget postloadform(final text, final color, bool isOnline) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TypeAheadFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textFieldConfiguration: TextFieldConfiguration(
                    decoration: InputDecoration(
                      hintText: 'Source Location',
                      labelText: 'From',
                      labelStyle: TextStyle(color: Colors.black),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.textfieldborder)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        // width: 2.5,
                        color: Constants.textfieldborder,
                      )),
                    ),
                    controller: postSLcont,
                  ),
                  suggestionsCallback: (pattern) async {
                    return await getSuggestions(pattern);
                  },
                  transitionBuilder: (context, suggestionsBox, controller) {
                    return suggestionsBox;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.toString()),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    postSLcont.text = suggestion.toString();
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Source, Eg. Mumbai';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                TypeAheadFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textFieldConfiguration: TextFieldConfiguration(
                    decoration: InputDecoration(
                      hintText: 'Destination Location',
                      labelText: 'To',
                      labelStyle: TextStyle(color: Colors.black),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.textfieldborder)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        // width: 2.5,
                        color: Constants.textfieldborder,
                      )),
                    ),
                    controller: postDLcont,
                  ),
                  suggestionsCallback: (pattern) async {
                    return await getSuggestions(pattern);
                  },
                  transitionBuilder: (context, suggestionsBox, controller) {
                    return suggestionsBox;
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(suggestion.toString()),
                    );
                  },
                  onSuggestionSelected: (suggestion) {
                    postDLcont.text = suggestion.toString();
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter destination, Eg. Mumbai';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                inputTextField(
                  postMATcont,
                  "Material",
                  'Material',
                  false,
                  TextInputType.text,
                  [],
                  () {},
                  (value) {
                    if (value!.isEmpty) {
                      return 'Enter material, Eg. Steel';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                inputTextField(
                  postQUTcont,
                  "Quantity",
                  "Quantity",
                  false,
                  TextInputType.number,
                  [FilteringTextInputFormatter.digitsOnly],
                  () {},
                  (value) {
                    if (value!.isEmpty || value == '') {
                      return 'Please Enter Quantity';
                    } else if (int.parse(value) > 100) {
                      return 'Please Enter Quantity under 100';
                    }
                  },
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.number,
                  controller: postPricecont,
                  readOnly: true,
                  cursorColor: Constants.cursorColor,
                  onTap: () {
                    _onButtonPressed();
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(15),
                    isDense: true,
                    hintText: "price unit",
                    labelText: 'Price Unit',
                    labelStyle: TextStyle(color: Colors.black),
                    suffixIcon: const Icon(
                      Icons.keyboard_arrow_right_outlined,
                      color: Colors.black,
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Constants.textfieldborder)),
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Constants.textfieldborder)),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please select any one';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                inputTextField(
                  postexpectedcont,
                  "Expected Price",
                  "Expected Price",
                  false,
                  TextInputType.number,
                  [FilteringTextInputFormatter.digitsOnly],
                  () {},
                  (value) {
                    if (value!.isEmpty) {
                      return 'Please Enter the price';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onTap: _onPaymentMode,
                  readOnly: true,
                  controller: postpmtmodecont,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(15),
                      isDense: true,
                      labelText: "Payment Modes",
                      suffixIcon: const Icon(
                        Icons.keyboard_arrow_right_outlined,
                        color: Colors.black,
                        size: 15,
                      ),
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.textfieldborder)),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.textfieldborder))),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please select any one';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                inputTextField(
                  expireLoad,
                  "Load expires in",
                  "Load expires in",
                  true,
                  TextInputType.text,
                  [],
                  () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ExpireTime(),
                            fullscreenDialog: true));
                  },
                  (value) {
                    if (value!.isEmpty) {
                      return 'Please select load expire time';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                RaisedButton(
                  color: Color(0XFF142438),
                  onPressed: () async {
                    FormState? form = _formKey.currentState;
                    form!.save();
                    if (!form.validate()) {
                      validate = true;

                      showInSnackBar(
                          'Please fix the errors in red before submitting.',
                          context);
                    } else {
                      !isOnline
                          ? showSimpleNotification(
                              Text(
                                text,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              slideDismiss: true,
                              background: color,
                            )
                          : setState(() {
                              loading = true;
                            });
                      try {
                        DocumentSnapshot doc = await usersRef
                            .doc(firebaseAuth.currentUser!.uid)
                            .get();
                        var user = UserModel.fromJson(
                            doc.data() as Map<String, dynamic>);
                        var ref = postRef.doc();
                        ref.set({
                          "postid": ref.id,
                          "ownerId": user.id,
                          "expectedprice": postexpectedcont.text,
                          "postexpiretime": expireloadtime.text,
                          "paymentmode": postpmtmodecont.text,
                          "quantity": postQUTcont.text,
                          "destinationlocation": postDLcont.text,
                          "priceunit": postPricecont.text,
                          "material": postMATcont.text,
                          "sourcelocation": postSLcont.text,
                          "loadposttime": Jiffy(DateTime.now()).yMMMMEEEEdjm,
                          "loadstatus": 'Active',
                          "posttime": FieldValue.serverTimestamp(),
                          'loadorderstatus': 'Active',
                        }).catchError((e) {
                          print(e);
                        });

                        await CoolAlert.show(
                            context: context,
                            type: CoolAlertType.loading,
                            text: 'Load Posted Successfully',
                            lottieAsset: 'assets/782-check-mark-success.json',
                            autoCloseDuration: Duration(seconds: 2),
                            animType: CoolAlertAnimType.slideInUp,
                            title: 'Load Posted Successfully');

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    OrderPostConfirmed(ref.id)));
                      } catch (e) {
                        print(e);

                        showInSnackBar('Uploaded successfully!', context);
                        setState(() {
                          loading = false;
                        });
                      }
                    }
                  },
                  child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      width: width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Next",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white)),
                          Icon(
                            Icons.keyboard_arrow_right_outlined,
                            color: Colors.white,
                          ),
                        ],
                      )),
                )
              ],
            )));
  }

  _onButtonPressed() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            height: 250,
            child: Container(
              child: _buildBottomNavigationMenu(),
              decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
            ),
          );
        });
  }

  Column _buildBottomNavigationMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(
          height: 5,
        ),
        Center(
            child: Container(
                height: 3.0, width: 40.0, color: const Color(0xFF32335C))),
        const SizedBox(
          height: 30,
        ),
        Container(
            margin: EdgeInsets.only(left: 15),
            child: const Text("Select your price Unit",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ))),
        RadioListTile(
          title: Text("Fixed price"),
          value: 'fixed price',
          groupValue: group,
          onChanged: (value) {
            group = value as String;
            Navigator.pop(context);
            postPricecont.text = value;
          },
        ),
        RadioListTile(
          title: Text("Tonne"),
          value: 'tonne',
          groupValue: group,
          onChanged: (value) {
            group = value as String;
            postPricecont.text = value;
            Navigator.pop(context);
          },
        )
      ],
    );
  }

  _onPaymentMode() {
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                color: Color(0xFF737373),
                height: 300,
                child: Container(
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

  Widget _buildSheet() {
    return StatefulBuilder(builder: (context, setState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            height: 5,
          ),
          Center(
              child: Container(
                  height: 3.0, width: 40.0, color: const Color(0xFF32335C))),
          const SizedBox(
            height: 30,
          ),
          Container(
              margin: EdgeInsets.only(left: 15),
              child: const Text("Select payment mode",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ))),
          RadioListTile(
            title: Text("Advance pay"),
            value: "Advance pay",
            selected: _value,
            groupValue: val,
            toggleable: _value,
            onChanged: (value) {
              setState(() {
                val = value as String;
                if (_value == false) {
                  _value = true;
                } else {
                  _value = false;
                }
              });

              print(value.toString());
              print(val.toString());
              // Navigator.pop(context);
            },
          ),
          Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              const Text('Enter Advance %(Optional)'),
              const SizedBox(
                width: 10,
              ),
              Flexible(
                  child: TextFormField(
                controller: postadvancecont,
                readOnly: _value ? false : true,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(12),
                    isDense: true,
                    labelStyle: TextStyle(color: Colors.black),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Constants.textfieldborder)),
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Constants.textfieldborder))),
              )),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          RadioListTile(
            title: Text("ToPay"),
            value: "ToPay",
            groupValue: val,
            selected: _value,
            toggleable: _value,
            onChanged: (value) {
              setState(() {
                val = value as String;
                if (_value == false) {
                  _value = true;
                } else {
                  _value = false;
                }
              });
              print(value.toString());
              print(val.toString());
              // Navigator.pop(context);
            },
          ),
          RaisedButton(
              color: Constants.btnBG,
              textColor: Constants.white,
              onPressed: () {
                if (val == "Advance pay" && postadvancecont.text.isEmpty) {
                  Fluttertoast.showToast(
                      msg: "Advance pay should not be blank");
                } else if (val == "Advance pay" &&
                    postadvancecont.text.isNotEmpty) {
                  postpmtmodecont.text =
                      "${postadvancecont.text}% " + val.toString();
                  Navigator.pop(context);
                } else {
                  postpmtmodecont.text = val.toString();
                  Navigator.pop(context);
                }
              },
              child: Container(
                height: 45,
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Next",
                ),
              ))
        ],
      );
    });
  }
  // for paymentoption

  // To get the source Address
  // void updateSource(String name1) {
  //   setState(() {
  //     controller1.text = name1;
  //   });
  // }

// To get the Destination Address
  // void updateDestination(String des) {
  //   setState(() {
  //     controller2.text = des;
  //   });
  // }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

// To pass the all controller value on nextPage(PaymentDetails)

}

// ignore: file_names
// ignore_for_file: file_names, prefer_const_constructors, unused_field
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/homepage.dart';
import 'package:thaartransport/addnewload/expiretime.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/controllers.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/utils/states.dart';

class UpdateLoad extends StatefulWidget {
  PostModal posts;
  UpdateLoad({required this.posts});

  @override
  _UpdateLoadState createState() => _UpdateLoadState();
}

class _UpdateLoadState extends State<UpdateLoad> {
  TextEditingController updatePriceunit = TextEditingController();
  TextEditingController updatePaymentmode = TextEditingController();
  TextEditingController sourceController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool validate = false;
  bool loading = false;
  String _selectedItem = '';
  String group = '';
  void initState() {
    fetchData();
    updatePriceunit.text = widget.posts.priceunit.toString();
    updatePaymentmode.text = widget.posts.paymentmode.toString();
    sourceController.text = widget.posts.sourcelocation.toString();
    destinationController.text = widget.posts.destinationlocation.toString();
  }

  int multiplyVal = 0;

  bool _value = false;
  String val = '';

  // void dispose() {
  //   quantity.clear();
  // }

  String timeCheck = '';

  // for inital value
  String? updateSource;
  String? updateDestination;
  String? updateMaterial;
  String? updateQuantity;
  String? updateExpectedprice;
  String? updateloadexpire;

  fetchData() {
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

  static List<String> cities = [];

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final text = isOnline ? "Internet" : "No Internet";
    final color = isOnline ? Colors.green : Colors.red;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: appBar(),
      body: Container(
          child: SingleChildScrollView(
        reverse: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: height * 0.04,
            ),
            documentField(text, color, isOnline),
            SizedBox(
              height: height * 0.09,
            ),
          ],
        ),
      )),
    );
  }

  callFunction() async {
    try {
      loading = true;
      await postRef.doc(widget.posts.postid).update({
        "expectedprice": updateExpectedprice,
        "postexpiretime": expireloadtime.text,
        "paymentmode": updatePaymentmode.text,
        "quantity": updateQuantity,
        "destinationlocation": destinationController.text,
        "priceunit": updatePriceunit.text,
        "material": updateMaterial,
        "sourcelocation": sourceController.text,
        "loadposttime": Jiffy(DateTime.now()).yMMMMEEEEdjm,
        "loadstatus": 'Active',
        "posttime": FieldValue.serverTimestamp(),
      }).catchError((e) {
        print(e);
      });

      loading = false;
      await CoolAlert.show(
          context: context,
          type: CoolAlertType.loading,
          text: 'Load Posted Successfully',
          lottieAsset: 'assets/782-check-mark-success.json',
          autoCloseDuration: Duration(seconds: 2),
          animType: CoolAlertAnimType.slideInUp,
          title: 'Load Posted Successfully');

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } catch (e) {
      print(e);
      loading = false;

      showInSnackBar('Uploaded successfully!', context);
    }
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Constants.btntextactive,
      title: const Text("Repost Load"),
      centerTitle: false,
    );
  }

  Widget documentField(final text, final color, bool isOnline) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Padding(
        padding: const EdgeInsets.only(left: 15, right: 15),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TypeAheadFormField(
                  // initialValue: updateSource,
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: sourceController,
                    decoration: InputDecoration(
                      hintText: 'Source Location',
                      labelText: 'From',
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
                  onSaved: (val) {
                    sourceController.text = val.toString();
                  },
                  onSuggestionSelected: (suggestion) {
                    sourceController.text = suggestion.toString();
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
                  // initialValue: updateDestination,
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: destinationController,
                    decoration: InputDecoration(
                      hintText: 'Destination Location',
                      labelText: 'To',
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
                  onSaved: (val) {
                    destinationController.text = val.toString();
                  },
                  onSuggestionSelected: (suggestion) {
                    destinationController.text = suggestion.toString();
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Destination, Eg. Mumbai';
                    }
                    return null;
                  },
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                TextFormField(
                  textInputAction: TextInputAction.next,
                  initialValue: widget.posts.material,
                  // controller: material,
                  cursorColor: Constants.cursorColor,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(15),
                      isDense: true,
                      hintText: "Material",
                      labelText: 'Material',
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.textfieldborder)),
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Constants.textfieldborder),
                      )),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter material, Eg. Steel';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    updateMaterial = val;
                  },
                  onSaved: (val) {
                    updateMaterial = val;
                  },
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                TextFormField(
                  initialValue: widget.posts.quantity,
                  // controller: quantity,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    // WhitelistingTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(15),
                      isDense: true,
                      labelText: "Quantity",
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.textfieldborder)),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.textfieldborder))),
                  validator: (value) {
                    if (value!.isEmpty || value == '') {
                      return 'Please Enter Quantity';
                    } else if (int.parse(value) > 100) {
                      return 'Please Enter Quantity under 100';
                    }
                  },
                  onChanged: (val) {
                    updateQuantity = val;
                  },
                  onSaved: (val) {
                    updateQuantity = val;
                  },
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  // initialValue: widget.posts.priceunit,
                  controller: updatePriceunit,
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
                TextFormField(
                  initialValue: widget.posts.expectedprice,
                  // controller: expectedPrice,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    // WhitelistingTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(15),
                      isDense: true,
                      labelText: "Expected Price",
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.textfieldborder)),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.textfieldborder))),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please Enter the price';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    updateExpectedprice = val;
                  },
                  onSaved: (val) {
                    updateExpectedprice = val;
                  },
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                TextFormField(
                  onTap: _onPaymentMode,
                  readOnly: true,
                  // initialValue: widget.posts.paymentmode,
                  controller: updatePaymentmode,
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
                TextFormField(
                  controller: expireLoad,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ExpireTime()));
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(15),
                      isDense: true,
                      labelText: "Load expires in",
                      labelStyle: TextStyle(color: Colors.black),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.textfieldborder)),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.textfieldborder))),
                  validator: (value) {
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
                  color: Constants.thaartheme,
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
                          : callFunction();
                    }
                  },
                  child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      width: width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("SUBMIT",
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

  // void caluclate() {
  //   if (quantity.text.trim().isNotEmpty &&
  //       priceController.text.trim().isNotEmpty) {
  //     final firstvalue = double.parse(quantity.text);
  //     final secondvalue = double.parse(priceController.text);
  //     thirdcontroller.text = (firstvalue * secondvalue).toString();
  //     multiplyVal = (firstvalue * secondvalue).toInt();
  //   } else {
  //     thirdcontroller.clear();
  //   }
  // }

  // for price unit bottom sheet value

  _onButtonPressed() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            color: Color(0xFF737373),
            // height: 250,
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
          height: 20,
        ),
        Container(
            margin: EdgeInsets.only(left: 15, right: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select your price Unit",
                  style: GoogleFonts.ibmPlexSerif(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.close, size: 25, color: Colors.black))
              ],
            )),
        SizedBox(
          height: 15,
        ),
        RadioListTile(
          title: Text(
            "Fixed price",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          value: 'fixed price',
          groupValue: group,
          onChanged: (value) {
            group = value as String;
            Navigator.pop(context);
            updatePriceunit.text = value;
          },
        ),
        RadioListTile(
          title: Text(
            "Tonne",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          value: 'tonne',
          groupValue: group,
          onChanged: (value) {
            group = value as String;
            updatePriceunit.text = value;
            Navigator.pop(context);
          },
        ),
        SizedBox(
          height: 30,
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
                // height: 300,
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
              margin: EdgeInsets.only(left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select payment mode",
                    style: GoogleFonts.ibmPlexSerif(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        size: 25,
                        color: Colors.black,
                      ))
                ],
              )),
          SizedBox(
            height: 15,
          ),
          RadioListTile(
            title: Text(
              "Advance pay",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
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
              const Text(
                'Enter Advance %(Optional)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
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
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          RadioListTile(
            title: Text(
              "ToPay",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
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
            },
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8),
            child: RaisedButton(
                color: Constants.btnBG,
                textColor: Constants.white,
                onPressed: () async {
                  if (val == "Advance pay" && postadvancecont.text.isEmpty) {
                    Fluttertoast.showToast(
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.cyan,
                        msg: "Advance pay should not be blank");
                  } else if (val == "Advance pay" &&
                      postadvancecont.text.isNotEmpty) {
                    updatePaymentmode.text =
                        "${postadvancecont.text}% " + val.toString();
                    Navigator.pop(context);
                  } else {
                    updatePaymentmode.text = val.toString();
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  height: 45,
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    "Next",
                    style: TextStyle(fontSize: 18),
                  ),
                )),
          ),
          SizedBox(
            height: 30,
          )
        ],
      );
    });
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

// To pass the all controller value on nextPage(PaymentDetails)

}

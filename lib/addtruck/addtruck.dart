// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, unused_local_variable, prefer_function_declarations_over_variables

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/homepage.dart';
import 'package:thaartransport/addtruck/textfield.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/states.dart';
import 'package:thaartransport/utils/validations.dart';
import 'package:thaartransport/utils/firebase.dart';

import '../services/connectivity.dart';
import '../utils/routeslocation.dart';

class AddTruck extends StatefulWidget {
  const AddTruck({Key? key}) : super(key: key);

  @override
  _AddTruckState createState() => _AddTruckState();
}

class _AddTruckState extends State<AddTruck> {
  bool showDoc = false;
  bool validate = false;
  bool isLoading = false;
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController sourceLocation = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController lorrynumber = TextEditingController();
  TextEditingController expireController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  TextEditingController alreadylodedController = TextEditingController();
  TextEditingController leftloadController = TextEditingController();

  // To save expire time in dateTime Format use this controller and post expire time
  TextEditingController expiretime = TextEditingController();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  var id = truckRef.doc().id.toString();
  List<String> _selectedItems = [];

  void _showMultiSelect() async {
    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MultiSelect(items: states);
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _selectedItems = results;
      });
    }
  }

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
  void initState() {
    super.initState();
    fetchData();
  }

  bool _value = false;
  String val = '';

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final text = isOnline ? "Internet" : "No Internet";
    final color = isOnline ? Colors.green : Colors.red;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        clearController();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
              clearController();
            },
            child: Icon(Icons.arrow_back_rounded),
          ),
          backgroundColor: Color(0XFF142438),
          title: Text("Add Truck"),
        ),
        body: Padding(
            padding: EdgeInsets.only(
                left: 15, right: 15, top: height * 0.04, bottom: 10),
            child: Container(
                child: SingleChildScrollView(
              reverse: true,
              child: Column(
                children: [
                  _BuildTextField(),
                  SizedBox(
                    height: height * 0.06,
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  sourceLocation.text.isEmpty ||
                          destinationController.text.isEmpty ||
                          lorrynumber.text.isEmpty ||
                          capacityController.text.isEmpty ||
                          alreadylodedController.text.isEmpty ||
                          leftloadController.text.isEmpty ||
                          expireController.text.isEmpty
                      ? Container()
                      : Container(
                          width: width,
                          height: 48,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  primary: Color(0XFF142438)),
                              onPressed: () async {
                                FormState? form = formkey.currentState;
                                form!.save();
                                if (!form.validate()) {
                                  validate = true;
                                  showInSnackBar(
                                      "Please fix the error in red before submitting.",
                                      context);
                                } else if (_selectedItems.isEmpty) {
                                  return EasyLoading.showToast(
                                      'Please select your routes');
                                } else {
                                  !isOnline
                                      ? showInSnackBar(
                                          'Please internet connection', context)
                                      : setState(() {
                                          isLoading = true;
                                        });
                                  DocumentSnapshot doc = await usersRef
                                      .doc(firebaseAuth.currentUser!.uid)
                                      .get();
                                  var user = UserModel.fromJson(
                                      doc.data() as Map<String, dynamic>);
                                  var truckref = truckRef.doc();
                                  truckref.set({
                                    "id": truckref.id,
                                    "ownerId": user.id,
                                    "lorrynumber": lorrynumber.text,
                                    "sourcelocation": sourceLocation.text,
                                    "destinationlocation":
                                        destinationController.text,
                                    "expiretruck": expiretime.text,
                                    "capacity": capacityController.text,
                                    "alcapacity": alreadylodedController.text,
                                    "leftcapacity": leftloadController.text,
                                    "usernumber": user.usernumber,
                                    "truckposttime":
                                        Jiffy(DateTime.now()).yMMMMEEEEdjm,
                                    "truckstatus": "ACTIVE",
                                    "time": FieldValue.serverTimestamp(),
                                    "routes": _selectedItems
                                  });
                                  var changeslorry =
                                      truckref.collection('changeslorry').doc();
                                  await usersRef
                                      .doc(UserService().currentUid())
                                      .update({'isTruck': true});
                                  await changeslorry.set({
                                    "id": changeslorry.id,
                                    "lorrynumber": lorrynumber.text,
                                    "sourcelocation": sourceLocation.text,
                                    "destinationlocation":
                                        destinationController.text,
                                    "expiretruck": expiretime.text,
                                    "capacity": capacityController.text,
                                    "alcapacity": alreadylodedController.text,
                                    "leftcapacity": leftloadController.text,
                                    "truckposttime":
                                        Jiffy(DateTime.now()).yMMMMEEEEdjm,
                                    "routes": _selectedItems
                                  });
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomePage()));
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              },
                              child: Text("SUBMIT")),
                        ),
                ],
              ),
            ))),
      ),
    );
  }

  Widget _BuildTextField() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Form(
      key: formkey,
      child: Column(
        children: [
          TypeAheadFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            textFieldConfiguration: TextFieldConfiguration(
              decoration: InputDecoration(
                hintText: 'Source Location',
                labelText: 'From',
                hintStyle: TextStyle(color: Colors.black),
                labelStyle: TextStyle(color: Colors.black),
                isDense: true,
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Constants.textfieldborder)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  width: 1,
                  color: Constants.textfieldborder,
                )),
              ),
              controller: sourceLocation,
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
              sourceLocation.text = suggestion.toString();
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
                hintStyle: TextStyle(color: Colors.black),
                labelText: 'To',
                labelStyle: TextStyle(color: Colors.black),
                isDense: true,
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Constants.textfieldborder)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  width: 1,
                  color: Constants.textfieldborder,
                )),
              ),
              controller: destinationController,
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
              destinationController.text = suggestion.toString();
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
          sourceLocation.text.isEmpty || destinationController.text.isEmpty
              ? Container()
              : textField(
                  lorrynumber,
                  'KA 10 AE 5555',
                  'Lorry Number',
                  false,
                  TextCapitalization.characters,
                  TextInputType.name,
                  [
                    LengthLimitingTextInputFormatter(10),
                  ],
                  () {}, (val) {
                  // lorrynumber.text = val;
                }, Validations.validateNumber),
          SizedBox(
            height: height * 0.03,
          ),
          sourceLocation.text.isEmpty ||
                  destinationController.text.isEmpty ||
                  lorrynumber.text.isEmpty
              ? Container()
              : textField(
                  capacityController,
                  "In Tonne(S)",
                  'Truck Capacity',
                  false,
                  TextCapitalization.none,
                  TextInputType.number,
                  [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  () {}, (val) {
                  // capacityController.text = val;
                }, (value) {
                  if (value!.isEmpty || value == '') {
                    return 'Please enter the capacity';
                  } else if (int.parse(value) > 100) {
                    return 'Capacity more than 100 tonnes is not allowed';
                  }
                }),
          SizedBox(
            height: height * 0.03,
          ),
          sourceLocation.text.isEmpty ||
                  destinationController.text.isEmpty ||
                  lorrynumber.text.isEmpty ||
                  capacityController.text.isEmpty
              ? Container()
              : textField(
                  alreadylodedController,
                  "In Tonne(S)",
                  'loaded capacity',
                  false,
                  TextCapitalization.none,
                  TextInputType.number,
                  [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  () {},
                  (val) {
                    setState(() {
                      final value = max(
                          0,
                          int.parse(capacityController.text) -
                              int.parse(alreadylodedController.text));
                      leftloadController.text = value.toString();
                    });
                  },
                  (value) {
                    if (value!.isEmpty || value == '') {
                      return 'Please enter the Alredy loaded capacity';
                    } else if (int.parse(value) > 100) {
                      return 'Capacity more than 100 tonnes is not allowed';
                    }
                  },
                ),
          SizedBox(
            height: height * 0.03,
          ),
          sourceLocation.text.isEmpty ||
                  destinationController.text.isEmpty ||
                  lorrynumber.text.isEmpty ||
                  capacityController.text.isEmpty ||
                  alreadylodedController.text.isEmpty
              ? Container()
              : textField(
                  leftloadController,
                  "In Tonne(S)",
                  'Left Capacity',
                  true,
                  TextCapitalization.none,
                  TextInputType.number,
                  [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  () {},
                  (val) {}, (value) {
                  if (value!.isEmpty || value == '') {
                    return 'Please enter the Left Capacity';
                  } else if (int.parse(value) > 100) {
                    return 'Capacity more than 100 tonnes is not allowed';
                  }
                }),
          SizedBox(
            height: height * 0.03,
          ),
          sourceLocation.text.isEmpty ||
                  destinationController.text.isEmpty ||
                  lorrynumber.text.isEmpty ||
                  capacityController.text.isEmpty ||
                  alreadylodedController.text.isEmpty ||
                  leftloadController.text.isEmpty
              ? Container()
              : textField(
                  expireController,
                  "Expire Truck",
                  'Expire Truck',
                  true,
                  TextCapitalization.none,
                  TextInputType.text,
                  [],
                  () {
                    expireSheet();
                  },
                  (val) {
                    expireController.text = val;
                  },
                  (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the expire time';
                    }
                    return null;
                  },
                ),
          SizedBox(
            height: height * 0.03,
          ),
          sourceLocation.text.isEmpty ||
                  destinationController.text.isEmpty ||
                  lorrynumber.text.isEmpty ||
                  capacityController.text.isEmpty ||
                  alreadylodedController.text.isEmpty ||
                  leftloadController.text.isEmpty ||
                  expireController.text.isEmpty
              ? Container()
              : InkWell(
                  onTap: () {
                    _showMultiSelect();
                  },
                  child: Container(
                    height: 50,
                    width: width,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                    ),
                    child: Text.rich(TextSpan(
                        style: TextStyle(fontSize: 16),
                        text: "Your routes ",
                        children: [
                          TextSpan(
                              style: TextStyle(fontWeight: FontWeight.w600),
                              text: _selectedItems.isNotEmpty
                                  ? "${_selectedItems.length}"
                                  : '')
                        ])),
                  ),
                )
        ],
      ),
    );
  }

  clearController() {
    sourceLocation.clear();
    destinationController.clear();
    lorrynumber.clear();
    capacityController.clear();
    alreadylodedController.clear();
    leftloadController.clear();
    expireController.clear();
  }

  expireSheet() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25))),
            child: StatefulBuilder(builder: (context, state) {
              return Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20, right: 20, top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select your expiring time",
                          style: GoogleFonts.ibmPlexSerif(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close_outlined),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Expanded(
                    child: Container(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            RadioListTile(
                                value:
                                    '01 hours ${Jiffy(DateTime.now().add(Duration(hours: 1))).yMMMMEEEEdjm}',
                                title: Text(
                                  "01 Hours",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(Jiffy(
                                        DateTime.now().add(Duration(hours: 1)))
                                    .yMMMMEEEEdjm),
                                groupValue: val,
                                onChanged: (value) {
                                  state(() {});
                                  setState(() {
                                    val = value as String;
                                    expiretime.text = DateTime.now()
                                        .add(Duration(hours: 1))
                                        .toString();
                                    expireController.text = value;
                                    Navigator.pop(context);
                                  });
                                }),
                            RadioListTile(
                                value:
                                    '02 hours ${Jiffy(DateTime.now().add(Duration(hours: 2))).yMMMMEEEEdjm}',
                                title: Text(
                                  "02 Hours",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(Jiffy(
                                        DateTime.now().add(Duration(hours: 2)))
                                    .yMMMMEEEEdjm),
                                groupValue: val,
                                onChanged: (value) {
                                  state(() {});
                                  setState(() {
                                    val = value as String;
                                    expiretime.text = DateTime.now()
                                        .add(Duration(hours: 2))
                                        .toString();
                                    expireController.text = value;
                                    Navigator.pop(context);
                                  });
                                }),
                            RadioListTile(
                                value:
                                    '03 hours ${Jiffy(DateTime.now().add(Duration(hours: 3))).yMMMMEEEEdjm}',
                                title: Text(
                                  "03 Hours",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(Jiffy(
                                        DateTime.now().add(Duration(hours: 3)))
                                    .yMMMMEEEEdjm),
                                groupValue: val,
                                onChanged: (value) {
                                  state(() {});
                                  setState(() {
                                    val = value as String;
                                    expiretime.text = DateTime.now()
                                        .add(Duration(hours: 3))
                                        .toString();
                                    expireController.text = value;
                                    Navigator.pop(context);
                                  });
                                }),
                            RadioListTile(
                                value:
                                    '06 hours ${Jiffy(DateTime.now().add(Duration(hours: 6))).yMMMMEEEEdjm}',
                                title: Text(
                                  "06 Hours",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(Jiffy(
                                        DateTime.now().add(Duration(hours: 6)))
                                    .yMMMMEEEEdjm),
                                groupValue: val,
                                onChanged: (value) {
                                  state(() {});
                                  setState(() {
                                    val = value as String;
                                    expiretime.text = DateTime.now()
                                        .add(Duration(hours: 6))
                                        .toString();
                                    expireController.text = value;
                                    Navigator.pop(context);
                                  });
                                }),
                            RadioListTile(
                                value:
                                    '12 hours ${Jiffy(DateTime.now().add(Duration(hours: 12))).yMMMMEEEEdjm}',
                                title: Text(
                                  "12 Hours",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(Jiffy(
                                        DateTime.now().add(Duration(hours: 12)))
                                    .yMMMMEEEEdjm),
                                groupValue: val,
                                onChanged: (value) {
                                  state(() {});
                                  setState(() {
                                    val = value as String;
                                    expiretime.text = DateTime.now()
                                        .add(Duration(hours: 12))
                                        .toString();
                                    expireController.text = value;
                                    Navigator.pop(context);
                                  });
                                }),
                            RadioListTile(
                                value:
                                    '24 hours ${Jiffy(DateTime.now().add(Duration(hours: 24))).yMMMMEEEEdjm}',
                                title: Text(
                                  "24 Hours",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(Jiffy(
                                        DateTime.now().add(Duration(hours: 24)))
                                    .yMMMMEEEEdjm),
                                groupValue: val,
                                onChanged: (value) {
                                  state(() {});
                                  setState(() {
                                    val = value as String;
                                    expiretime.text = DateTime.now()
                                        .add(Duration(hours: 24))
                                        .toString();
                                    expireController.text = value;
                                    Navigator.pop(context);
                                  });
                                }),
                            RadioListTile(
                                value:
                                    '48 hours ${Jiffy(DateTime.now().add(Duration(hours: 48))).yMMMMEEEEdjm}',
                                title: Text(
                                  "48 Hours",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                subtitle: Text(Jiffy(
                                        DateTime.now().add(Duration(hours: 48)))
                                    .yMMMMEEEEdjm),
                                groupValue: val,
                                onChanged: (value) {
                                  state(() {});
                                  setState(() {
                                    val = value as String;
                                    expiretime.text = DateTime.now()
                                        .add(Duration(hours: 48))
                                        .toString();
                                    expireController.text = value;
                                    Navigator.pop(context);
                                  });
                                }),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          );
        });
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      value,
      style: TextStyle(fontSize: 16),
    )));
  }
}

class MultiSelect extends StatefulWidget {
  final List<String> items;
  const MultiSelect({Key? key, required this.items}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  final List<String> _selectedItems = [];

  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _submit() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Select your Routes',
        style: GoogleFonts.ibmPlexSerif(
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
                    value: _selectedItems.contains(item),
                    title: Text(item),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (isChecked) => _itemChange(item, isChecked!),
                  ))
              .toList(),
        ),
      ),
      actions: [
        RaisedButton(
          textColor: Colors.white,
          color: Colors.red,
          child: const Text('CANCEL'),
          onPressed: _cancel,
        ),
        RaisedButton(
          textColor: Colors.white,
          color: Constants.thaartheme,
          child: const Text(
            'SUBMIT',
            style: TextStyle(fontSize: 16),
          ),
          onPressed: _submit,
        ),
      ],
    );
  }
}

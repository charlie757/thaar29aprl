// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, unused_local_variable, prefer_function_declarations_over_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:jiffy/jiffy.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/NEW/homepage.dart';
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
    return Scaffold(
      appBar: AppBar(
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
                Container(
                  width: width,
                  height: 48,
                  child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(primary: Color(0XFF142438)),
                      onPressed: () async {
                        FormState? form = formkey.currentState;
                        form!.save();
                        if (!form.validate()) {
                          validate = true;
                          showInSnackBar(
                              "Please fix the error in red before submitting.",
                              context);
                        } else if (_selectedItems.isEmpty) {
                          return showInSnackBar(
                              "Please select your routes", context);
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
                            "destinationlocation": destinationController.text,
                            "expiretruck": expiretime.text,
                            "capacity": capacityController.text,
                            "usernumber": user.usernumber,
                            "truckposttime": Jiffy(DateTime.now()).yMMMMEEEEdjm,
                            "truckstatus": "ACTIVE",
                            "time": FieldValue.serverTimestamp(),
                            "routes": _selectedItems
                          });
                          await usersRef
                              .doc(UserService().currentUid())
                              .update({'isTruck': true});
                          await truckref.collection('changeslorry').add({
                            "lorrynumber": lorrynumber.text,
                            "sourcelocation": sourceLocation.text,
                            "destinationlocation": destinationController.text,
                            "expiretruck": expiretime.text,
                            "capacity": capacityController.text,
                            "truckposttime": Jiffy(DateTime.now()).yMMMMEEEEdjm,
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
                labelStyle: TextStyle(color: Colors.black),
                isDense: true,
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Constants.textfieldborder)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  width: 2.5,
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
                labelText: 'To',
                labelStyle: TextStyle(color: Colors.black),
                isDense: true,
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Constants.textfieldborder)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  width: 2.5,
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
          TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              textCapitalization: TextCapitalization.characters,
              controller: lorrynumber,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Constants.textfieldborder)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  width: 2.5,
                  color: Constants.textfieldborder,
                )),
                labelText: 'Lorry Number',
                hintText: 'KA 10 AE 5555',
                labelStyle: TextStyle(color: Colors.black),
                hintStyle: TextStyle(color: Colors.black26),
              ),
              validator: Validations.validateNumber),
          SizedBox(
            height: height * 0.03,
          ),
          TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              controller: capacityController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Constants.textfieldborder)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                    width: 2.5,
                    color: Constants.textfieldborder,
                  )),
                  hintText: "In Tonne(S)",
                  labelText: 'Capacity',
                  labelStyle: TextStyle(color: Colors.black),
                  hintStyle: TextStyle(color: Colors.black26)),
              validator: (value) {
                if (value!.isEmpty || value == '') {
                  return 'Please enter the capacity';
                } else if (int.parse(value) > 100) {
                  return 'Capacity more than 100 tonnes is not allowed';
                }
              }),
          SizedBox(
            height: height * 0.03,
          ),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            readOnly: true,
            onTap: () {
              expireSheet();
            },
            controller: expireController,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Constants.textfieldborder)),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                  width: 2.5,
                  color: Constants.textfieldborder,
                )),
                hintText: "Expire Truck",
                labelText: 'Expire Truck',
                labelStyle: TextStyle(color: Colors.black),
                hintStyle: TextStyle(color: Colors.black26)),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Please enter the expire time';
              }
              return null;
            },
          ),
          SizedBox(
            height: height * 0.03,
          ),
          InkWell(
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
                            ? "(${_selectedItems.length})"
                            : '')
                  ])),
            ),
          )
        ],
      ),
    );
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
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      margin: EdgeInsets.all(15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select your expiring time",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 18),
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
                    RadioListTile(
                        value:
                            '01 hours ${Jiffy(DateTime.now().add(Duration(hours: 1))).yMMMMEEEEdjm}',
                        title: Text("01 Hours"),
                        subtitle: Text(
                            Jiffy(DateTime.now().add(Duration(hours: 1)))
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
                          });
                        }),
                    RadioListTile(
                        value:
                            '02 hours ${Jiffy(DateTime.now().add(Duration(hours: 2))).yMMMMEEEEdjm}',
                        title: Text("02 Hours"),
                        subtitle: Text(
                            Jiffy(DateTime.now().add(Duration(hours: 2)))
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
                          });
                        }),
                    RadioListTile(
                        value:
                            '03 hours ${Jiffy(DateTime.now().add(Duration(hours: 3))).yMMMMEEEEdjm}',
                        title: Text("03 Hours"),
                        subtitle: Text(
                            Jiffy(DateTime.now().add(Duration(hours: 3)))
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
                          });
                        }),
                    RadioListTile(
                        value:
                            '06 hours ${Jiffy(DateTime.now().add(Duration(hours: 6))).yMMMMEEEEdjm}',
                        title: Text("06 Hours"),
                        subtitle: Text(
                            Jiffy(DateTime.now().add(Duration(hours: 6)))
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
                          });
                        }),
                    RadioListTile(
                        value:
                            '12 hours ${Jiffy(DateTime.now().add(Duration(hours: 12))).yMMMMEEEEdjm}',
                        title: Text("12 Hours"),
                        subtitle: Text(
                            Jiffy(DateTime.now().add(Duration(hours: 12)))
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
                          });
                        }),
                    RadioListTile(
                        value:
                            '24 hours ${Jiffy(DateTime.now().add(Duration(hours: 24))).yMMMMEEEEdjm}',
                        title: Text("24 Hours"),
                        subtitle: Text(
                            Jiffy(DateTime.now().add(Duration(hours: 24)))
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
                          });
                        }),
                    RadioListTile(
                        value:
                            '48 hours ${Jiffy(DateTime.now().add(Duration(hours: 48))).yMMMMEEEEdjm}',
                        title: Text("48 Hours"),
                        subtitle: Text(
                            Jiffy(DateTime.now().add(Duration(hours: 48)))
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
                          });
                        }),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: RaisedButton(
                        color: Constants.btnBG,
                        textColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width,
                          height: 45,
                          child: Text(
                            "SUBMIT",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
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
      title: const Text('Select your Routes'),
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
        TextButton(
          child: const Text('Cancel'),
          onPressed: _cancel,
        ),
        FlatButton(
          child: const Text(
            'Submit',
            style: TextStyle(fontSize: 16),
          ),
          onPressed: _submit,
        ),
      ],
    );
  }
}

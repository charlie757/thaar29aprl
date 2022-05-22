import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:thaartransport/addtruck/addtruck.dart';
import 'package:thaartransport/addtruck/textfield.dart';
import 'package:thaartransport/modal/truckmodal.dart';
import 'package:thaartransport/services/connectivity.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/utils/routeslocation.dart';
import 'package:thaartransport/utils/states.dart';
import 'package:thaartransport/utils/validations.dart';

class RepostLorry extends StatefulWidget {
  TruckModal truckModal;
  final int routes;
  RepostLorry(this.truckModal, this.routes);

  @override
  State<RepostLorry> createState() => _RepostLorryState();
}

class _RepostLorryState extends State<RepostLorry> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController sourceLocation = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController lorrynumber = TextEditingController();
  TextEditingController expireController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  // To save expire time in dateTime Format use this controller and post expire time
  TextEditingController expiretime = TextEditingController();
  TextEditingController alreadylodedController = TextEditingController();
  TextEditingController leftloadController = TextEditingController();

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
    sourceLocation.text = widget.truckModal.sourcelocation.toString();
    destinationController.text =
        widget.truckModal.destinationlocation.toString();
    lorrynumber.text = widget.truckModal.lorrynumber.toString();
    capacityController.text = widget.truckModal.capacity.toString();
    super.initState();
    fetchData();
  }

  bool isLoading = false;
  bool validate = false;
  bool _value = false;
  String val = '';

  @override
  Widget build(BuildContext context) {
    final isOnline = Provider.of<ConnectivityProvider>(context).isOnline;
    final text = isOnline ? "Internet" : "No Internet";
    final color = isOnline ? Colors.green : Colors.red;
    return LoadingOverlay(
      isLoading: isLoading,
      progressIndicator: const CircularProgressIndicator(
          strokeWidth: 4, color: Colors.blue, backgroundColor: Colors.red),
      opacity: 0.2,
      color: Colors.white,
      child: Scaffold(
          appBar: AppBar(
            title: const Text("ReActive Truck"),
            backgroundColor: const Color(0XFF142438),
          ),
          body: builddocument(text, color, isOnline)),
    );
  }

  Widget builddocument(final text, final color, bool isOnline) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 25, bottom: 15),
      child: Form(
        key: formkey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TypeAheadFormField(
                textFieldConfiguration: TextFieldConfiguration(
                  decoration: InputDecoration(
                    hintText: 'Source Location',
                    labelText: 'From',
                    // isDense: true,
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Constants.textfieldborder)),
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
                textFieldConfiguration: TextFieldConfiguration(
                  decoration: InputDecoration(
                    hintText: 'Destination Location',
                    labelText: 'To',
                    // isDense: true,
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Constants.textfieldborder)),
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
              TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  controller: lorrynumber,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Constants.textfieldborder)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      width: 1,
                      color: Constants.textfieldborder,
                    )),
                    labelText: 'Lorry Number',
                    hintText: 'KA 10 AE 5555',
                    labelStyle: const TextStyle(color: Colors.black),
                    hintStyle: const TextStyle(color: Colors.black26),
                  ),
                  validator: Validations.validateNumber),
              SizedBox(
                height: height * 0.03,
              ),
              TextFormField(
                  controller: capacityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Constants.textfieldborder)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                        width: 1,
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
              textField(
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
              textField(
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
              TextFormField(
                readOnly: true,
                onTap: () {
                  expireSheet();
                },
                controller: expireController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Constants.textfieldborder)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                      width: 1,
                      color: Constants.textfieldborder,
                    )),
                    hintText: "Expire Truck",
                    labelText: 'Expire Truck',
                    labelStyle: const TextStyle(color: Colors.black),
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
                      style: const TextStyle(fontSize: 16),
                      text: "Your routes  ",
                      children: [
                        TextSpan(
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.green,
                                fontSize: 17),
                            text: _selectedItems.isNotEmpty
                                ? "${_selectedItems.length}"
                                : widget.truckModal.routes!.length.toString())
                      ])),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  height: 80,
                  width: width,
                  child: ListView.builder(
                      itemCount: _selectedItems.isNotEmpty
                          ? _selectedItems.length
                          : widget.truckModal.routes!.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 100,
                          child: Card(
                            color: Colors.blue[100],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.location_city,
                                  color: Colors.blue,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  _selectedItems.isNotEmpty
                                      ? _selectedItems[index].toString()
                                      : widget.truckModal.routes![index]
                                          .toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                          ),
                        );
                      })),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: width,
                height: 45,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Color(0XFF142438)),
                    onPressed: () async {
                      FormState? form = formkey.currentState;
                      form!.save();
                      if (!form.validate()) {
                        validate = true;
                        showInSnackBar(
                            "Please fix the error in red before submitting.",
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
                    child: const Text(
                      "Active Truck",
                      style: TextStyle(fontSize: 18),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  callFunction() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    await truckRef.doc(widget.truckModal.id).update({
      "lorrynumber": widget.truckModal.lorrynumber!.isEmpty
          ? widget.truckModal.lorrynumber
          : lorrynumber.text,
      "sourcelocation": widget.truckModal.sourcelocation!.isEmpty
          ? widget.truckModal.sourcelocation
          : sourceLocation.text,
      "destinationlocation": widget.truckModal.destinationlocation!.isEmpty
          ? widget.truckModal.destinationlocation
          : destinationController.text,
      "expiretruck": expiretime.text,
      "alcapacity": alreadylodedController.text,
      "leftcapacity": leftloadController.text,
      "capacity": widget.truckModal.capacity!.isEmpty
          ? widget.truckModal.capacity
          : capacityController.text,
      "time": FieldValue.serverTimestamp(),
      "truckstatus": "ACTIVE",
      "routes":
          _selectedItems.isNotEmpty ? _selectedItems : widget.truckModal.routes
    }).catchError((e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      print(e);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
        "Somthing went worng Please try again later",
        style: TextStyle(fontSize: 15),
      )));
    });
    var changeslorry =
        truckRef.doc(widget.truckModal.id).collection('changeslorry').doc();

    await changeslorry.set({
      "id": changeslorry.id,
      "lorrynumber": widget.truckModal.lorrynumber!.isEmpty
          ? widget.truckModal.lorrynumber
          : lorrynumber.text,
      "sourcelocation": widget.truckModal.sourcelocation!.isEmpty
          ? widget.truckModal.sourcelocation
          : sourceLocation.text,
      "destinationlocation": widget.truckModal.destinationlocation!.isEmpty
          ? widget.truckModal.destinationlocation
          : destinationController.text,
      "expiretruck": expiretime.text,
      "capacity": widget.truckModal.capacity!.isEmpty
          ? widget.truckModal.capacity
          : capacityController.text,
      "alcapacity": alreadylodedController.text,
      "leftcapacity": leftloadController.text,
      "truckposttime": Jiffy(DateTime.now()).yMMMMEEEEdjm,
      "routes":
          _selectedItems.isNotEmpty ? _selectedItems : widget.truckModal.routes
    });

    await CoolAlert.show(
        context: context,
        type: CoolAlertType.loading,
        text: 'truck repost Successfully',
        lottieAsset: 'assets/782-check-mark-success.json',
        autoCloseDuration: Duration(seconds: 2),
        animType: CoolAlertAnimType.slideInUp,
        title: 'truck repost has been Successfully');
    Navigator.pop(context);
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
      value,
      style: TextStyle(fontSize: 16),
    )));
  }

  expireSheet() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return Container(
            // height: 250,
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25))),
            child: StatefulBuilder(builder: (context, state) {
              return Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 10),
                    margin: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Select your expiring time",
                            style: GoogleFonts.ibmPlexSerif(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            )),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.close_outlined),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            RadioListTile(
                                value:
                                    '01 hours ${Jiffy(DateTime.now().add(Duration(hours: 1))).yMMMMEEEEdjm}',
                                title: Text("01 Hours"),
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
                                title: Text("02 Hours"),
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
                                title: Text("03 Hours"),
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
                                title: Text("06 Hours"),
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
                                title: Text("12 Hours"),
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
                                    '24 hours ${Jiffy(DateTime.now().add(const Duration(hours: 24))).yMMMMEEEEdjm}',
                                title: const Text("24 Hours"),
                                subtitle: Text(Jiffy(DateTime.now()
                                        .add(const Duration(hours: 24)))
                                    .yMMMMEEEEdjm),
                                groupValue: val,
                                onChanged: (value) {
                                  state(() {});
                                  setState(() {
                                    val = value as String;
                                    expiretime.text = DateTime.now()
                                        .add(const Duration(hours: 24))
                                        .toString();
                                    expireController.text = value;
                                    Navigator.pop(context);
                                  });
                                }),
                            RadioListTile(
                                value:
                                    '48 hours ${Jiffy(DateTime.now().add(const Duration(hours: 48))).yMMMMEEEEdjm}',
                                title: const Text("48 Hours"),
                                subtitle: Text(Jiffy(DateTime.now()
                                        .add(const Duration(hours: 48)))
                                    .yMMMMEEEEdjm),
                                groupValue: val,
                                onChanged: (value) {
                                  state(() {});
                                  setState(() {
                                    val = value as String;
                                    expiretime.text = DateTime.now()
                                        .add(const Duration(hours: 48))
                                        .toString();
                                    expireController.text = value;
                                    Navigator.pop(context);
                                  });
                                }),
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
}

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:thaartransport/addtruck/addtruck.dart';
// import 'package:thaartransport/utils/controllers.dart';
// import 'package:thaartransport/utils/firebase.dart';
// import 'package:thaartransport/utils/googleservice.dart';

// import 'package:http/http.dart' as http;

// class TruckCurrentLocation extends StatefulWidget {
//   const TruckCurrentLocation({Key? key}) : super(key: key);

//   @override
//   _TruckCurrentLocationState createState() => _TruckCurrentLocationState();
// }

// class _TruckCurrentLocationState extends State<TruckCurrentLocation> {
//   String? sessionTokenCurrentCity;
//   List<dynamic> currentList = [];

//   @override
//   void initState() {
//     super.initState();
//     trucksearchlocation.addListener(() {
//       _onChanged();
//     });
//   }

//   _onChanged() {
//     if (sessionTokenCurrentCity == null) {
//       setState(() {
//         sessionTokenCurrentCity = uuid.v4();
//       });
//     }
//     getCurrentCitySuggestion(trucksearchlocation.text);
//   }

//   void getCurrentCitySuggestion(String input) async {
//     String components = googleService().components;
//     String baseURL = googleService().baseURL;
//     String API_KEY = googleService().kPLACES_API_KEY;
//     String type = googleService().type;
//     String request =
//         '$baseURL?input=$input&types=$type&components=$components&key=$API_KEY&sessiontoken=$sessionTokenCurrentCity';
//     var response = await http.get(Uri.parse(request));
//     if (response.statusCode == 200) {
//       setState(() {
//         currentList = json.decode(response.body)['predictions'];
//       });
//     } else {
//       throw Exception('Failed to load predictions');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           backgroundColor: Colors.white,
//           elevation: 0.0,
//           bottom: PreferredSize(
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
//                 child: TextField(
//                   autofocus: true,
//                   controller: trucksearchlocation,
//                   cursorColor: Colors.black,
//                   decoration: InputDecoration(
//                       hintText: "Enter your location",
//                       focusColor: Colors.white,
//                       floatingLabelBehavior: FloatingLabelBehavior.never,
//                       focusedBorder: const OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.black)),
//                       border: const OutlineInputBorder(
//                           borderSide: BorderSide(color: Colors.black)),
//                       suffixIcon: IconButton(
//                           onPressed: () {
//                             trucksearchlocation.clear();
//                           },
//                           icon: const Icon(Icons.cancel, color: Colors.black)),
//                       prefixIcon: GestureDetector(
//                           onTap: () {
//                             Navigator.pop(context);
//                           },
//                           child: const Icon(
//                             Icons.arrow_back,
//                             color: Colors.black,
//                           ))),
//                 ),
//               ),
//               preferredSize: const Size.fromHeight(40)),
//         ),
//         body: ListView.builder(
//             shrinkWrap: true,
//             itemCount: currentList.length,
//             itemBuilder: (context, index) {
//               final item = currentList[index];
//               return ListTile(
//                 onTap: () async {
//                   setState(() {
//                     trucksearchlocation.text =
//                         currentList[index]["description"];
//                     String id = item['description'];
//                     // _placeList1.cast();
//                     currentList.clear();
//                     print(id);
//                     saveCurrentCity();
//                   });
//                 },
//                 title: Text(item["description"]),
//               );
//             }));
//   }

//   void saveCurrentCity() {
//     String searchCity = trucksearchlocation.text;
//     saveNamePreference(searchCity).then((bool committed) {
//       Navigator.push(
//           context, MaterialPageRoute(builder: (context) => AddTruck()));
//     });
//   }
// }

// Future<bool> saveNamePreference(String searchCity) async {
//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   preferences.setString('searchCity', searchCity);
//   return preferences.commit();
// }

// Future<String> getsearchCity() async {
//   SharedPreferences preferences = await SharedPreferences.getInstance();
//   String searchCity = preferences.getString('searchCity').toString();
//   return searchCity;
// }

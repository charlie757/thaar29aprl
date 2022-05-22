import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:thaartransport/auth/register.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/widget/indicatiors.dart';
// import 'package:thaartransport/utils/constants.dart';

class UserPreference extends StatefulWidget {
  const UserPreference({Key? key}) : super(key: key);

  @override
  _UserPreferenceState createState() => _UserPreferenceState();
}

class _UserPreferenceState extends State<UserPreference> {
  bool isLoading = false;
  String SelectedValue = '';
  int value = 0;

  String location = 'Press Button';
  String Address = 'search';
  String placeMark = '';
  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
  }

  @override
  void initState() {
    super.initState();

    getLocation();
  }

  getLocation() async {
    Position position = await _getGeoLocationPosition();
    location = 'Lat: ${position.latitude} , Long: ${position.longitude}';
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    print(placemarks);
    Placemark place = placemarks[3];
    Address = '${place.locality}, ${place.country}';
    print(Address);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          height: MediaQuery.of(context).size.height,
          // color: Colors.red,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: ClipPath(
                      clipper: WaveClipper(),
                      child: Container(
                        color: Colors.deepOrangeAccent,
                        height: 200,
                      ),
                    ),
                  ),
                  ClipPath(
                      clipper: WaveClipper(),
                      child: Container(
                        color: Color(0xff183038),
                        alignment: Alignment.center,
                        height: 180,
                        child: Text.rich(TextSpan(
                            text: "I AM ",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                            children: [
                              TextSpan(
                                  text: SelectedValue,
                                  style: TextStyle(
                                      color: SelectedValue == "Transporator"
                                          ? Colors.red
                                          : Colors.green,
                                      fontSize: 25))
                            ])),
                      )),
                ],
              ),
              Spacer(),
              selectUserPreference(),
              const SizedBox(
                height: 150,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 15, right: 15),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    color: isLoading == false
                        ? Color(0XFF142438)
                        : Constants.btninactive,
                    onPressed: () async {
                      await getLocation();
                      if (value == 0) {
                        Fluttertoast.showToast(
                            msg: 'Select your profile type',
                            fontSize: 16,
                            gravity: ToastGravity.CENTER);
                      } else {
                        setState(() {
                          isLoading = true;
                          print(isLoading);
                        });

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UserRegistration(SelectedValue, Address),
                                fullscreenDialog: true));
                        setState(() {
                          isLoading = false;
                          print(isLoading);
                        });
                      }
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8)),
                        height: 48,
                        child: isLoading == false
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("Go",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios_sharp,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                ],
                              )
                            : circularProgress(context)),
                  )),
              const SizedBox(
                height: 10,
              )
            ],
          )),
    );
  }

  Widget selectUserPreference() {
    return Padding(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () {
              setState(() {
                value = 1;
                SelectedValue = "Transporator";
                print(value);
              });
            },
            child: Text("Transporator",
                style: TextStyle(
                    fontSize: 20,
                    color: value == 1 ? Colors.red : Colors.black)),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                value = 2;
                SelectedValue = "Shipper";
                print(value);
              });
            },
            child: Text("Shipper",
                style: TextStyle(
                    fontSize: 20,
                    color: value == 2 ? Colors.green : Colors.black)),
          ),
        ]));
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        dismissDirection: DismissDirection.down,
        content: Text(
          value,
          style: const TextStyle(fontSize: 16),
        )));
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    debugPrint(size.width.toString());
    var path = new Path();
    path.lineTo(0, size.height);
    var firstStart = Offset(size.width / 5, size.height);
    var firstEnd = Offset(size.width / 2.25, size.height - 50);
    path.quadraticBezierTo(
        firstStart.dx, firstStart.dy, firstEnd.dx, firstEnd.dy);

    var secondStart =
        Offset(size.width - (size.width / 3.24), size.height - 105);
    var secondEnd = Offset(size.width, size.height - 10);
    path.quadraticBezierTo(
        secondStart.dx, secondStart.dy, secondEnd.dx, secondEnd.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

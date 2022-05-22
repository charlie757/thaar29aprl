import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:thaartransport/auth/login.dart';
import 'package:thaartransport/auth/profile_pic.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/firebase.dart';

class AuthService {
  String token = "";

  User? getCurrentUser() {
    User? user = firebaseAuth.currentUser;
    return user;
  }

  Future<bool> createUser({
    String? username,
    String? companyname,
    String? location,
  }) async {
    var res = await FirebaseAuth.instance.currentUser!.uid;
    if (res != null) {
      await saveRegistertoFirestore(username, res, companyname, location);
      return true;
    } else {
      return false;
    }
  }

  saveRegistertoFirestore(username, res, companyname, location) {}

//this will save the details inputted by the user to firestore.
  saveUserToFirestore(BuildContext context, String username, String companyName,
      String useremail, String location, String userType) async {
    await usersRef.doc(UserService().currentUid()).set({
      "id": UserService().currentUid(),
      "usernumber": UserService().currentNumber(),
      "creationtime": user!.metadata.creationTime.toString(),
      "location": location,
      "username": username,
      "amount": 0,
      "companyname": companyName.isNotEmpty ? companyName.toString() : 'null',
      "isTruck": false,
      "firebasetoken": token,
      "time": FieldValue.serverTimestamp(),
      "useremail": useremail,
      "usertype": userType,
      "photourl": "",
      'loginstatus': "login",
      "lastsigntime": Timestamp.now().toDate(),
      // "UserKyc": {
      //   'kycname': "",
      //   "selfi": "",
      // },
      "PANKyc": {
        "pannumber": "",
        "panfrontimg": "",
        "panbackimg": "",
      },
      "AadhaarKyc": {
        "aadhaarnumber": "",
        "aadhaarfrontimg": "",
        "aadhaarbackimg": "",
      },
      // "OfficeKyc": {
      //   "businessname": "",
      //   "officeimg1": "",
      //   "officeimg2": "",
      //   "officeimg3": "",
      //   "officeimg4": ""
      // },
      "GstKyc": {
        "businessname": "",
        "gstnumber": "",
        "gstimg1": "",
        "gstimg2": "",
        "gstimg3": "",
      },
      'kycmsg': '',
      "userkycstatus": "Pending",
      "companybio": {"esbmyear": "", "bio": ""}
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => ProfilePicture()));
  }

  saveUserToUpdateFirestore(
    BuildContext context,
  ) async {
    await usersRef.doc(UserService().currentUid()).update({
      "id": UserService().currentUid(),
      "usernumber": UserService().currentNumber(),
      "lastsigntime": Timestamp.now().toDate(),
      'loginstatus': "login",
    });
  }

  logOut(BuildContext context) async {
    await usersRef.doc(UserService().currentUid()).update({
      'loginstatus': "logout",
    });
    await firebaseAuth.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => EnterNumber()),
    );
  }

  Firebasetoken() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    token = (await firebaseMessaging.getToken())!;
    print(token);
    await usersRef
        .doc(UserService().currentUid())
        .update({"firebasetoken": token});
  }
}

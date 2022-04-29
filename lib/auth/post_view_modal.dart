// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thaartransport/NEW/homepage.dart';
import 'package:thaartransport/screens/kyc/kycverfied.dart';
import 'package:thaartransport/services/post_service.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:thaartransport/widget/indicatiors.dart';

import '../utils/constants.dart';

class PostsViewModel extends ChangeNotifier {
  //Services
  UserService userService = UserService();
  PostService postService = PostService();

  //Variables
  bool loading = false;
  File? mediaUrl;
  final picker = ImagePicker();
  File? userDp;
  String? imgLink;
  bool? edit;
  String? id;
  String usertype = '';

  curentUser() async {
    await usersRef.doc(UserService().currentUid()).get().then((value) {
      usertype = value.get('usertype');
      notifyListeners();
    });
  }

  //Setters
  setEdit(bool val) {
    edit = val;
    notifyListeners();
  }

  //Functions
  pickImage({bool camera = false, required BuildContext context}) async {
    loading = true;
    notifyListeners();
    try {
      loading = true;
      notifyListeners();
      PickedFile? pickedFile = await picker.getImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
      );
      File? croppedFile = await ImageCropper().cropImage(
        compressQuality: 50,
        sourcePath: pickedFile!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Constants.lightAccent,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        iosUiSettings: const IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
      );
      mediaUrl = File(croppedFile!.path);

      loading = false;
      notifyListeners();
    } catch (e) {
      loading = false;
      notifyListeners();
      showInSnackBar('Cancelled', context);
    }
  }

  uploadProfilePicture(BuildContext context) async {
    if (mediaUrl == null) {
      showInSnackBar('Please select an image', context);
    } else {
      try {
        loading = true;
        notifyListeners();

        await postService.uploadProfilePicture(
            mediaUrl!, firebaseAuth.currentUser!);
        loading = false;
        usertype == "Transporator"
            ? Navigator.of(context)
                .push(CupertinoPageRoute(builder: (_) => KycVerified()))
            : Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => HomePage()));
        notifyListeners();
      } catch (e) {
        print(e);
        loading = false;
        notifyListeners();
        showInSnackBar('Uploaded successfully!', context);
      }
    }
  }

  // resetPost() {
  //   mediaUrl == null;
  //   description = null;
  //   location = null;
  //   edit = null;
  //   notifyListeners();
  // }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:uuid/uuid.dart';
import 'package:thaartransport/services/services.dart';

import '../utils/firebase.dart';

class PostService extends Service {
  String postId = Uuid().v4();

//uploads profile picture to the users collection
  uploadProfilePicture(File image, User user) async {
    String link = await uploadImage(profilePic, image);
    var ref = usersRef.doc(UserService().currentUid());
    ref.update({"photourl": link, "imageuploadtime": Timestamp.now().toDate()});
  }
}

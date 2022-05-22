import 'package:flutter/material.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/services/services.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/firebase.dart';

class remoteService {
  fetchacceptbid(PostModal posts) async {
    await bidRef
        .where('loadid', isEqualTo: posts.postid)
        .where('loadpostid', isEqualTo: UserService().currentUid())
        .where('bidresponse', isEqualTo: "Bid Accepted")
        .get()
        .then((value) {
      biddoc = value.docs;
      biddoc.forEach((element) {
        print(element['bidresponse']);
        bidaccepted = element['bidresponse'];
      });
    });
  }

  fetchcompletebid(PostModal posts) async {
    await bidRef
        .where('loadid', isEqualTo: posts.postid)
        .where('loadpostid', isEqualTo: UserService().currentUid())
        .where('bidresponse', isEqualTo: "Bid Completed")
        .get()
        .then((value) {
      bidcomdoc = value.docs;
      bidcomdoc.forEach((element) {
        print(element['bidresponse']);
        bidcomplete = element['bidresponse'];
      });
    });
  }

  List biddoc = [];
  String bidaccepted = '';

  List bidcomdoc = [];
  String bidcomplete = '';
}

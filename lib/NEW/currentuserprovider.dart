import 'package:flutter/material.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/services/userservice.dart';
import 'package:thaartransport/utils/firebase.dart';

class CurrentUserProvider extends ChangeNotifier {
  String username = '';
  String kycstatus = '';
  String photourl = '';
  String usertype = '';
  String usernumber = '';

  List bidAceptdocs = [];

  List biddoc = [];
  String bidaccepted = '';
  currentuser() async {
    await usersRef.doc(UserService().currentUid()).get().then((value) {
      username = value.get('username');
      kycstatus = value.get('userkycstatus');
      photourl = value.get('photourl');
      usertype = value.get('usertype');
      usernumber = value.get('usernumber');
      notifyListeners();
    });
  }

  bidaceceptcount() async {
    await bidRef
        .where('truckownerid', isEqualTo: UserService().currentUid())
        .where('bidresponse', isEqualTo: 'Bid Accepted')
        .get()
        .then((value) {
      bidAceptdocs = value.docs;
      notifyListeners();
      // print("bidaceceptcount ${biddocs.length}");
    });
  }

  fetchbid(PostModal posts) async {
    await bidRef
        .where('loadid', isEqualTo: posts.postid)
        .where('loadpostid', isEqualTo: UserService().currentUid())
        .where('bidresponse', isEqualTo: "Bid Accepted")
        .get()
        .then((value) {
      biddoc = value.docs;
      biddoc.forEach((element) {
        bidaccepted = element['bidresponse'];
        notifyListeners();
      });
    });
  }
}

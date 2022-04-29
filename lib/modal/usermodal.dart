// ignore_for_file: unnecessary_this, prefer_collection_literals, unnecessary_new

import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String? id;
  String? usernumber;
  String? creationtime;
  String? location;
  String? username;
  num? amount;
  String? companyname;
  bool? isTruck;
  String? firebasetoken;
  Timestamp? time;
  String? useremail;
  String? usertype;
  String? photourl;
  String? loginstatus;
  bool? isOnline;
  String? userkycstatus;
  CompanyDetails? companybio;
  AadharDocument? AadhaarKyc;
  PANDocument? PANKyc;
  GstDocument? GstKyc;
  UserModel(
      {this.id,
      this.usernumber,
      this.creationtime,
      this.location,
      this.username,
      this.amount,
      this.companyname,
      this.isTruck,
      this.firebasetoken,
      this.time,
      this.useremail,
      this.usertype,
      this.photourl,
      this.loginstatus,
      this.isOnline,
      this.userkycstatus,
      this.companybio,
      this.AadhaarKyc,
      this.PANKyc,
      this.GstKyc});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    usernumber = json['usernumber'] as String;
    creationtime = json['creationtime'] as String;
    location = json['location'] as String;
    username = json['username'] as String;
    amount = json['amount'] as num;
    companyname = json['companyname'] as String;
    isTruck = json['isTruck'] as bool;
    firebasetoken = json['firebasetoken'] as String;
    time = json['time'] as Timestamp;
    useremail = json['useremail'] as String;
    usertype = json['usertype'] as String;
    photourl = json['photourl'] as String;
    loginstatus = json['loginstatus'] as String;
    isOnline = json['isOnline'] as bool;
    userkycstatus = json['userkycstatus'] as String;
    companybio = (json['companybio'] != null
        ? CompanyDetails.fromJson(json['companybio'])
        : null);
    AadhaarKyc = (json['AadhaarKyc'] != null
        ? AadharDocument.fromJson(json['AadhaarKyc'])
        : null);
    PANKyc =
        (json['PANKyc'] != null ? PANDocument.fromJson(json['PANKyc']) : null);
    GstKyc =
        (json['GstKyc'] != null ? GstDocument.fromJson(json['GstKyc']) : null);
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['id'] = this.id;
    data['usernumber'] = this.usernumber;
    data['creationtime'] = this.creationtime;
    data['location'] = this.location;
    data['username'] = this.username;
    data['amount'] = this.amount;
    data['companyname'] = this.companyname;
    data['isTruck'] = this.isTruck;
    data['firebasetoken'] = this.firebasetoken;
    data['time'] = this.time;
    data['useremail'] = this.useremail;
    data['usertype'] = this.usertype;
    data['photourl'] = this.photourl;
    data['loginstatus'] = this.loginstatus;
    data['isOnline'] = this.isOnline;
    data['userkycstatus'] = this.userkycstatus;
    if (this.companybio != null) {
      data['companybio'] = this.companybio!.toJson();
    }
    if (this.AadhaarKyc != null) {
      data['AadhaarKyc'] = this.AadhaarKyc!.toJson();
    }
    if (this.PANKyc != null) {
      data['PANKyc'] = this.PANKyc!.toJson();
    }
    if (this.GstKyc != null) {
      data['GstKyc'] = this.GstKyc!.toJson();
    }
    return data;
  }
}

class CompanyDetails {
  String? bio;
  String? esbmyear;

  CompanyDetails({required this.bio, required this.esbmyear});

  CompanyDetails.fromJson(Map<String, dynamic> json) {
    bio = json['bio'];
    esbmyear = json['esbmyear'];
  }
  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['bio'] = this.bio;
    data['esbmyear'] = this.esbmyear;

    return data;
  }
}

class GstDocument {
  String? businessname;
  String? gstnumber;
  String? gstimg1;
  String? gstimg2;
  String? gstimg3;

  GstDocument(
      {required this.businessname,
      required this.gstnumber,
      required this.gstimg1,
      required this.gstimg2,
      required this.gstimg3});

  GstDocument.fromJson(Map<String, dynamic> json) {
    businessname = json['businessname'];
    gstnumber = json['gstnumber'];
    gstimg1 = json['gstimg1'];
    gstimg2 = json['gstimg2'];
    gstimg3 = json['gstimg3'];
  }
  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['businessname'] = this.businessname;
    data['gstnumber'] = this.gstnumber;
    data['gstimg1'] = this.gstimg1;
    data['gstimg2'] = this.gstimg2;
    data['gstimg3'] = this.gstimg3;
    return data;
  }
}

class PANDocument {
  String? pannumber;
  String? panfrontimg;
  String? panbackimg;

  PANDocument({
    required this.pannumber,
    required this.panfrontimg,
    required this.panbackimg,
  });

  PANDocument.fromJson(Map<String, dynamic> json) {
    pannumber = json['pannumber'];
    panfrontimg = json['panfrontimg'];
    panbackimg = json['panbackimg'];
  }
  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['pannumber'] = this.pannumber;
    data['panfrontimg'] = this.panfrontimg;
    data['panbackimg'] = this.panbackimg;
    return data;
  }
}

class AadharDocument {
  String? aadhaarnumber;
  String? aadhaarfrontimg;
  String? aadhaarbackimg;

  AadharDocument({
    required this.aadhaarnumber,
    required this.aadhaarfrontimg,
    required this.aadhaarbackimg,
  });

  AadharDocument.fromJson(Map<String, dynamic> json) {
    aadhaarnumber = json['aadhaarnumber'];
    aadhaarfrontimg = json['aadhaarfrontimg'];
    aadhaarbackimg = json['aadhaarbackimg'];
  }
  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['aadhaarnumber'] = this.aadhaarnumber;
    data['aadhaarfrontimg'] = this.aadhaarfrontimg;
    data['aadhaarbackimg'] = this.aadhaarbackimg;
    return data;
  }
}

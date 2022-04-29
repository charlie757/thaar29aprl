import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModal {
  String? rate;
  String? remarks;
  Timestamp? bidtime;
  String? biduserid;
  String? bidresponse;
  String? negotiateprice;
  String? img;
  String? type;
  String? completeremarks;
  ChatModal(
      {this.rate,
      this.remarks,
      this.bidtime,
      this.biduserid,
      this.bidresponse,
      this.negotiateprice,
      this.img,
      this.type,
      this.completeremarks
      // this.message,
      });

  ChatModal.fromJson(Map<String, dynamic> json) {
    rate = json['rate'];
    remarks = json['remarks'];
    bidtime = json['bidtime'];
    biduserid = json['biduserid'];
    bidresponse = json['bidresponse'];
    negotiateprice = json['negotiateprice'];
    img = json['img'];
    type = json['type'];
    completeremarks = json['completeremarks'];
    // message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['rate'] = rate;
    data['remarks'] = remarks;
    data['bidtime'] = bidtime;
    data['biduserid'] = biduserid;
    data['bidresponse'] = bidresponse;
    data['negotiateprice'] = negotiateprice;
    data['img'] = img;
    data['type'] = type;
    data['completeremarks'] = completeremarks;
    // data['message'] = message;
    return data;
  }
}

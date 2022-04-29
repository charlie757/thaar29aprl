// ignore_for_file: unnecessary_this, prefer_collection_literals, unnecessary_new

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class BidModal {
  String? bidresponse;
  String? bidtime;
  String? biduserid;
  String? rate;
  String? id;
  String? loadid;
  String? remarks;
  String? btnvalue;
  String? negotiateprice;
  String? paymentstatus;
  String? paymentid;
  bool? loaderimage;
  String? truckid;
  String? truckposttime;
  String? truckownerid;
  BidModal(
      {required this.bidresponse,
      required this.bidtime,
      required this.biduserid,
      required this.rate,
      required this.btnvalue,
      required this.negotiateprice,
      required this.loadid,
      required this.id,
      required this.remarks,
      required this.paymentstatus,
      required this.paymentid,
      required this.loaderimage,
      this.truckid,
      this.truckposttime,
      this.truckownerid});

  BidModal.fromJson(Map<String, dynamic> json) {
    bidresponse = json['bidresponse'];
    bidtime = json['bidtime'];
    biduserid = json['biduserid'];
    rate = json['rate'];
    loadid = json['loadid'];
    btnvalue = json['btnvalue'];
    negotiateprice = json['negotiateprice'];
    id = json['id'];
    remarks = json['remarks'];
    paymentstatus = json['paymentstatus'];
    paymentid = json['paymentid'];
    loaderimage = json['loaderimage'];
    truckid = json['truckid'];
    truckposttime = json['truckposttime'];
    truckownerid = json['truckownerid'];
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['bidresponse'] = bidresponse;
    data['bidtime'] = bidtime;
    data['biduserid'] = biduserid;
    data['remakrs'] = remarks;
    data['negotiateprice'] = negotiateprice;
    data['btnvalue'] = btnvalue;
    data['loadid'] = loadid;
    data['rate'] = rate;
    data['id'] = id;
    data['paymentstatus'] = paymentstatus;
    data['paymentid'] = paymentid;
    data['loaderimage'] = loaderimage;
    data['truckid'] = truckid;
    data['truckposttime'] = truckposttime;
    data['truckownerid'] = truckownerid;
    return data;
  }
}

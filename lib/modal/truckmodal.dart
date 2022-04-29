// ignore_for_file: unnecessary_this, prefer_collection_literals, unnecessary_new

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class TruckModal {
  String? id;
  // String? truckpostid;
  String? ownerId;
  // String? dp;
  String? lorrynumber;
  String? sourcelocation;
  String? destinationlocation;
  String? expiretruck;
  String? capacity;
  String? usernumber;
  // String? frontimage;
  // String? backimage;
  // String? truckloadstatus;
  String? truckposttime;
  String? truckstatus;
  List? routes;
  Timestamp? time;

  TruckModal(
      {this.id,
      this.ownerId,
      this.lorrynumber,
      this.sourcelocation,
      this.destinationlocation,
      this.expiretruck,
      this.capacity,
      this.usernumber,
      this.truckposttime,
      this.truckstatus,
      this.routes,
      this.time});

  TruckModal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ownerId = json['ownerId'];
    lorrynumber = json['lorrynumber'];
    sourcelocation = json['sourcelocation'];
    destinationlocation = json['destinationlocation'];
    expiretruck = json['expiretruck'];
    capacity = json['capacity'];
    usernumber = json['usernumber'];
    truckposttime = json['truckposttime'];
    truckstatus = json['truckstatus'];
    routes = json['routes'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['id'] = id;
    data['ownerId'] = ownerId;
    data['lorrynumber'] = lorrynumber;
    data['sourcelocation'] = sourcelocation;
    data['destinationlocation'] = destinationlocation;
    data['expiretruck'] = expiretruck;
    data['capacity'] = capacity;
    data['usernumber'] = usernumber;
    data['truckposttime'] = truckposttime;
    data['truckstatus'] = truckstatus;
    data['routes'] = routes;
    data['time'] = time;
    return data;
  }
}

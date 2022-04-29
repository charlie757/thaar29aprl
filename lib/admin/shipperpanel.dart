import 'package:flutter/material.dart';
import 'package:thaartransport/admin/shipper.dart';
import 'package:thaartransport/utils/firebase.dart';

class ShipperPanel extends StatefulWidget {
  const ShipperPanel({Key? key}) : super(key: key);

  @override
  State<ShipperPanel> createState() => _ShipperPanelState();
}

class _ShipperPanelState extends State<ShipperPanel> {
  shipperUsers() async {
    await usersRef.where('usertype', isEqualTo: "Shipper").get().then((value) {
      userdocs = value.docs;
      userdocs.forEach((e) {
        setState(() {
          // createTime = e['creationtime'];
          // loginTime = e['lastsigntime'];
        });
      });
    });
  }

  List userdocs = [];
  DateTime? createTime;
  DateTime? loginTime;

  @override
  void initState() {
    shipperUsers();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                    dividerThickness: 2,
                    border: TableBorder.all(),
                    headingTextStyle: TextStyle(color: Colors.red),
                    columns: const [
                      DataColumn(
                          label: Text(
                        "ID",
                      )),
                      DataColumn(label: Text("UserType")),
                      DataColumn(label: Text("Name")),
                      DataColumn(label: Text("Number")),
                      DataColumn(label: Text("Email")),
                      DataColumn(label: Text("Location")),
                      DataColumn(label: Text("Amount")),
                      DataColumn(label: Text("CreationTime")),
                      DataColumn(label: Text("LoginTime")),
                      DataColumn(label: Text("LoginStaus")),
                      DataColumn(label: Text("Photo")),
                    ],
                    rows: userdocs
                        .map((e) => DataRow(
                                onLongPress: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Shipper(e['username'], e['id'])));
                                },
                                cells: [
                                  DataCell(Text(e['id'])),
                                  DataCell(Text(e['usertype'])),
                                  DataCell(Text(e['username'])),
                                  DataCell(Text(e['usernumber'])),
                                  DataCell(Text(e['useremail'])),
                                  DataCell(Text(e['location'])),
                                  DataCell(Text(e['amount'].toString())),
                                  DataCell(Text(createTime.toString())),
                                  DataCell(Text(loginTime.toString())),
                                  DataCell(Text(
                                    e['loginstatus'],
                                    style: TextStyle(
                                        color: e['loginstatus'] == "login"
                                            ? Colors.green
                                            : Colors.red),
                                  )),
                                  DataCell(Image.network(
                                    e['photourl'],
                                    fit: BoxFit.cover,
                                    height: 50,
                                    width: 50,
                                  )),
                                ]))
                        .toList()),
              )
            ],
          ),
        ),
      ),
    );
  }
}

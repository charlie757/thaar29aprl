import 'package:flutter/material.dart';
import 'package:thaartransport/admin/trucks.dart';
import 'package:thaartransport/utils/firebase.dart';

class TransportPanel extends StatefulWidget {
  TransportPanel({Key? key}) : super(key: key);

  @override
  State<TransportPanel> createState() => _TransportPanelState();
}

class _TransportPanelState extends State<TransportPanel> {
  transportUsers() async {
    await usersRef
        .where('usertype', isEqualTo: "Transporator")
        .get()
        .then((value) {
      userdocs = value.docs;
      userdocs.forEach((e) {
        setState(() {
          // createTime = e['creationtime'];
          // loginTime = e['lastsigntime'];
          print(createTime);
        });
      });
    });
  }

  List userdocs = [];
  DateTime? createTime;
  DateTime? loginTime;

  @override
  void initState() {
    super.initState();
    transportUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                    dividerThickness: 2,
                    border: TableBorder.all(),
                    headingTextStyle: const TextStyle(color: Colors.red),
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
                                          builder: (context) => Trucks(
                                              e['id']!.toString(),
                                              e['username']!.toString(),
                                              e['userkycstatus']!.toString())));
                                },
                                cells: [
                                  DataCell(Text(e['id'].toString())),
                                  DataCell(Text(e['usertype'].toString())),
                                  DataCell(Text(e['username'].toString())),
                                  DataCell(Text(e['usernumber'].toString())),
                                  DataCell(Text(e['useremail'].toString())),
                                  DataCell(Text(e['location'].toString())),
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

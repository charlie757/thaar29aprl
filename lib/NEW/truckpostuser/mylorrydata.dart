import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:thaartransport/addtruck/repostlorry.dart';
import 'package:thaartransport/modal/truckmodal.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';

class Mylorrydata extends StatefulWidget {
  TruckModal truckModal;
  Mylorrydata(this.truckModal);

  @override
  State<Mylorrydata> createState() => _MylorrydataState();
}

class _MylorrydataState extends State<Mylorrydata> with WidgetsBindingObserver {
  int differenceinmin = 0;
  int checkdifference = 0;
  int differenceinsec = 0;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    WidgetsBinding.instance!.removeObserver(this);
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state);
    if (state == AppLifecycleState.paused) {
      Future.delayed(Duration(minutes: 1)).then((value) {
        postRef.doc(widget.truckModal.id).update({'loadstatus': 'Expired'});
        print("sccess");
      });
    } else if (state == AppLifecycleState.inactive) {
      Future.delayed(Duration(minutes: 1)).then((value) {
        postRef.doc(widget.truckModal.id).update({'loadstatus': 'Expired'});
        print("sccess");
      });
    } else if (state == AppLifecycleState.resumed) {
      Future.delayed(Duration(minutes: 1)).then((value) {
        postRef.doc(widget.truckModal.id).update({'loadstatus': 'Active'});
        print("sccess");
      });
    } else if (state == AppLifecycleState.detached) {
      Future.delayed(Duration(minutes: 1)).then((value) {
        postRef.doc(widget.truckModal.id).update({'loadstatus': 'Active'});
        print("sccess");
      });
    }
  }

  timerFunction() {
    final currenttime = DateTime.now();
    final backenddatehours =
        DateTime.parse(widget.truckModal.expiretruck.toString());
    final differencehours = backenddatehours.difference(currenttime).inHours;
    checkdifference = differencehours >= 1 ? differencehours : 1;

    differenceinmin = backenddatehours.difference(currenttime).inMinutes;
    final checkdifferenceinmin =
        differenceinmin >= 60 ? checkdifference : differenceinmin;

    differenceinsec = backenddatehours.difference(currenttime).inSeconds;
    final checkdifferenceinsec = differenceinsec >= 1
        ? differenceinmin
        : differenceinsec <= 1
            ? 0
            : differenceinsec;

    checkdifferenceinsec == 1 ||
            checkdifferenceinsec <= 1 ||
            checkdifferenceinsec == 0
        ? truckRef.doc(widget.truckModal.id).update({'truckstatus': 'Expired'})
        : null;

    print("expiretime ${widget.truckModal.expiretruck}");
    print("checkdifferenceinsec $checkdifferenceinsec");
    print("checkdifference $checkdifference");
  }

  @override
  Widget build(BuildContext context) {
    timerFunction();
    return Column(
      children: [
        Card(
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text(
                        widget.truckModal.truckstatus.toString(),
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: widget.truckModal.truckstatus == "ACTIVE"
                                ? Constants.cursorColor
                                : Constants.alert),
                      )),
                  widget.truckModal.truckstatus == 'ACTIVE'
                      ? PopupMenuButton(
                          icon: const Icon(
                            Icons.more_vert,
                          ),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 1,
                                enabled: true,
                                child: Text(
                                  "Remove from market",
                                )),
                          ],
                          onSelected: (menu) {
                            if (menu == 1) {
                              truckRef.doc(widget.truckModal.id).update({
                                'truckstatus': "EXPIRED",
                              });
                            }
                          },
                        )
                      : Container()
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  leading: const Icon(
                    LineIcons.truck,
                    color: Colors.red,
                  ),
                  title: Text(
                    widget.truckModal.lorrynumber.toString(),
                    style: const TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                  subtitle: Text(
                      "posted on ${widget.truckModal.truckposttime.toString().split(',')[1] + widget.truckModal.truckposttime.toString().split(',')[2]}"),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Colors.green),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      widget.truckModal.sourcelocation.toString(),
                      style: TextStyle(fontSize: 15),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 10, color: Colors.red),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      widget.truckModal.destinationlocation.toString(),
                      style: const TextStyle(fontSize: 15),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Truck Capacity",
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "${widget.truckModal.capacity} tonne",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    Container(
                        height: 30,
                        child: const VerticalDivider(color: Colors.black)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Already Loaded",
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "${widget.truckModal.alcapacity} tonne",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                    Container(
                        height: 30,
                        child: const VerticalDivider(color: Colors.black)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Left Capacity",
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Text(
                          "${widget.truckModal.leftcapacity} tonne",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 15, color: Colors.black26),
                            const SizedBox(
                              width: 15,
                            ),
                            Text(
                              "${widget.truckModal.routes!.length} routes",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        widget.truckModal.truckstatus == "ACTIVE"
                            ? Text.rich(TextSpan(
                                text: "Expire After:  ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w400, fontSize: 16),
                                children: [
                                  TextSpan(
                                      text: differenceinmin >= 60
                                          ? checkdifference.toString()
                                          : differenceinsec >= 1
                                              ? differenceinmin.toString()
                                              : differenceinsec.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17,
                                          color: differenceinmin >= 60
                                              ? Colors.green.shade900
                                              : differenceinsec >= 1
                                                  ? Colors.orange
                                                  : Colors.orange),
                                      children: [
                                        TextSpan(
                                            text: differenceinmin >= 60
                                                ? " Hours"
                                                : differenceinsec >= 1
                                                    ? " Min"
                                                    : " Sec",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 15,
                                                color: differenceinmin >= 60
                                                    ? Colors.green.shade900
                                                    : differenceinsec >= 1
                                                        ? Colors.orange
                                                        : Colors.orange))
                                      ]),
                                ],
                              ))
                            : Container()
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 20,
              ),
              InkWell(
                  onTap: () {
                    widget.truckModal.truckstatus == "ACTIVE"
                        ? null
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RepostLorry(
                                    widget.truckModal,
                                    widget.truckModal.routes!.length)));
                    ;
                  },
                  child: Container(
                    height: 40,
                    color: const Color(0xffe8e8f0),
                    // width: 150,
                    alignment: Alignment.center,
                    child: Text(
                      widget.truckModal.truckstatus == "ACTIVE"
                          ? "Active Truck"
                          : "Reactive Truck",
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(
          height: 15,
        )
      ],
    );
  }
}

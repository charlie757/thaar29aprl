// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:thaartransport/NEW/postloaduser/bidresponse/bidresponse.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/addnewload/updateload.dart';
import 'package:thaartransport/utils/constants.dart';

class OrderData extends StatefulWidget {
  PostModal posts;
  OrderData({required this.posts});
  @override
  _OrderDataState createState() => _OrderDataState();
}

class _OrderDataState extends State<OrderData> {
  bool validate = false;
  bool loading = false;
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return LoadPosted(
        widget.posts.material!,
        widget.posts.quantity!,
        widget.posts.paymentmode!,
        widget.posts.expectedprice!,
        widget.posts.priceunit!);
  }

  Widget LoadPosted(String material, String quantity, String PaymentMode,
      String expectedPrice, String priceUnit) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 1,
            child: Container(
              height: 200,
              width: width,
              padding: const EdgeInsets.only(
                left: 15,
                right: 15,
                top: 5,
              ),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                      // onTap: () => showModalBottomSheet(
                      //     context: context, builder: (context) => buildSheet()),
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.posts.loadstatus == "Active"
                          ? Container(
                              child: Row(
                                children: [
                                  LottieBuilder.asset(
                                    'assets/79827-circle-fade-loader.json',
                                    height: 30,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(
                                    width: width * 0.02,
                                  ),
                                  Text(
                                    "Load Posted",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Constants.cursorColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          : widget.posts.loadstatus == "Expired"
                              ? Container(
                                  child: Row(
                                    children: [
                                      LottieBuilder.asset(
                                        'assets/79827-circle-fade-loader.json',
                                        height: 30,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(
                                        width: width * 0.02,
                                      ),
                                      const Text(
                                        "Load Expired",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                )
                              : widget.posts.loadstatus == "InTransit"
                                  ? Container(
                                      child: Row(
                                        children: [
                                          LottieBuilder.asset(
                                            'assets/79827-circle-fade-loader.json',
                                            height: 30,
                                            fit: BoxFit.cover,
                                          ),
                                          SizedBox(
                                            width: width * 0.02,
                                          ),
                                          const Text(
                                            "In Transit",
                                            style: TextStyle(
                                                color: Colors.purple,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(
                                      child: Row(
                                        children: [
                                          LottieBuilder.asset(
                                            'assets/79827-circle-fade-loader.json',
                                            height: 30,
                                            fit: BoxFit.cover,
                                          ),
                                          SizedBox(
                                            width: width * 0.02,
                                          ),
                                          const Text(
                                            "Load Completed",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    )
                    ],
                  )),
                  const Divider(
                    color: Colors.black,
                  ),
                  Container(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/product.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(
                                      width: width * 0.02,
                                    ),
                                    Text("Material: $material"),
                                  ],
                                ),
                                SizedBox(
                                  height: height * 0.01,
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/quantity.png',
                                      width: 20,
                                      height: 20,
                                    ),
                                    SizedBox(
                                      width: width * 0.02,
                                    ),
                                    Text("Quantity: $quantity Tons"),
                                  ],
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  expectedPrice,
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  priceUnit,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/payment.png',
                              width: 20,
                              height: 20,
                            ),
                            SizedBox(
                              width: width * 0.02,
                            ),
                            Text('Payment Mode: $PaymentMode'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: height * 0.02,
          ),
          widget.posts.loadstatus == "Expired" ? repostButton() : Container(),
          tabBar()
        ],
      ),
    );
  }

  Widget repostButton() {
    return FlatButton(
        color: Colors.grey,
        textColor: Colors.white,
        onPressed: () {
          widget.posts.loadorderstatus == "InTransit" ||
                  widget.posts.loadorderstatus == "Completed"
              ? Alert(
                  context: context,
                  title: "In-Transit",
                  desc: "Your load is In-Transit.",
                  buttons: [
                      DialogButton(
                          color: Color(0XFF142438),
                          child: Text(
                            "Ok",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          })
                    ]).show()
              : Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => UpdateLoad(
                            posts: widget.posts,
                          )));
        },
        child: Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.refresh),
              SizedBox(
                width: 5,
              ),
              Text("Repost Load")
            ],
          ),
        ));
  }

  Widget WhatsAppButton() {
    return RaisedButton(
      color: Colors.green,
      onPressed: () {},
      child: Container(
          height: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.share,
                size: 17,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Share on WhatsApp",
                style: TextStyle(color: Colors.white, fontSize: 17),
              )
            ],
          )),
    );
  }

  Widget tabBar() {
    return DefaultTabController(
        length: 1,
        child: Container(
          child: Column(
            children: [
              TabBar(
                  indicatorColor: Constants.thaartheme,
                  indicatorWeight: 1,
                  tabs: const [
                    Tab(
                      child: Text(
                        'BID RESPONSE',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ]),
              const SizedBox(
                height: 15,
              ),
              Container(
                height: 500,
                child: TabBarView(children: [
                  BidResponse(
                    posts: widget.posts,
                  ),
                  // Text("data")
                ]),
              )
            ],
          ),
        ));
  }
}

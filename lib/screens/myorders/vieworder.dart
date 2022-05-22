import 'package:blinking_text/blinking_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thaartransport/addnewload/postmodal.dart';
import 'package:thaartransport/modal/bidmodal.dart';
import 'package:thaartransport/modal/usermodal.dart';
import 'package:thaartransport/utils/constants.dart';
import 'package:thaartransport/utils/firebase.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewOrder extends StatefulWidget {
  UserModel users;
  PostModal posts;
  BidModal bidpost;
  ViewOrder(this.users, this.posts, this.bidpost);

  @override
  State<ViewOrder> createState() => _ViewOrderState();
}

class _ViewOrderState extends State<ViewOrder> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.white,
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
          titleSpacing: 0,
          title: ListTile(
            contentPadding: const EdgeInsets.all(0),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.users.photourl.toString()),
            ),
            title: Text(
              widget.users.username.toString(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              widget.posts.loadposttime!.split(',')[1] +
                  widget.posts.loadposttime!.split(',')[2],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          actions: [
            FlatButton.icon(
                onPressed: () {
                  widget.bidpost.bidresponse == "Bid Accepted"
                      ? callNow()
                      : widget.bidpost.bidresponse == "Bid Completed"
                          ? callNow()
                          : null;
                },
                icon: Icon(Icons.call,
                    color: widget.bidpost.bidresponse == "Bid Accepted"
                        ? Colors.black
                        : widget.bidpost.bidresponse == "Bid Completed"
                            ? Colors.black
                            : Colors.black12),
                label: Text(
                  "Call Now",
                  style: TextStyle(
                      color: widget.bidpost.bidresponse == "Bid Accepted"
                          ? Colors.black
                          : widget.bidpost.bidresponse == "Bid Completed"
                              ? Colors.black
                              : Colors.black12),
                ))
          ],
        ),
        body: secondUI());
  }

  Widget secondUI() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Card(
      elevation: 8,
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "posted on:",
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(
                width: 2,
              ),
              Text(widget.posts.loadposttime!.split(',')[1] +
                  widget.posts.loadposttime!.split(',')[2]),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    widget.posts.sourcelocation!,
                    style: GoogleFonts.lato(fontSize: 16),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Divider(),
          Row(
            children: [
              Expanded(
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/product.png',
                      height: 20,
                      width: 20,
                    ),
                    SizedBox(
                      width: width * 0.05,
                    ),
                    Text(
                      widget.posts.material!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/quantity.png',
                      height: 20,
                      width: 20,
                    ),
                    SizedBox(
                      width: width * 0.05,
                    ),
                    Text(
                      "${widget.posts.quantity} Tons",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              )
            ],
          ),
          Divider(),
          SizedBox(
            height: height * 0.01,
          ),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Original Amount:", style: TextStyle(fontSize: 15)),
              const SizedBox(
                width: 10,
              ),
              Row(
                children: [
                  Image.asset(
                    'assets/images/rupee-indian.png',
                    height: 18,
                    width: 18,
                  ),
                  Text(widget.posts.expectedprice!,
                      style: GoogleFonts.lato(fontSize: 20)),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                      widget.posts.priceunit == 'tonne'
                          ? "per ${widget.posts.priceunit}"
                          : widget.posts.priceunit!,
                      style: const TextStyle(fontSize: 17)),
                ],
              ),
            ],
          ),
          SizedBox(
            height: height * 0.01,
          ),
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Bidding Amount:", style: TextStyle(fontSize: 15)),
              const SizedBox(
                width: 10,
              ),
              Row(
                children: [
                  Image.asset(
                    'assets/images/rupee-indian.png',
                    height: 18,
                    width: 18,
                  ),
                  Text(widget.posts.expectedprice!,
                      style: GoogleFonts.lato(fontSize: 20)),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                      widget.posts.priceunit == 'tonne'
                          ? "per ${widget.posts.priceunit}"
                          : widget.posts.priceunit!,
                      style: const TextStyle(fontSize: 17)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget firstui() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Card(
      elevation: 4,
      child: Container(
        // height: 20,
        padding: const EdgeInsets.only(left: 8, right: 10),
        child: Column(
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.circle,
                  color: Colors.green,
                  size: 15,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  widget.posts.sourcelocation!,
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const Icon(
                  Icons.circle,
                  color: Colors.red,
                  size: 15,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  widget.posts.destinationlocation!,
                  style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Image.asset(
                  'assets/images/product.png',
                  height: 20,
                  width: 20,
                ),
                SizedBox(
                  width: width * 0.05,
                ),
                Text(
                  widget.posts.material!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Image.asset(
                  'assets/images/quantity.png',
                  height: 20,
                  width: 20,
                ),
                SizedBox(
                  width: width * 0.05,
                ),
                Text(
                  "${widget.posts.quantity} Tons",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
            SizedBox(
              height: height * 0.01,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Original Amount",
                        style: TextStyle(fontSize: 17)),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/rupee-indian.png',
                          height: 18,
                          width: 18,
                        ),
                        Text(widget.posts.expectedprice!,
                            style: GoogleFonts.lato(fontSize: 20)),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                            widget.posts.priceunit == 'tonne'
                                ? "per ${widget.posts.priceunit}"
                                : widget.posts.priceunit!,
                            style: const TextStyle(fontSize: 17)),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Bidding Amount",
                        style: TextStyle(fontSize: 17)),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/rupee-indian.png',
                          height: 18,
                          width: 18,
                        ),
                        Text(widget.posts.expectedprice!,
                            style: GoogleFonts.lato(fontSize: 20)),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                            widget.posts.priceunit == 'tonne'
                                ? "per ${widget.posts.priceunit}"
                                : widget.posts.priceunit!,
                            style: const TextStyle(fontSize: 17)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(onPressed: () async {}, child: Text("Submit"))
          ],
        ),
      ),
    );
  }

  callNow() async {
    // launch('tel://$user.usernumber!');
    await FlutterPhoneDirectCaller.callNumber(widget.users.usernumber!);
  }
}

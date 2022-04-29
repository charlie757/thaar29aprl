import 'package:flutter/material.dart';

class FullImage extends StatefulWidget {
  String img;
  FullImage(this.img);

  @override
  State<FullImage> createState() => _FullImageState();
}

class _FullImageState extends State<FullImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Image.network(
          widget.img,
          fit: BoxFit.fill,
        ),
      ),
    );
  }
}

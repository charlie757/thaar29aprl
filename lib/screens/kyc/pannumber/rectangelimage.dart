import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:dotted_decoration/dotted_decoration.dart';

class RectangelImage extends StatelessWidget {
  final ImageProvider provider;
  final double height;
  final double width;

  RectangelImage(this.provider, {required this.height, required this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(
          color: Color(0XFF142438),
        )),
        child: Image(
          fit: BoxFit.fill,
          image: provider,
          height: height,
          width: width,
        ));
  }

// eompp4711k
  factory RectangelImage.url(String url,
      {required double height, required double width}) {
    return RectangelImage(NetworkImage(url), height: height, width: width);
  }

  factory RectangelImage.memory(Uint8List data,
      {required double height, required double width}) {
    return RectangelImage(MemoryImage(data), height: height, width: width);
  }
}

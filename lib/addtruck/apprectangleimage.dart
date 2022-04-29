import 'dart:typed_data';

import 'package:flutter/material.dart';

class AppRectangelImage extends StatelessWidget {
  final ImageProvider provider;
  final double height;
  final double width;

  AppRectangelImage(this.provider, {required this.height, required this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Image(
      image: provider,
      height: height,
      width: width,
    ));
  }

  factory AppRectangelImage.url(String url,
      {required double height, required double width}) {
    return AppRectangelImage(NetworkImage(url), height: height, width: width);
  }

  factory AppRectangelImage.memory(Uint8List data,
      {required double height, required double width}) {
    return AppRectangelImage(MemoryImage(data), height: height, width: width);
  }
}

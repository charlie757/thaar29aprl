// ignore: file_names
// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:thaartransport/screens/mainsceen/modal.dart';

class SlideItem extends StatelessWidget {
  final int index;
  SlideItem(this.index);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            image: DecorationImage(
              image: AssetImage(slideList[index].imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Text(
          slideList[index].title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            color: Colors.black,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          slideList[index].description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

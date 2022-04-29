import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class FlickerWidget extends StatelessWidget {
  FlickerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade100,
      highlightColor: Colors.grey.shade300,
      child: Container(
        height: 200,
        child: const Card(
          elevation: 8,
        ),
      ),
    );
  }
}

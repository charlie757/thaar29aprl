import 'package:flutter/material.dart';

class NewLoad extends StatefulWidget {
  const NewLoad({Key? key}) : super(key: key);

  @override
  State<NewLoad> createState() => _NewLoadState();
}

class _NewLoadState extends State<NewLoad> {
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller4 = TextEditingController();
  TextEditingController controller5 = TextEditingController();
  TextEditingController controller6 = TextEditingController();
  TextEditingController controller7 = TextEditingController();
  TextEditingController controller8 = TextEditingController();
  TextEditingController controller9 = TextEditingController();
  TextEditingController controller10 = TextEditingController();
  TextEditingController controller11 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.only(left: 15, top: 10, right: 15),
        child: Column(
          children: [
            TextFormField(
              controller: controller1,
            ),
            TextFormField(
              controller: controller1,
            ),
            TextFormField(
              controller: controller1,
            ),
            TextFormField(
              controller: controller1,
            ),
            TextFormField(
              controller: controller1,
            ),
            TextFormField(
              controller: controller1,
            ),
            TextFormField(
              controller: controller1,
            ),
            TextFormField(
              controller: controller1,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thaartransport/utils/constants.dart';

class inputTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String lblText;
  bool readonly;
  final TextInputType inputType;
  Function() onTap;
  List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  inputTextField(this.controller, this.hintText, this.lblText, this.readonly,
      this.inputType, this.inputFormatters, this.onTap, this.validator);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: inputType,
        readOnly: readonly,
        inputFormatters: inputFormatters,
        cursorColor: Constants.cursorColor,
        onTap: onTap,
        decoration: InputDecoration(
            labelText: lblText,
            isDense: true,
            contentPadding: EdgeInsets.all(15),
            hintText: hintText,
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
              color: Constants.textfieldborder,
            )),
            border: OutlineInputBorder(
                borderSide:
                    BorderSide(width: 1, color: Constants.textfieldborder))),
        validator: validator);
  }
}

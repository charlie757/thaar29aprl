import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thaartransport/utils/constants.dart';

class textField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String lblText;
  bool readonly;
  TextCapitalization textCapitalization;
  final TextInputType inputType;
  Function() onTap;
  List<TextInputFormatter>? inputFormatters;

  ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  textField(
      this.controller,
      this.hintText,
      this.lblText,
      this.readonly,
      this.textCapitalization,
      this.inputType,
      this.inputFormatters,
      this.onTap,
      this.onChanged,
      this.validator);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: inputType,
        textCapitalization: textCapitalization,
        readOnly: readonly,
        inputFormatters: inputFormatters,
        cursorColor: Constants.cursorColor,
        onTap: onTap,
        onChanged: onChanged,
        decoration: InputDecoration(
            labelText: lblText,
            isDense: true,
            labelStyle: const TextStyle(color: Colors.black),
            contentPadding: const EdgeInsets.all(15),
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black),
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

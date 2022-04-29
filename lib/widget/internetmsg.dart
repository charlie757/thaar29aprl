import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget internetchecker() {
  return Center(
    child: Text(
      "Please check your internet connection",
      style: GoogleFonts.openSans(fontSize: 17, fontWeight: FontWeight.bold),
    ),
  );
}

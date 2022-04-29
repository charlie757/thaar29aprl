// ignore: file_names
// ignore_for_file: file_names
import 'package:flutter/material.dart';

class Slide {
  final String imageUrl;
  final String title;
  final String description;

  Slide({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

final slideList = [
  Slide(
    imageUrl: 'assets/images/truck_1.png',
    title: 'Live Transport Market',
    description:
        'Book Trucks, Trailers , Containers & Tankers from Live market and find best deals.',
  ),
  Slide(
    imageUrl: 'assets/images/truck_2.png',
    title: 'Book loads',
    description:
        'Are you transporator or truck owner and looking for loads??\n Go with this app, book loads with the best price.',
  ),
  Slide(
    imageUrl: 'assets/images/truck_3.png',
    title: 'Best Negotiate price',
    description:
        'Negotiate with the truck owner before confirming your order and book the truck for your load',
  ),
];

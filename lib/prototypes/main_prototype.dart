import 'package:flutter/material.dart';
import 'book_grid_prototype.dart';

void main() {
  runApp(const BookGridPrototypeApp());
}

class BookGridPrototypeApp extends StatelessWidget {
  const BookGridPrototypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Grid Prototype',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: const BookGridPrototypePage(),
    );
  }
}

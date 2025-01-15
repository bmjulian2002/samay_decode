import 'package:flutter/material.dart';
import 'package:samay_decode/main_decode/main_decode_injection.dart';
import 'package:samay_decode/utils/samay_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: SamayColors.blue),
        useMaterial3: true,
      ),
      home: MainDecodeInjection.injection(),
    );
  }
}

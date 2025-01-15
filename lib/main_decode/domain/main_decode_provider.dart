import 'package:flutter/material.dart';

class MainDecodeProvider with ChangeNotifier {
  final ValueNotifier<TextEditingController> decodeController =
      ValueNotifier<TextEditingController>(TextEditingController());

  final ValueNotifier<List<String>> decodedResults =
      ValueNotifier<List<String>>([]);

  List<String> decodeNumber(String number) {
    List<String> results = [];
    void decodeHelper(String current, String remaining) {
      if (remaining.isEmpty) {
        results.add(current);
        return;
      }
      for (int i = 1; i <= 2; i++) {
        if (remaining.length >= i) {
          String part = remaining.substring(0, i);
          int value = int.tryParse(part) ?? 0;
          if (value >= 1 && value <= 26) {
            decodeHelper(current + String.fromCharCode(value + 64),
                remaining.substring(i));
          }
        }
      }
    }

    decodeHelper('', number);
    return results;
  }
}

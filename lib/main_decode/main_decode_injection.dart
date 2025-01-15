import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samay_decode/main_decode/domain/main_decode_provider.dart';
import 'package:samay_decode/main_decode/interface/main_decode_screen.dart';

class MainDecodeInjection {
  MainDecodeInjection._();

  static Widget injection() {
    return ListenableProvider(
      create: (context) => MainDecodeProvider(),
      child: MainDecodeScreen(),
    );
  }
}

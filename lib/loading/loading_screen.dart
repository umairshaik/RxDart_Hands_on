import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rxdart_hands_on/loading/loading_screen_controller.dart';

@immutable
class LoadingScreen {
  const LoadingScreen._sharedInstance();

  static final LoadingScreen _shared = LoadingScreen._sharedInstance();

  factory LoadingScreen.instance() => _shared;

  LoadingScreenController? controller;

  LoadingScreenController _showOverlay({
    required BuildContext context,
    required String text,
  }) {
    final _text = StreamController<String>();
    _text.add(text);

    final state = Over
  }
}

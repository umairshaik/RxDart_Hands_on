import 'dart:developer' as dev_tools show log;

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

void main() {
  runApp(
    const App(),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    testIt();
    return Scaffold(
        appBar: AppBar(
      title: const Text('Hello World'),
    ));
  }
}

void testIt() async {
  final stream1 = Stream.periodic(
    const Duration(seconds: 1),
    (int count) => 'Stream 1 and Count is $count',
  ).take(3);
  final stream2 = Stream.periodic(
    const Duration(seconds: 3),
    (int count) => 'Stream 2 and Count is $count',
  );

  final results = Rx.zip2(
    stream1,
    stream2,
    (a, b) => 'Stream1 is producing $a while Stream2 is producing $b',
  );

  await for (final value in results) {
    value.log();
  }
}

extension Log on Object {
  void log() => dev_tools.log(toString());
}

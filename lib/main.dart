import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

//Reading from file and get data as Stream
Stream<String> getNames({required String filePath}) {
  final names = rootBundle.loadString(filePath);
  return Stream.fromFuture(names).transform(const LineSplitter());
}

Stream<String> getAllNames() =>
    getNames(filePath: 'assets/texts/cats.txt').concatWith([
      getNames(filePath: 'assets/texts/dogs.txt'),
    ]);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Combine latest with RxDart'),
      ),
      body: FutureBuilder(
          future: getAllNames().toList(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
                return const Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                final List<String> names = snapshot.requireData;
                return ListView.separated(
                    itemBuilder: (context, position) {
                      return ListTile(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(names[position]),
                          ));
                        },
                        title: Text(names[position]),
                      );
                    },
                    separatorBuilder: (_, __) {
                      return const Divider(
                        color: Colors.black,
                      );
                    },
                    itemCount: names.length);
            }
          }),
    );
  }
}

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Bloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = Bloc();
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          TextField(
              decoration:
                  const InputDecoration(hintText: 'Enter first name here....'),
              onChanged: (String data) {
                _bloc.setFirstName.add(data);
              }),
          TextField(
              decoration:
                  const InputDecoration(hintText: 'Enter last name here....'),
              onChanged: (String data) {
                _bloc.setLastName.add(data);
              }),
          AsyncSnapshotBuilder(
            stream: _bloc.fullName,
            onActive: (context, String? value) {
              return Text(value ?? '');
            },
          )
        ]),
      ),
    );
  }
}

typedef AsyncSnapshotBuilderCallBack<T> = Widget Function(
    BuildContext context, T? value);

class AsyncSnapshotBuilder<T> extends StatelessWidget {
  final Stream<T> stream;
  final AsyncSnapshotBuilderCallBack<T>? onNone;
  final AsyncSnapshotBuilderCallBack<T>? onWaiting;
  final AsyncSnapshotBuilderCallBack<T>? onActive;
  final AsyncSnapshotBuilderCallBack<T>? onDone;

  const AsyncSnapshotBuilder(
      {super.key,
      required this.stream,
      this.onNone,
      this.onWaiting,
      this.onActive,
      this.onDone});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: this.stream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              final Widget Function(BuildContext context, T? value) callBack =
                  onNone ?? (_, __) => const SizedBox();
              return callBack(context, snapshot.data);
            case ConnectionState.waiting:
              final Widget Function(BuildContext context, T? value) callBack =
                  onWaiting ?? (_, __) => const CircularProgressIndicator();
              return callBack(context, snapshot.data);
            case ConnectionState.active:
              final Widget Function(BuildContext context, T? value) callBack =
                  onActive ?? (_, __) => const SizedBox();
              return callBack(context, snapshot.data);
            case ConnectionState.done:
              final Widget Function(BuildContext context, T? value) callBack =
                  onDone ?? (_, __) => const SizedBox();
              return callBack(context, snapshot.data);
          }
        });
  }
}

@immutable
class Bloc {
  final Sink<String?> setFirstName;
  final Sink<String?> setLastName;
  final Stream<String> fullName;

  const Bloc._({
    required this.setFirstName,
    required this.setLastName,
    required this.fullName,
  });

  factory Bloc() {
    final firstNameSubject = BehaviorSubject<String?>();
    final lastNameSubject = BehaviorSubject<String?>();
    final Stream<String> streamFullName = Rx.combineLatest2(
      firstNameSubject.startWith(null),
      lastNameSubject.startWith(null),
      (String? firstName, String? lastName) {
        if (firstName != null &&
            firstName.isNotEmpty &&
            lastName != null &&
            lastName.isNotEmpty) {
          return '$firstName $lastName';
        } else {
          return 'Provide first name and last name';
        }
      },
    );
    return Bloc._(
        setFirstName: firstNameSubject.sink,
        setLastName: lastNameSubject.sink,
        fullName: streamFullName);
  }

  void dispose() {
    setFirstName.close();
    setLastName.close();
  }
}

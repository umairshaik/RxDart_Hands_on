import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

enum TypeOfThings {
  animal,
  person,
}

@immutable
class Thing {
  final TypeOfThings type;
  final String name;

  const Thing({required this.type, required this.name});
}

@immutable
class Bloc {
  final Sink<TypeOfThings?> setTypeOfThings;
  final Stream<TypeOfThings?> currentTypeOfThings;
  final Stream<Iterable<Thing>> things;

  const Bloc._({
    required this.setTypeOfThings,
    required this.currentTypeOfThings,
    required this.things,
  });

  void dispose() {
    setTypeOfThings.close();
  }

  factory Bloc({required List<Thing> things}) {
    final typeOfThingSubject = BehaviorSubject<TypeOfThings?>();
    final filteredThings = typeOfThingSubject
        .debounceTime(const Duration(milliseconds: 300))
        .map<List<Thing>>((typeOfThing) {
      if (typeOfThing != null) {
        return things.where((element) => element.type == typeOfThing).toList();
      } else {
        return things;
      }
    }).startWith(things);
    return Bloc._(
      setTypeOfThings: typeOfThingSubject.sink,
      currentTypeOfThings: typeOfThingSubject.stream,
      things: filteredThings,
    );
  }
}

const List<Thing> things = [
  Thing(type: TypeOfThings.person, name: 'Foo'),
  Thing(type: TypeOfThings.person, name: 'Bar'),
  Thing(type: TypeOfThings.person, name: 'Baz'),
  Thing(type: TypeOfThings.animal, name: 'Bunz'),
  Thing(type: TypeOfThings.animal, name: 'Fluffers'),
  Thing(type: TypeOfThings.animal, name: 'Woofz'),
];

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
    _bloc = Bloc(things: things);
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello World'),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: _bloc.currentTypeOfThings,
            builder: (context, snapshot) {
              final TypeOfThings? selectedTypeOfThing = snapshot.data;
              return Wrap(
                children: TypeOfThings.values.map((typeOfThings) {
                  return FilterChip(
                    selectedColor: Colors.blueAccent[100],
                    label: Text(typeOfThings.name),
                    onSelected: (selected) {
                      final TypeOfThings? type = selected ? typeOfThings : null;
                      _bloc.setTypeOfThings.add(type);
                    },
                    selected: selectedTypeOfThing == typeOfThings,
                  );
                }).toList(),
              );
            },
          ),
          Expanded(
            child: StreamBuilder(
              stream: _bloc.things,
              builder: (context, snapshot) {
                final data = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final thing = data.elementAt(index);
                    return ListTile(
                      title: Text(thing.name),
                      subtitle: Text(thing.type.name),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

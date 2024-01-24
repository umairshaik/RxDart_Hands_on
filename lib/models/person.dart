import 'package:flutter/foundation.dart' show immutable;
import 'package:rxdart_hands_on/models/thing.dart';

@immutable
class Person extends Thing {
  final int age;

  const Person({required super.name, required this.age});

  @override
  String toString() => 'Person, name: $name, age: $age';

  Person.fromJson(Map<String, dynamic> json)
      : this(age: json["age"], name: json["name"]);
}

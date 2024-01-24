import 'dart:convert';
import 'dart:io';

import 'package:rxdart_hands_on/models/animal.dart';

import '../models/person.dart';
import '../models/thing.dart';

typedef SearchTerm = String;

class Api {
  List<Animal> _animals = [];
  List<Person> _persons = [];

  Future<List<Thing>> search(SearchTerm searchTerm) async {
    final term = searchTerm.trim().toLowerCase();

    // search in the cache
    final cachedResults = _extractThingsUsingSearchTerm(term);
    if (cachedResults.isNotEmpty) {
      return cachedResults;
    }

    // we don't have the values cached, let's call APIs

    // start by calling persons api
    final persons = await _getJson('http://localhost:3000/apis/persons.json')
        .then((json) => json.map((value) => Person.fromJson(value)));
    _persons = persons.toList();

    // start by calling persons api
    final animals = await _getJson('http://localhost:3000/apis/animals.json')
        .then((json) => json.map((value) => Animal.fromJson(value)));
    _animals = animals.toList();

    return _extractThingsUsingSearchTerm(term);
  }

  List<Thing> _extractThingsUsingSearchTerm(SearchTerm term) {
    final cachedAnimals = _animals;
    final cachedPersons = _persons;
    List<Thing> result = [];
    if (cachedAnimals.isNotEmpty && cachedPersons.isNotEmpty) {
      // go through animals
      for (final animal in cachedAnimals) {
        if (animal.name.trimmedContains(term) ||
            animal.type.name.trimmedContains(term)) {
          result.add(animal);
        }
      }
      // go through persons
      for (final person in cachedPersons) {
        if (person.name.trimmedContains(term) ||
            person.age.toString().trimmedContains(term)) {
          result.add(person);
        }
      }
    }
    return result;
  }

  Future<List<dynamic>> _getJson(String url) => HttpClient()
      .getUrl(Uri.parse(url))
      .then((req) => req.close())
      .then((response) => response.transform(utf8.decoder).join())
      .then((jsonString) => json.decode(jsonString));
}

extension TrimmedCaseInsensitiveContain on String {
  bool trimmedContains(String other) => trim().toLowerCase().contains(
        other.trim().toLowerCase(),
      );
}

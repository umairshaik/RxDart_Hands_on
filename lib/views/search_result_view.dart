import 'package:flutter/material.dart';

import '../bloc/search_result.dart';
import '../models/animal.dart';
import '../models/person.dart';

class SearchResultView extends StatelessWidget {
  final Stream<SearchResult> searchResult;

  const SearchResultView({super.key, required this.searchResult});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SearchResult?>(
      stream: searchResult,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final result = snapshot.data;
          switch (result) {
            case SearchResultHasError():
              return Text('Got error ${result.error}');
            case SearchResultLoading():
              return const CircularProgressIndicator();
            case SearchResultNoResult():
              return const Text(
                'No results found for your search term. Try with another one!',
              );
            case SearchResultWithResults():
              final results = result.results;
              return Expanded(
                child: ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final item = results[index];
                    final String title;
                    if (item is Animal) {
                      title = 'Animal';
                    } else if (item is Person) {
                      title = 'Person';
                    } else {
                      title = 'Unknown';
                    }
                    return ListTile(
                      title: Text(title),
                      subtitle: Text(
                        item.toString(),
                      ),
                    );
                  },
                ),
              );
            default:
              return const Text('Unknown state!');
          }
        } else {
          return const Text('Waiting');
        }
      },
    );
  }
}

import 'package:flutter/foundation.dart' show immutable;
import 'package:rxdart/rxdart.dart';
import 'package:rxdart_hands_on/bloc/search_result.dart';
import 'package:rxdart_hands_on/models/thing.dart';

import 'api.dart';

@immutable
class SearchBloc {
  final Sink<String> search;
  final Stream<SearchResult> results;

  void dispose() {
    search.close();
  }

  factory SearchBloc({required Api api}) {
    final textChanges = BehaviorSubject<String>();

    final results = textChanges
        .distinct()
        .debounceTime(const Duration(seconds: 1))
        .switchMap<SearchResult>((String searchTerm) {
      if (searchTerm.isEmpty) {
        // search is empty
        return Stream<SearchResult>.value(const SearchResultNoResult());
      } else {
        return Rx.fromCallable(() => api.search(searchTerm))
            .delay(const Duration(seconds: 1))
            .map(
              (List<Thing> results) => results.isEmpty
                  ? const SearchResultNoResult()
                  : SearchResultWithResults(results),
            )
            .startWith(const SearchResultLoading())
            .onErrorReturnWith((error, stackTrace) =>
                SearchResultHasError('$error$stackTrace'));
      }
    });

    return SearchBloc._(
      search: textChanges.sink,
      results: results,
    );
  }

  const SearchBloc._({
    required this.search,
    required this.results,
  });
}

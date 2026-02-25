import 'package:hive/hive.dart';

part 'search_history.g.dart';

@HiveType(typeId: 3)
class SearchHistory extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String query;
  
  @HiveField(2)
  final DateTime timestamp;
  
  @HiveField(3)
  final int resultCount;

  SearchHistory({
    required this.id,
    required this.query,
    required this.timestamp,
    required this.resultCount,
  });

  SearchHistory copyWith({
    String? id,
    String? query,
    DateTime? timestamp,
    int? resultCount,
  }) {
    return SearchHistory(
      id: id ?? this.id,
      query: query ?? this.query,
      timestamp: timestamp ?? this.timestamp,
      resultCount: resultCount ?? this.resultCount,
    );
  }

  @override
  String toString() {
    return 'SearchHistory(id: $id, query: $query, timestamp: $timestamp, resultCount: $resultCount)';
  }
}

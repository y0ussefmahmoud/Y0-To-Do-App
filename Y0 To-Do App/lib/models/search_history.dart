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

  /// Convert SearchHistory to JSON for backup
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'query': query,
      'timestamp': timestamp.toIso8601String(),
      'resultCount': resultCount,
    };
  }

  /// Create SearchHistory from JSON for restore
  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    return SearchHistory(
      id: json['id'] as String,
      query: json['query'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      resultCount: json['resultCount'] as int,
    );
  }
}

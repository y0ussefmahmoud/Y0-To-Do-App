import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/search_history.dart';
import '../models/task.dart';
import '../models/task_category.dart';
import '../services/ai_service.dart';
import 'ai_provider.dart';
import 'task_provider.dart';

class SearchState {
  final String query;
  final bool isSearching;
  final List<SearchHistory> searchHistory;
  final List<String> suggestions;
  final List<Task> searchResults;

  SearchState({
    this.query = '',
    this.isSearching = false,
    this.searchHistory = const [],
    this.suggestions = const [],
    this.searchResults = const [],
  });

  SearchState copyWith({
    String? query,
    bool? isSearching,
    List<SearchHistory>? searchHistory,
    List<String>? suggestions,
    List<Task>? searchResults,
  }) {
    return SearchState(
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      searchHistory: searchHistory ?? this.searchHistory,
      suggestions: suggestions ?? this.suggestions,
      searchResults: searchResults ?? this.searchResults,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Box<SearchHistory>? _historyBox;
  final AIService _aiService;
  Timer? _debounceTimer;

  SearchNotifier(this._historyBox, this._aiService) : super(SearchState()) {
    if (_historyBox != null) {
      _loadSearchHistory();
    }
  }

  void _loadSearchHistory() {
    if (_historyBox == null) return;
    
    final history = _historyBox.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = state.copyWith(searchHistory: history);
  }

  void updateQuery(String query, [List<Task>? allTasks]) {
    state = state.copyWith(query: query);
    
    // Debounce search while typing
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (query.isNotEmpty && allTasks != null) {
        performSearch(query, allTasks);
      } else if (query.isNotEmpty) {
        state = state.copyWith(isSearching: true);
      }
    });
  }

  Future<void> performSearch(String query, List<Task> allTasks) async {
    if (query.trim().isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(isSearching: true);

    try {
      // Filter tasks based on query
      final filteredTasks = allTasks.where((task) {
        final searchLower = query.toLowerCase();
        return task.title.toLowerCase().contains(searchLower) ||
               (task.note?.toLowerCase().contains(searchLower) ?? false) ||
               task.safeCategory.displayName.toLowerCase().contains(searchLower);
      }).toList();

      // Rank results using AI service
      final rankedResults = await _aiService.rankSearchResults(filteredTasks, query);

      // Save to history
      if (_historyBox != null) {
        final historyItem = SearchHistory(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          query: query,
          timestamp: DateTime.now(),
          resultCount: rankedResults.length,
        );

        await _historyBox.put(historyItem.id, historyItem);
        
        // Keep only last 20 searches
        final allHistory = _historyBox.values.toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        if (allHistory.length > 20) {
          for (int i = 20; i < allHistory.length; i++) {
            await allHistory[i].delete();
          }
        }

        _loadSearchHistory();
      }

      state = state.copyWith(
        searchResults: rankedResults,
        isSearching: false,
      );
    } catch (e) {
      state = state.copyWith(isSearching: false);
    }
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    state = state.copyWith(
      query: '',
      isSearching: false,
      searchResults: [],
    );
  }

  Future<void> deleteHistoryItem(String id) async {
    if (_historyBox != null) {
      await _historyBox.delete(id);
      _loadSearchHistory();
    }
  }

  Future<void> clearAllHistory() async {
    if (_historyBox != null) {
      await _historyBox.clear();
      state = state.copyWith(searchHistory: []);
    }
  }

  Future<void> loadSmartSuggestions(List<Task> tasks) async {
    try {
      final suggestions = await _aiService.generateSearchSuggestions(tasks);
      state = state.copyWith(suggestions: suggestions);
    } catch (e) {
      // If AI fails, provide basic suggestions
      state = state.copyWith(suggestions: [
        'مهام اليوم',
        'مهام متأخرة',
        'مهام عالية الأولوية',
        'مهام الغد',
        'مهام هذا الأسبوع',
      ]);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// Providers
final searchHistoryBoxProvider = FutureProvider<Box<SearchHistory>>((ref) async {
  return await Hive.openBox<SearchHistory>('searchHistoryBox');
});

final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  final historyBoxAsync = ref.watch(searchHistoryBoxProvider);
  final aiService = ref.watch(aiServiceProvider);
  
  return historyBoxAsync.when(
    data: (historyBox) => SearchNotifier(historyBox, aiService),
    loading: () => SearchNotifier(null, aiService), // Pass null for historyBox during loading
    error: (error, stack) => throw error,
  );
});

final searchResultsProvider = Provider<List<Task>>((ref) {
  final searchState = ref.watch(searchProvider);
  final filteredTasks = ref.watch(filteredTasksProvider);
  
  if (searchState.query.isNotEmpty) {
    return searchState.searchResults;
  }
  
  return filteredTasks;
});

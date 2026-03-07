import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_history.dart';
import '../providers/search_provider.dart';
import '../providers/task_provider.dart';
import '../services/speech_service.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({super.key});

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  late AnimationController _suggestionAnimationController;
  late Animation<double> _suggestionAnimation;

  @override
  void initState() {
    super.initState();
    _suggestionAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _suggestionAnimation = CurvedAnimation(
      parent: _suggestionAnimationController,
      curve: Curves.easeInOut,
    );

    _focusNode.addListener(() {
      setState(() {
        _showSuggestions = _focusNode.hasFocus;
      });
      if (_focusNode.hasFocus) {
        _suggestionAnimationController.forward();
      } else {
        _suggestionAnimationController.reverse();
      }
    });

    // Load smart suggestions when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tasks = ref.read(tasksProvider);
      ref.read(searchProvider.notifier).loadSmartSuggestions(tasks);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _suggestionAnimationController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _searchController.text = query;
    final tasks = ref.read(tasksProvider);
    ref.read(searchProvider.notifier).updateQuery(query, tasks);
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;
    
    final tasks = ref.read(tasksProvider);
    ref.read(searchProvider.notifier).performSearch(query, tasks);
    _focusNode.unfocus();
  }

  void _onClearSearch() {
    _searchController.clear();
    ref.read(searchProvider.notifier).clearSearch();
    _focusNode.unfocus();
  }

  void _onVoiceSearch() async {
    final speechService = SpeechService();
    
    try {
      await speechService.startListening(
        onResult: (text) {
          final command = speechService.processVoiceCommand(text);
          if (command.type == VoiceCommandType.search) {
            final query = command.data['query'] as String;
            _onSearchChanged(query);
            _onSearchSubmitted(query);
          } else {
            // If it's not a search command, treat it as regular search
            if (mounted) {
              _onSearchChanged(text);
              _onSearchSubmitted(text);
            }
          }
        },
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ في التعرف على الصوت: $error'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في بدء تسجيل الصوت: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSuggestionTap(String suggestion) {
    _onSearchChanged(suggestion);
    _onSearchSubmitted(suggestion);
  }

  void _onHistoryItemTap(SearchHistory historyItem) {
    _onSearchChanged(historyItem.query);
    _onSearchSubmitted(historyItem.query);
  }

  Future<void> _onDeleteHistoryItem(String id) async {
    await ref.read(searchProvider.notifier).deleteHistoryItem(id);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);
    
    return Column(
      children: [
        // Search Bar Container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.surface.withValues(alpha: 0.9),
                theme.colorScheme.surface,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Search Icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  Icons.search,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ).animate(target: searchState.isSearching ? 1 : 0).rotate(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                ),
              ),
              
              // Text Field
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'ابحث عن مهام...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: _onSearchChanged,
                  onSubmitted: _onSearchSubmitted,
                ),
              ),
              
              // Voice Search Button
              if (searchState.query.isEmpty)
                IconButton(
                  onPressed: _onVoiceSearch,
                  icon: Icon(
                    Icons.mic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ).animate().scale(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                ).then().shake(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                ),
              
              // Clear Button
              if (searchState.query.isNotEmpty)
                IconButton(
                  onPressed: _onClearSearch,
                  icon: Icon(
                    Icons.clear,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ).animate().scale(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                ),
            ],
          ),
        ).animate().slideY(
          duration: const Duration(milliseconds: 300),
          begin: -0.2,
          curve: Curves.easeOut,
        ).fadeIn(
          duration: const Duration(milliseconds: 300),
        ),
        
        // Suggestions Dropdown
        if (_showSuggestions && (searchState.searchHistory.isNotEmpty || searchState.suggestions.isNotEmpty))
          SizeTransition(
            sizeFactor: _suggestionAnimation,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search History Section
                  if (searchState.searchHistory.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            size: 16,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'البحث الأخير',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...searchState.searchHistory.take(5).map((historyItem) => 
                      _buildHistoryItem(historyItem),
                    ),
                  ],
                  
                  // AI Suggestions Section
                  if (searchState.suggestions.isNotEmpty) ...[
                    if (searchState.searchHistory.isNotEmpty)
                      Divider(
                        height: 1,
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            size: 16,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'اقتراحات ذكية',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...searchState.suggestions.map((suggestion) => 
                      _buildSuggestionItem(suggestion),
                    ),
                  ],
                ],
              ),
            ),
          ).animate().fadeIn(
            duration: const Duration(milliseconds: 200),
          ),
      ],
    );
  }

  Widget _buildHistoryItem(SearchHistory historyItem) {
    final theme = Theme.of(context);
    
    return Dismissible(
      key: Key(historyItem.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) => _onDeleteHistoryItem(historyItem.id),
      child: InkWell(
        onTap: () => _onHistoryItemTap(historyItem),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                Icons.history,
                size: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      historyItem.query,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      '${historyItem.resultCount} نتيجة',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatRelativeTime(historyItem.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(String suggestion) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _onSuggestionTap(suggestion),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      return 'منذ ${difference.inMinutes} د';
    } else if (difference.inDays < 1) {
      return 'منذ ${difference.inHours} س';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

import 'dart:math';
import '../models/task.dart';
import '../models/task_category.dart';

/// خدمة الذكاء الاصطناعي (AI Service)
/// 
/// توفر وظائف NLP (Natural Language Processing) لتحليل المهام:
/// - استخراج الأولوية من النص
/// - استخراج التاريخ من النص
/// - تقدير مدة المهمة
/// - اقتراح الفئة
/// - توليد اقتراحات ذكية
/// - تحليل الإنتاجية
/// 
/// يستخدم Singleton Pattern لضمان instance واحد فقط
class AIService {
  static final AIService _instance = AIService._internal();
  
  /// Factory constructor يرجع نفس الـ instance
  factory AIService() => _instance;
  
  /// Private constructor لل Singleton
  AIService._internal();

  /// Cache للاقتراحات الذكية
  /// المفتاح: ساعة الحالية (0-23)
  /// القيمة: قائمة الاقتراحات
  final Map<String, List<String>> _suggestionsCache = {};
  
  /// وقت آخر تحديث للـ Cache
  DateTime? _lastCacheTime;
  
  /// مدة صلاحية الـ Cache (ساعة واحدة)
  static const _cacheDuration = Duration(hours: 1);

  /// تحليل نص المهمة باستخدام NLP
  /// 
  /// [text] نص المهمة المراد تحليله
  /// 
  /// Returns: [TaskAnalysis] يحتوي على:
  /// - الأولوية (0-2)
  /// - تاريخ الاستحقاق
  /// - المدة المقدرة (بالدقائق)
  /// - الفئة المقترحة
  /// 
  /// مثال:
  /// ```dart
  /// final analysis = AIService().analyzeTaskText('اجتماع مهم غداً');
  /// print('الأولوية: ${analysis.priority}'); // 2 (عالية)
  /// ```
  TaskAnalysis analyzeTaskText(String text) {
    final analysis = TaskAnalysis();
    final lowerText = text.toLowerCase();
    
    // استخراج الأولوية
    analysis.priority = _extractPriority(lowerText);
    
    // استخراج التاريخ
    analysis.dueDate = _extractDate(lowerText);
    
    // تقدير الوقت المطلوب
    analysis.estimatedDuration = _estimateDuration(lowerText);
    
    // اقتراح الفئة
    analysis.suggestedCategory = _suggestCategory(lowerText);
    
    return analysis;
  }

  /// استخراج الأولوية من النص
  ///
  /// يبحث عن كلمات مفتاحية تدل على الأولوية
  ///
  /// [text] النص بأحرف صغيرة
  /// Returns: 0 (منخفضة), 1 (متوسطة), 2 (عالية)
  int _extractPriority(String text) {
    // كلمات عربية وإنجليزية للأولوية العالية
    final urgentWords = [
      'عاجل', 'مهم جداً', 'مهم جدا', 'مهم', 'ضروري', 'فوري', 'أسرع',
      'بسرعة', 'اسرع', 'حتمي', 'لا يتأخر',
      'urgent', 'important', 'critical', 'asap', 'immediately',
      'must', 'deadline', 'priority',
    ];
    // كلمات للأولوية المتوسطة
    final mediumWords = [
      'متوسط', 'عادي', 'اجتماع', 'meeting', 'مراجعة', 'review',
      'medium', 'normal', 'soon',
    ];
    // كلمات للأولوية المنخفضة
    final lowWords = [
      'بسيط', 'سهل', 'لاحقاً', 'لاحقا', 'مش مهم',
      'low', 'simple', 'easy', 'later', 'whenever',
    ];

    for (final word in urgentWords) {
      if (text.contains(word)) return 2;
    }

    for (final word in mediumWords) {
      if (text.contains(word)) return 1;
    }

    for (final word in lowWords) {
      if (text.contains(word)) return 0;
    }

    // تحليل طول النص
    if (text.length > 50) return 1;

    return 0; // Default low priority
  }

  /// استخراج الوقت من النص
  ///
  /// يتعرف على تعبيرات الوقت العربية والإنجليزية مثل:
  /// - "at 5pm", "at 3:30pm", "at 14:00"
  /// - "الساعة 5 مساءً", "الساعة 9:30 صباحاً"
  ///
  /// [text] النص بأحرف صغيرة
  /// Returns: Record يحتوي على hour و minute، أو null إذا لم يتم التعرف
  ({int hour, int minute})? _extractTime(String text) {
    // الأنماط الإنجليزية: "at 5pm", "at 5:30pm", "at 5 pm"
    final enTime12 = RegExp(
      r'at\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)',
      caseSensitive: false,
    );
    final en12Match = enTime12.firstMatch(text);
    if (en12Match != null) {
      int hour = int.parse(en12Match.group(1)!);
      final minute = int.tryParse(en12Match.group(2) ?? '0') ?? 0;
      final period = en12Match.group(3)!.toLowerCase();
      if (period == 'pm' && hour < 12) hour += 12;
      if (period == 'am' && hour == 12) hour = 0;
      return (hour: hour, minute: minute);
    }

    // 24h: "at 14:30", "at 9:00"
    final en24 = RegExp(r'at\s+(\d{1,2}):(\d{2})');
    final en24Match = en24.firstMatch(text);
    if (en24Match != null) {
      final hour = int.parse(en24Match.group(1)!);
      final minute = int.parse(en24Match.group(2)!);
      if (hour < 24 && minute < 60) return (hour: hour, minute: minute);
    }

    // الأنماط العربية: "الساعة 5 مساءً", "الساعة 9:30 صباحاً"
    final arTime = RegExp(
      r'الساعة\s+(\d{1,2})(?::(\d{2}))?\s*(مساءً|مساء|صباحاً|صباح|ليلاً|ليل|ظهراً|ظهر)?',
    );
    final arMatch = arTime.firstMatch(text);
    if (arMatch != null) {
      int hour = int.parse(arMatch.group(1)!);
      final minute = int.tryParse(arMatch.group(2) ?? '0') ?? 0;
      final period = arMatch.group(3) ?? '';
      if ((period.contains('مساء') || period.contains('ليل')) && hour < 12) {
        hour += 12;
      }
      if (period.contains('ظهر') && hour < 12) hour = 12;
      if (hour < 24 && minute < 60) return (hour: hour, minute: minute);
    }

    return null;
  }

  /// استخراج التاريخ (والوقت إن ذُكر) من النص
  ///
  /// يتعرف على كلمات مثل: غداً، بعد غد، الأسبوع القادم
  /// وأيضاً يتعرف على التواريخ بصيغة DD/MM
  /// ويدمج الوقت المستخرج تلقائياً في DateTime المُرجعة
  ///
  /// [text] النص بأحرف صغيرة
  /// Returns: DateTime إذا تم التعرف على تاريخ، null إذا لم يتم
  DateTime? _extractDate(String text) {
    final now = DateTime.now();
    DateTime? date;

    // كلمات التاريخ العربية والإنجليزية
    if (text.contains('غداً') || text.contains('غدا') || text.contains('tomorrow')) {
      date = now.add(const Duration(days: 1));
    } else if (text.contains('بعد غد') || text.contains('day after tomorrow')) {
      date = now.add(const Duration(days: 2));
    } else if (text.contains('الأسبوع القادم') || text.contains('next week')) {
      date = now.add(const Duration(days: 7));
    } else if (text.contains('الشهر القادم') || text.contains('next month')) {
      date = DateTime(now.year, now.month + 1, now.day);
    } else if (text.contains('اليوم') || text.contains('today')) {
      date = now;
    } else {
      // البحث عن أرقام التواريخ DD/MM أو DD-MM
      final dateRegex = RegExp(r'(\d{1,2})[\/\-](\d{1,2})');
      final match = dateRegex.firstMatch(text);
      if (match != null) {
        final day = int.parse(match.group(1)!);
        final month = int.parse(match.group(2)!);
        date = DateTime(now.year, month, day);
      }
    }

    if (date == null) return null;

    // دمج الوقت المستخرج إن وُجد
    final time = _extractTime(text);
    if (time != null) {
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }

    return DateTime(date.year, date.month, date.day);
  }

  /// تقدير مدة المهمة بالدقائق
  /// 
  /// يعتمد على كلمات مفتاحية وطول النص
  /// 
  /// [text] النص بأحرف صغيرة
  /// Returns: المدة المقدرة بالدقائق (15-240)
  int _estimateDuration(String text) {
    // كلمات تدل على مدة قصيرة (دقائق)
    final quickWords = ['سريع', 'بسيط', 'quick', 'simple', 'call', 'مكالمة'];
    // كلمات تدل على مدة متوسطة (ساعات)
    final mediumWords = ['اجتماع', 'meeting', 'مراجعة', 'review', 'تقرير', 'report'];
    // كلمات تدل على مدة طويلة (أيام)
    final longWords = ['مشروع', 'project', 'تطوير', 'development', 'دراسة', 'study'];
    
    for (String word in quickWords) {
      if (text.contains(word)) return 15; // 15 minutes
    }
    
    for (String word in mediumWords) {
      if (text.contains(word)) return 60; // 1 hour
    }
    
    for (String word in longWords) {
      if (text.contains(word)) return 240; // 4 hours
    }
    
    // تقدير بناءً على طول النص
    if (text.length < 20) return 15;
    if (text.length < 50) return 30;
    return 60;
  }

  /// اقتراح فئة للمهمة
  /// 
  /// يبحث عن كلمات مفتاحية لتحديد الفئة
  /// 
  /// [text] النص بأحرف صغيرة
  /// Returns: الفئة (work, personal, study, health, general)
  String _suggestCategory(String text) {
    final workWords = ['عمل', 'مكتب', 'اجتماع', 'مشروع', 'تقرير', 'work', 'office', 'meeting', 'project', 'report'];
    final personalWords = ['شخصي', 'منزل', 'عائلة', 'تسوق', 'personal', 'home', 'family', 'shopping'];
    final studyWords = ['دراسة', 'تعلم', 'كتاب', 'قراءة', 'امتحان', 'study', 'learn', 'book', 'reading', 'exam'];
    final healthWords = ['رياضة', 'طبيب', 'صحة', 'تمرين', 'جيم', 'sport', 'doctor', 'health', 'exercise', 'gym'];
    
    for (String word in workWords) {
      if (text.contains(word)) return 'work';
    }
    
    for (String word in personalWords) {
      if (text.contains(word)) return 'personal';
    }
    
    for (String word in studyWords) {
      if (text.contains(word)) return 'study';
    }
    
    for (String word in healthWords) {
      if (text.contains(word)) return 'health';
    }
    
    return 'general';
  }

  /// توليد اقتراحات ذكية للمهام
  /// 
  /// يعتمد على الوقت الحالي واليوم لتوليد اقتراحات مناسبة
  /// يستخدم Cache لتحسين الأداء وتقليل الحسابات المتكررة
  /// 
  /// [recentTasks] قائمة بالمهام الأخيرة (غير مستخدمة حالياً)
  /// Returns: قائمة بأفضل 3 اقتراحات
  /// 
  /// مثال:
  /// ```dart
  /// final suggestions = AIService().getSmartSuggestions([]);
  /// // في الصباح: ['مراجعة الإيميلات', 'تحضير خطة اليوم', ...]
  /// ```
  List<String> getSmartSuggestions(List<String> recentTasks) {
    final now = DateTime.now();
    final cacheKey = '${now.hour}';
    
    // التحقق من وجود Cache صالح
    if (_isCacheValid() && _suggestionsCache.containsKey(cacheKey)) {
      return _suggestionsCache[cacheKey]!;
    }
    
    // توليد اقتراحات جديدة
    final suggestions = _generateSuggestions(now);
    
    // حفظ في الـ Cache
    _suggestionsCache[cacheKey] = suggestions;
    _lastCacheTime = now;
    
    return suggestions;
  }

  /// توليد الاقتراحات الفعلية
  /// 
  /// [now] الوقت الحالي
  /// Returns: قائمة بالاقتراحات
  List<String> _generateSuggestions(DateTime now) {
    final suggestions = <String>[];
    final hour = now.hour;
    
    // اقتراحات حسب الوقت
    if (hour >= 6 && hour < 12) {
      suggestions.addAll([
        'مراجعة الإيميلات',
        'تحضير خطة اليوم',
        'ممارسة الرياضة',
      ]);
    } else if (hour >= 12 && hour < 17) {
      suggestions.addAll([
        'اجتماع فريق العمل',
        'مراجعة التقارير',
        'متابعة المشاريع',
      ]);
    } else {
      suggestions.addAll([
        'تحضير قائمة الغد',
        'قراءة كتاب',
        'وقت مع العائلة',
      ]);
    }
    
    // اقتراحات حسب اليوم
    final weekday = now.weekday;
    if (weekday == DateTime.monday) {
      suggestions.add('تخطيط الأسبوع');
    } else if (weekday == DateTime.friday) {
      suggestions.add('مراجعة إنجازات الأسبوع');
    }
    
    return suggestions.take(3).toList();
  }

  /// التحقق من صلاحية الـ Cache
  /// 
  /// Returns: true إذا كان الـ Cache صالحاً
  bool _isCacheValid() {
    if (_lastCacheTime == null) return false;
    
    final now = DateTime.now();
    return now.difference(_lastCacheTime!) < _cacheDuration;
  }

  /// مسح الـ Cache يدوياً
  /// 
  /// تستخدم لتحديث الاقتراحات فوراً
  void clearCache() {
    _suggestionsCache.clear();
    _lastCacheTime = null;
  }

  /// تحليل الإنتاجية بناءً على المهام المكتملة
  /// 
  /// يحسب نقاط الإنتاجية ويحدد أفضل وقت للعمل
  /// ويقدم اقتراحات للتحسين
  /// 
  /// [completedTasks] قائمة بالمهام المكتملة مع تاريخ completedAt
  /// Returns: [ProductivityAnalysis] يحتوي على:
  /// - نقاط الإنتاجية (0-100)
  /// - أفضل وقت للعمل
  /// - اقتراحات التحسين
  ProductivityAnalysis analyzeProductivity(List<Map<String, dynamic>> completedTasks) {
    final analysis = ProductivityAnalysis();
    
    if (completedTasks.isEmpty) {
      analysis.score = 0;
      analysis.bestTimeToWork = 'الصباح';
      analysis.suggestions = ['ابدأ بإضافة بعض المهام!'];
      return analysis;
    }
    
    // حساب نقاط الإنتاجية
    final totalTasks = completedTasks.length;
    final now = DateTime.now();
    final completedToday = completedTasks.where((task) {
      final date = DateTime.parse(task['completedAt']);
      return date.year == now.year && date.month == now.month && date.day == now.day;
    }).length;
    
    analysis.score = ((completedToday / max(totalTasks * 0.1, 1)) * 100).clamp(0, 100).round();
    
    // تحليل أفضل وقت للعمل
    final hourCounts = <int, int>{};
    for (final task in completedTasks) {
      final hour = DateTime.parse(task['completedAt']).hour;
      hourCounts[hour] = (hourCounts[hour] ?? 0) + 1;
    }
    
    if (hourCounts.isNotEmpty) {
      final bestHour = hourCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      if (bestHour >= 6 && bestHour < 12) {
        analysis.bestTimeToWork = 'الصباح';
      } else if (bestHour >= 12 && bestHour < 17) {
        analysis.bestTimeToWork = 'بعد الظهر';
      } else {
        analysis.bestTimeToWork = 'المساء';
      }
    }
    
    // اقتراحات التحسين
    analysis.suggestions = _generateImprovementSuggestions(analysis.score);
    
    return analysis;
  }

  /// توليد اقتراحات لتحسين الإنتاجية
  /// 
  /// [score] نقاط الإنتاجية (0-100)
  /// Returns: قائمة بالاقتراحات المناسبة
  List<String> _generateImprovementSuggestions(int score) {
    if (score >= 80) {
      return [
        'أداء ممتاز! استمر على هذا المنوال',
        'جرب تحدي نفسك بمهام أكثر تعقيداً',
        'شارك خبرتك مع الآخرين',
      ];
    } else if (score >= 60) {
      return [
        'أداء جيد! يمكنك تحسينه أكثر',
        'حاول تقسيم المهام الكبيرة لأجزاء صغيرة',
        'خصص وقتاً محدداً لكل مهمة',
      ];
    } else if (score >= 40) {
      return [
        'تحتاج لتحسين التركيز',
        'ابدأ بالمهام السهلة لبناء الزخم',
        'استخدم تقنية البومودورو',
      ];
    } else {
      return [
        'ابدأ بخطوات صغيرة',
        'ضع أهدافاً واقعية',
        'احتفل بالإنجازات الصغيرة',
      ];
    }
  }
  
  /// توليد اقتراحات بحث ذكية
  /// 
  /// يحلل المهام الموجودة لاستخراج كلمات مفتاحية شائعة
  /// ويقترح عمليات بحث بناءً على التصنيفات والأولويات
  /// 
  /// [tasks] قائمة المهام لتحليلها
  /// Returns: قائمة بالاقتراحات (5-7 اقتراحات)
  Future<List<String>> generateSearchSuggestions(List<Task> tasks) async {
    final suggestions = <String>[];
    final now = DateTime.now();
    
    // تحليل المهام لاستخراج أنماط شائعة
    final categories = <String, int>{};
    final priorities = <int, int>{};
    final keywords = <String, int>{};
    
    for (final task in tasks) {
      // تحليل التصنيفات
      categories[task.safeCategory.displayName] = (categories[task.safeCategory.displayName] ?? 0) + 1;
      
      // تحليل الأولويات
      priorities[task.priority] = (priorities[task.priority] ?? 0) + 1;
      
      // استخراج كلمات مفتاحية من العناوين
      final words = task.title.toLowerCase().split(' ');
      for (final word in words) {
        if (word.length > 3) {
          keywords[word] = (keywords[word] ?? 0) + 1;
        }
      }
    }
    
    // اقتراحات بناءً على الوقت والتاريخ
    suggestions.addAll([
      'مهام اليوم',
      'مهام الغد',
      'مهام هذا الأسبوع',
    ]);
    
    // اقتراحات بناءً on الأولويات
    if (priorities[2] != null && priorities[2]! > 0) {
      suggestions.add('مهام عالية الأولوية');
    }
    if (priorities[0] != null && priorities[0]! > 0) {
      suggestions.add('مهام منخفضة الأولوية');
    }
    
    // اقتراحات بناءً على التصنيفات الأكثر شيوعاً
    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (int i = 0; i < min(2, sortedCategories.length); i++) {
      suggestions.add('مهام ${sortedCategories[i].key}');
    }
    
    // اقتراحات بناءً على المهام المتأخرة
    final overdueTasks = tasks.where((task) {
      if (task.dueDate != null) {
        return task.dueDate!.isBefore(now) && !task.isDone;
      }
      return false;
    }).length;
    
    if (overdueTasks > 0) {
      suggestions.add('مهام متأخرة');
    }
    
    // اقتراحات بناءً على الكلمات المفتاحية الشائعة
    final sortedKeywords = keywords.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    for (int i = 0; i < min(2, sortedKeywords.length); i++) {
      if (suggestions.length < 7) {
        suggestions.add(sortedKeywords[i].key);
      }
    }
    
    return suggestions.take(7).toList();
  }
  
  /// ترتيب نتائج البحث حسب الأهمية
  /// 
  /// يرتب النتائج بناءً على:
  /// - الأولوية
  /// - التاريخ (المهام القادمة أولاً)
  /// - درجة التطابق
  /// 
  /// [tasks] قائمة المهام المرتبة
  /// [query] نص البحث
  /// Returns: قائمة المهام مرتبة حسب الأهمية
  Future<List<Task>> rankSearchResults(List<Task> tasks, String query) async {
    if (tasks.isEmpty) return tasks;
    
    final queryLower = query.toLowerCase();
    final now = DateTime.now();
    
    // حساب درجة لكل مهمة
    final scoredTasks = tasks.map((task) {
      double score = 0.0;
      
      // درجة الأولوية (0-40 نقطة)
      score += task.priority * 20; // عالية الأولوية = 40، متوسطة = 20، منخفضة = 0
      
      // درجة التاريخ (0-30 نقطة)
      if (task.dueDate != null) {
        final daysUntilDue = task.dueDate!.difference(now).inDays;
        if (daysUntilDue < 0) {
          score += 30; // مهام متأخرة
        } else if (daysUntilDue == 0) {
          score += 25; // مهام اليوم
        } else if (daysUntilDue <= 3) {
          score += 20; // مهام قريبة
        } else if (daysUntilDue <= 7) {
          score += 10; // مهام هذا الأسبوع
        }
      }
      
      // درجة التطابق (0-30 نقطة)
      final titleMatch = _calculateMatchScore(task.title.toLowerCase(), queryLower);
      final noteMatch = task.note != null 
          ? _calculateMatchScore(task.note!.toLowerCase(), queryLower)
          : 0.0;
      final categoryMatch = _calculateMatchScore(task.safeCategory.displayName.toLowerCase(), queryLower);
      
      score += (titleMatch * 0.6 + noteMatch * 0.3 + categoryMatch * 0.1) * 30;
      
      // مكافأة للمهام غير المكتملة
      if (!task.isDone) {
        score += 5;
      }
      
      return MapEntry(task, score);
    }).toList();
    
    // ترتيب تنازلي حسب النقاط
    scoredTasks.sort((a, b) => b.value.compareTo(a.value));
    
    return scoredTasks.map((entry) => entry.key).toList();
  }
  
  /// حساب درجة التطابق بين نصين
  /// 
  /// [text] النص المراد البحث فيه
  /// [query] نص البحث
  /// Returns: درجة التطابق (0.0 - 1.0)
  double _calculateMatchScore(String text, String query) {
    if (query.isEmpty) return 0.0;
    if (text.isEmpty) return 0.0;
    
    // تطابق تام
    if (text == query) return 1.0;
    
    // تطابق كامل للكلمة
    if (text.contains(query)) return 0.8;
    
    // تطابق جزئي للكلمات
    final queryWords = query.split(' ');
    final textWords = text.split(' ');
    
    int matchedWords = 0;
    for (final qWord in queryWords) {
      for (final tWord in textWords) {
        if (tWord.contains(qWord)) {
          matchedWords++;
          break;
        }
      }
    }
    
    return matchedWords / queryWords.length;
  }
}

/// نموذج بيانات تحليل المهمة
/// 
/// يحتوي على نتائج تحليل NLP للمهمة
class TaskAnalysis {
  /// الأولوية المستخرجة (0-2)
  int priority = 0;
  
  /// تاريخ الاستحقاق المستخرج
  DateTime? dueDate;
  
  /// المدة المقدرة بالدقائق
  int estimatedDuration = 30;
  
  /// الفئة المقترحة
  String suggestedCategory = 'عام';
}

/// نموذج بيانات تحليل الإنتاجية
/// 
/// يحتوي على نتائج تحليل أداء المستخدم
class ProductivityAnalysis {
  /// نقاط الإنتاجية (0-100)
  int score = 0;
  
  /// أفضل وقت للعمل (الصباح، بعد الظهر، المساء)
  String bestTimeToWork = 'الصباح';
  
  /// قائمة بالاقتراحات لتحسين الإنتاجية
  List<String> suggestions = [];
}

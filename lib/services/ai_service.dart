import 'dart:math';
import 'package:intl/intl.dart';

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
    // كلمات عربية للأولوية العالية
    final urgentWords = ['عاجل', 'مهم', 'ضروري', 'فوري', 'urgent', 'important', 'critical'];
    // كلمات للأولوية المتوسطة
    final mediumWords = ['متوسط', 'عادي', 'medium', 'normal'];
    // كلمات للأولوية المنخفضة
    final lowWords = ['بسيط', 'سهل', 'low', 'simple', 'easy'];
    
    for (String word in urgentWords) {
      if (text.contains(word)) return 2; // High priority
    }
    
    for (String word in mediumWords) {
      if (text.contains(word)) return 1; // Medium priority
    }
    
    for (String word in lowWords) {
      if (text.contains(word)) return 0; // Low priority
    }
    
    // تحليل طول النص وتعقيده
    if (text.length > 50 || text.contains('اجتماع') || text.contains('meeting')) {
      return 1; // Medium priority
    }
    
    return 0; // Default low priority
  }

  /// استخراج التاريخ من النص
  /// 
  /// يتعرف على كلمات مثل: غداً، بعد غد، الأسبوع القادم
  /// وأيضاً يتعرف على التواريخ بصيغة DD/MM
  /// 
  /// [text] النص بأحرف صغيرة
  /// Returns: DateTime إذا تم التعرف على تاريخ، null إذا لم يتم
  DateTime? _extractDate(String text) {
    final now = DateTime.now();
    
    // كلمات التاريخ العربية
    if (text.contains('غداً') || text.contains('غدا') || text.contains('tomorrow')) {
      return now.add(const Duration(days: 1));
    }
    
    if (text.contains('بعد غد') || text.contains('day after tomorrow')) {
      return now.add(const Duration(days: 2));
    }
    
    if (text.contains('الأسبوع القادم') || text.contains('next week')) {
      return now.add(const Duration(days: 7));
    }
    
    if (text.contains('الشهر القادم') || text.contains('next month')) {
      return DateTime(now.year, now.month + 1, now.day);
    }
    
    // البحث عن أرقام التواريخ
    final dateRegex = RegExp(r'(\d{1,2})[\/\-](\d{1,2})');
    final match = dateRegex.firstMatch(text);
    if (match != null) {
      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      return DateTime(now.year, month, day);
    }
    
    return null;
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
  /// Returns: الفئة (العمل، شخصي، التعلم، الصحة، عام)
  String _suggestCategory(String text) {
    final workWords = ['عمل', 'مكتب', 'اجتماع', 'work', 'office', 'meeting'];
    final personalWords = ['شخصي', 'منزل', 'عائلة', 'personal', 'home', 'family'];
    final studyWords = ['دراسة', 'تعلم', 'كتاب', 'study', 'learn', 'book'];
    final healthWords = ['رياضة', 'طبيب', 'صحة', 'sport', 'doctor', 'health'];
    
    for (String word in workWords) {
      if (text.contains(word)) return 'العمل';
    }
    
    for (String word in personalWords) {
      if (text.contains(word)) return 'شخصي';
    }
    
    for (String word in studyWords) {
      if (text.contains(word)) return 'التعلم';
    }
    
    for (String word in healthWords) {
      if (text.contains(word)) return 'الصحة';
    }
    
    return 'عام';
  }

  /// توليد اقتراحات ذكية للمهام
  /// 
  /// يعتمد على الوقت الحالي واليوم لتوليد اقتراحات مناسبة
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
    final suggestions = <String>[];
    final now = DateTime.now();
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
    final completedToday = completedTasks.where((task) {
      final date = DateTime.parse(task['completedAt']);
      return date.day == DateTime.now().day;
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

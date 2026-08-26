// Developed by:
// - Arabic: م / يوسف محمود عبد الجواد
// - English: Eng / Youssef Mahmoud Abdelgawad
// - Business Website: https://y0ussef.com/
// - Whatsapp: https://wa.me/201129334173
// - Email: info@Y0ussef.com

/// أدوات مساعدة للتاريخ ومقارنة الأيام
class AppDateUtils {
  /// التحقق مما إذا كان التاريخان يقعان في نفس اليوم (تجاهل الوقت)
  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// التحقق مما إذا كان التاريخ هو تاريخ اليوم
  static bool isToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  /// إرجاع بداية اليوم (00:00:00.000)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// بداية يوم اليوم
  static DateTime todayStart() {
    return startOfDay(DateTime.now());
  }
}

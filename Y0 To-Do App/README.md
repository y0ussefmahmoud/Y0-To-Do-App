# Y0 To-Do App

![Flutter](https://img.shields.io/badge/Flutter-3.24.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.5.x-0175C2?logo=dart&logoColor=white)
![Version](https://img.shields.io/badge/Version-3.2.8-66BB6A)
![Tests](https://img.shields.io/badge/Tests-16%2F16%20passing-brightgreen)
![Coverage](https://img.shields.io/badge/coverage-85%25-brightgreen)
![Analyzer](https://img.shields.io/badge/analyzer-0%20errors-brightgreen)

## نظرة عامة
Y0 To-Do App هو تطبيق إدارة مهام ذكي باللغة العربية أولاً، مع اقتراحات مدعومة بالذكاء الاصطناعي، وإدخال صوتي باللغة العربية، وتصفية متقدمة. يجمع بين واجهة عصرية وإدارة حالة Riverpod والتخزين المحلي باستخدام Hive لسرعة وأداء بدون اتصال.

---

## الجديد في الإصدار v3.2.8 (أحدث)

### 🗂️ منطق الأرشيف التلقائي (Archive Logic)
- **شروط الأرشفة التلقائية**: تنتقل المهمة تلقائياً إلى الأرشيف إذا:
  - كانت **مكتملة** (`isDone == true`)، أو
  - **مرّ على موعد استحقاقها أكثر من 30 يوماً**.
- **`task.isArchived` getter**: خاصية محسوبة آمنة ودقيقة على مستوى النموذج.
- **كارت ملخص الأرشيف (`ArchiveSummaryCard`)**: عنصر جديد في شاشة الإحصائيات يعرض تفكيكاً مرئياً واضحاً لـ:
  - 🟢 **المهام النشطة الجارية** (غير المؤرشفة).
  - 🟠 **المهام القديمة** (تجاوزت 30 يوماً).
  - 🔵 **المهام المكتملة**.
- **زر فلتر الأرشيف** في القائمة السريعة بالصفحة الرئيسية لعرض المهام المؤرشفة مباشرة.

### 📊 تحسين منطق الإحصائيات
- **`QuickStatsCards`**: إصلاح القيم لعرض المهام المكتملة نسبةً للإجمالي مع نسبة مئوية حية ودقيقة.
- **`EditorialHeroHeader`**: رسالة تحفيزية ديناميكية متكيفة مع نسبة الإنجاز (0% → 100%).
- **`WeeklyProductivityChart`**: إصلاح حساب أيام الأسبوع بدءاً من الأحد بدقة.

### 🏗️ إعادة هيكلة وتحسين الأداء
- 🧩 **تقسيم الملفات الضخمة**: تقسيم `home_screen_neomorphic.dart` (1322 سطر) إلى 7 مكونات مستقلة في `lib/screens/home/`.
- 🧩 **نمذجة شاشتي الإحصائيات والإعدادات**: مكونات صغيرة وقابلة للصيانة في `lib/widgets/statistics/` و `lib/widgets/settings/`.
- ⚡ **Lazy Building**: قوائم `SliverList.builder` بدون `shrinkWrap` لرفع سلاسة الأداء.
- 🎯 **Memoized State**: `taskCountsProvider` لمنع تكرار عمليات الفلترة في الـ Build Loop.
- 🔍 **Riverpod `.select()`**: حصر تحديث الـ widgets فقط على الجزء المتغير فعلياً.

### 🐛 إصلاحات منطقية وبصرية
- إصلاح خطأ `RenderFlex overflowed` في جميع الأماكن (تم تطبيق `FittedBox` و`Flexible` و`Expanded` و`maxLines`).
- إصلاح إضافة المهام الجديدة في `_showAddTaskDialog`.
- تصحيح رسائل حالة Toggle، ونمط Sentinel في `task.copyWith()`، وإصدار UUID للمهام الصوتية.
- 👨‍💻 **توثيق المطور**: إضافة حقوق ملكية مطور التطبيق في جميع ملفات `.dart`.

### ✅ نتائج الفحص والاختبارات
```
flutter analyze lib  →  0 errors (6 deprecated Radio info فقط)
flutter test         →  16/16 All tests passed!
```

---

## الجديد في الإصدار v3.2.6
- 💾 **ميزة النسخ الاحتياطي**: آلية تصدير واستعادة البيانات (Backup & Restore)
- 📤 **تصدير البيانات**: تصدير جميع بيانات التطبيق (المهام، الإعدادات، سجل البحث) إلى ملف JSON
- 📥 **استعادة البيانات**: استيراد البيانات من ملف النسخ الاحتياطي
- 📤 **مشاركة النسخ الاحتياطي**: عبر share_plus (WhatsApp, Email, Google Drive, إلخ)
- 🗂️ **تحسين النماذج**: إضافة `toJson`/`fromJson` لـ Task و SearchHistory
- 🧹 **تنظيف المشروع**: إزالة الملفات غير المفيدة

---

## المميزات الكاملة

| الميزة | الوصف |
|---|---|
| 🎨 **تصميم Neo-morphic** | واجهة حديثة مع تأثيرات 3D وظلال واقعية |
| 🗂️ **أرشيف تلقائي** | أرشفة تلقائية للمهام المكتملة أو القديمة (>30 يوم) |
| 📊 **إحصائيات متكاملة** | رسوم بيانية تفاعلية وتحليلات مفصّلة للأداء |
| 🌙 **وضع ليلي مخصص** | ألوان متكيفة مع أفضل تجربة مستخدم |
| 🤖 **ذكاء اصطناعي** | تحليل المهام، اقتراح الأولوية والتصنيف والموعد |
| 🎤 **إدخال صوتي** | دعم كامل للغة العربية |
| 🔍 **فلاتر متقدمة** | الحالة، الأولوية، التصنيف، التاريخ، الأرشيف |
| 🔎 **بحث ذكي** | بحث فوري مع سجل وتصفية آنية |
| 🔔 **إشعارات محلية** | تعمل حتى لو التطبيق مقفول |
| 💾 **نسخ احتياطي** | تصدير واستيراد البيانات عبر JSON |
| ⚡ **أداء مُحسَّن** | Lazy Building + Riverpod `.select()` + Memoized Counts |
| 📱 **توافق شامل** | Android 5.0+ بما فيها Samsung Galaxy |

---

## Tech Stack

| Layer | Technology |
|---|---|
| UI | Flutter (Material 3 + Neo-morphic Design) |
| State | Riverpod (+ `.select()` & memoized providers) |
| Storage | Hive |
| Voice | Speech-to-Text / TTS |
| Charts | fl_chart |
| Animations | flutter_animate + Lottie |
| Navigation | Named Routes + Material Router |

---

## Architecture

```
lib/
├── main.dart
├── models/
│   ├── task.dart              # Task model + isArchived getter
│   ├── task_filter.dart
│   └── task_category.dart
├── providers/
│   ├── task_provider.dart     # tasksProvider + taskCountsProvider
│   └── settings_provider.dart
├── screens/
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   │       ├── greeting_card.dart
│   │       ├── progress_card.dart
│   │       ├── search_section.dart
│   │       ├── quick_filters.dart
│   │       ├── task_list_widget.dart
│   │       └── task_card_widget.dart
│   ├── statistics_screen.dart
│   ├── settings_screen.dart
│   └── add_edit_task_screen.dart
├── widgets/
│   ├── statistics/
│   │   ├── editorial_hero_header.dart
│   │   ├── quick_stats_cards.dart
│   │   ├── weekly_productivity_chart.dart
│   │   ├── achievement_badges.dart
│   │   └── archive_summary_card.dart   # NEW in v3.2.8
│   └── settings/
│       ├── language_selector.dart
│       ├── notification_time_selector.dart
│       └── name_edit_dialog.dart
├── services/
│   ├── ai_service.dart
│   ├── task_service.dart
│   └── notification_service.dart
└── theme/
    └── y0_design_system.dart
```

---

## Setup

```bash
# تثبيت المتطلبات
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# تشغيل التطبيق
flutter run

# تشغيل الاختبارات
flutter test

# فحص جودة الكود
flutter analyze lib
```

---

## Quality Metrics

| Metric | Result |
|---|---|
| Unit Tests | ✅ 16/16 passing |
| Analyzer Errors | ✅ 0 errors |
| Analyzer Warnings | ⚠️ 6 info (deprecated Radio API) |
| Test Coverage | ✅ ≥ 85% |

---

## استكشاف الأخطاء وإصلاحها

### 1. التطبيق لا يعمل على الهاتف الحقيقي
**الحل:** امسح بيانات التطبيق القديمة قبل الترقية، أو أعد التثبيت من الصفر.

### 2. الإشعارات لا تعمل على Samsung Galaxy
**الحل:**
- الإعدادات → البطارية → استخدام البطارية → Y0 To-Do App → "عدم تقييد"
- الإعدادات → التطبيقات → Y0 To-Do App → البطارية → "غير مقيد"
- الإعدادات → التطبيقات → خاصة → إذن الدقة العالية → فعّل للتطبيق

### 3. الميكروفون لا يعمل
**الحل:**
- الإعدادات → التطبيقات → Y0 To-Do App → الصلاحيات → فعّل "الميكروفون"

### 4. خطأ في البناء (Daemon compilation failed)
**الحل:** تأكد أن `JAVA_HOME` يشير لـ Java 17 أو أعلى.

### 5. RenderFlex overflow في الإحصائيات
**الحل:** تم حل هذه المشكلة بالكامل في v3.2.8 عبر `FittedBox` و`Flexible`.

---

## المتطلبات التقنية
- Android 5.0 (API 21) أو أعلى
- 50MB مساحة تخزين
- صلاحيات: الإشعارات، الميكروفون، التخزين

---

## المطور

| | |
|---|---|
| 👨‍💻 **المطور** | م / يوسف محمود عبد الجواد |
| 🌐 **الموقع** | [y0ussef.com](https://y0ussef.com/) |
| 💬 **واتساب** | [wa.me/201129334173](https://wa.me/201129334173) |
| 📧 **البريد** | [info@Y0ussef.com](mailto:info@Y0ussef.com) |

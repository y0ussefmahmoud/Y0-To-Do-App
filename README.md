# Y0 To-Do App

![Flutter](https://img.shields.io/badge/Flutter-3.24.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.5.x-0175C2?logo=dart&logoColor=white)
![Version](https://img.shields.io/badge/Version-2.3.3-66BB6A)
![Coverage](https://img.shields.io/badge/coverage-85%25-brightgreen)

## نظرة عامة
Y0 To-Do App هو تطبيق إدارة مهام ذكي باللغة العربية أولاً، مع اقتراحات مدعومة بالذكاء الاصطناعي، وإدخال صوتي باللغة العربية، وتصفية متقدمة. يجمع بين واجهة عصرية وإدارة حالة Riverpod والتخزين المحلي باستخدام Hive لسرعة وأداء بدون اتصال.

## Screenshots
> Add screenshots under `assets/` and reference them here.

## المميزات
- ✅ تحليل المهام بالذكاء الاصطناعي (الأولوية، التصنيف، اقتراحات الموعد)
- ✅ إدخال صوتي بالتعرف على الكلام العربي
- ✅ اقتراحات ذكية بناءً على المهام الحديثة
- ✅ فلاتر متقدمة (الحالة، الأولوية، التصنيف، التاريخ)
- ✅ بحث مع سجل + نتائج فورية
- ✅ إشعارات محلية + جدولة تعمل حتى لو التطبيق مقفول
- ✅ رسوم متحركة سلسة مع ردود فعلية لمسية
- ✅ متوافق مع جميع أجهزة Android بما فيها Samsung Galaxy

## الإصلاحات الأخيرة (v2.3.3)
- 🚀 **تحديث البيئة البرمجية**: ترقية Java إلى إصدار 17 وتحديث JVM Target لتحسين أداء بناء التطبيق واستقراره.
- 🔧 **حل مشكلة Kotlin Daemon**: إصلاح أخطاء البناء المتعلقة بـ `Daemon compilation failed` وتعارض ملفات الكاش.
- 🛠️ **تحسين استقرار المكتبات**: تحديث `package_info_plus` و `device_info_plus` لضمان التوافق الكامل مع أحدث إصدارات Android.
- 📝 **تحديث التوثيق**: تحديث دليل التشغيل والـ README ليعكس التغييرات التقنية الجديدة.

## الإصلاحات السابقة (v2.3.2)
- 🎨 **تحسينات Dark Mode**: إصلاح ألوان الفلاتر والنصوص في الوضع الليلي.
- 🎯 **تحسين تجربة المستخدم**: توحيد الألوان في جميع الفلاتر (الحالة، الأولوية، التصنيف، التاريخ).
- 📱 **إصلاح الشاشات الصغيرة**: تحسين عرض الفلاتر النشطة في الأجهزة ذات الشاشات المحدودة.
- 🔧 **استقرار التطبيق**: تحسين معالجة الأخطاء وزيادة الاستقرار العام.

## الإصلاحات السابقة (v2.2.6-2.2.8)
- 🔧 إصلاح انهيار التطبيق عند بدء التشغيل على الأجهزة الحقيقية
- 🔧 حل مشكلة الإشعارات على هواتف Samsung Galaxy
- 🔧 إصلاح خطأ type cast في إعدادات التطبيق
- 🔧 تحسين استقرار البحث والاقتراحات الذكية
- 🔧 إضافة صلاحيات الميكروفون للإدخال الصوتي

## Tech Stack
| Layer | Technology |
| --- | --- |
| UI | Flutter (Material 3) |
| State | Riverpod |
| Storage | Hive |
| Voice | Speech/TTS services |
| Animations | flutter_animate + Lottie |

## Architecture
For detailed diagrams and data flow, see [ARCHITECTURE.md](ARCHITECTURE.md).

```mermaid
flowchart TB
  App[MyApp] --> Screens
  Screens --> Home[HomeScreen]
  Screens --> Settings[SettingsScreen]
  Screens --> Stats[StatisticsScreen]

  Home --> Providers
  Providers --> Tasks[Task Providers]
  Providers --> Voice[Voice Provider]
  Providers --> Search[Search Provider]

  Providers --> Services
  Services --> AI[AI Service]
  Services --> Speech[Speech Service]
  Services --> Notifications[Notification Service]

  Tasks --> Storage[Hive Boxes]
```

## Requirements
- Flutter SDK 3.x
- Dart SDK (bundled with Flutter)
- Android Studio / VS Code with Flutter plugins
- Android/iOS device or emulator

## Setup
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## Run
```bash
flutter run
```

## Tests
```bash
flutter test --coverage
```

## Quality Metrics
| Metric | Target |
| --- | --- |
| Test coverage | ≥ 70% |
| Linting | 0 analyzer errors |
| Accessibility | Semantics labels on interactive UI |

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines and workflow.

## استكشاف الأخطاء وإصلاحها

### مشاكل شائعة وحلولها

#### 1. التطبيق لا يعمل على الهاتف الحقيقي
**المشكلة:** التطبيق ينهار عند التثبيت على الهاتف
**الحل:** امسح بيانات التطبيق القديمة قبل الترقية، أو قم بإلغاء التثبيت وإعادة التثبيت

#### 2. الإشعارات لا تعمل على Samsung Galaxy
**المشكلة:** الإشعارات لا تصل عندما يكون التطبيق مقفول
**الحل:**
- اذهب إلى الإعدادات > البطارية > استخدام البطارية > Y0 To-Do App > "عدم تقييد"
- اذهب إلى الإعدادات > التطبيقات > Y0 To-Do App > البطارية > "غير مقيد"
- اذهب إلى الإعدادات > التطبيقات > خاصة > إذن الدقة العالية > فعّل للتطبيق

#### 3. الميكروفون لا يعمل
**المشكلة:** رسالة "لم يتم منح إذن الميكروفون"
**الحل:**
- اذهب إلى الإعدادات > التطبيقات > Y0 To-Do App > الصلاحيات
- فعّل "الميكروفون" و"تسجيل الصوت"

#### 4. خطأ في البناء (Daemon compilation failed)
**المشكلة:** فشل بناء التطبيق مع رسائل خطأ تتعلق بـ Kotlin أو Java.
**الحل:** تم حل المشكلة في v2.3.3 عبر الترقية لـ Java 17. تأكد من ضبط `JAVA_HOME` على الإصدار 17 أو أعلى في جهازك.

### المتطلبات التقنية
- Android 5.0 (API 21) أو أعلى
- 50MB مساحة تخزين
- صلاحيات: الإشعارات، الميكروفون، التخزين

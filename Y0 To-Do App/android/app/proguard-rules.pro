# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Hive specific rules
-keep class org.apache.hadoop.hive.** { *; }
-dontwarn org.apache.hadoop.hive.**

# Riverpod specific rules
-keep class androidx.compose.** { *; }

# Local notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Speech to text
-keep class flutter.speech.** { *; }

# Gson rules
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep model classes
-keep class com.y0.y0_todo_app.models.** { *; }

# Keep Hive adapters
-keep class com.y0.y0_todo_app.adapters.** { *; }

# Keep providers
-keep class com.y0.y0_todo_app.providers.** { *; }

# Keep services
-keep class com.y0.y0_todo_app.services.** { *; }

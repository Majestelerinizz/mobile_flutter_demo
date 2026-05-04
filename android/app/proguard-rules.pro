# AidatPanel ProGuard Rules
# Flutter ve kullanılan paketler için obfuscation kuralları

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Dio ve Network
-keep class com.google.gson.** { *; }
-keep class retrofit2.** { *; }
-dontwarn retrofit2.**
-keepattributes Signature
-keepattributes Exceptions

# JSON Serialization (freezed, json_serializable)
-keepclassmembers class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Riverpod
-keep class flutter_riverpod.** { *; }
-keepclassmembers class * {
    flutter_riverpod.** *;
}

# RevenueCat (Purchases Flutter)
-keep class com.revenuecat.purchases.** { *; }
-keep class com.revenuecat.purchases_flutter.** { *; }

# Dio Cookie Manager (varsa)
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# Keep model classes
-keep class com.aidatpanel.mobile.** { *; }
-keepclassmembers class com.aidatpanel.mobile.** { *; }

# Generics
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes SourceFile
-keepattributes LineNumberTable

# Prevent R8 from leaving data object members always null
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}

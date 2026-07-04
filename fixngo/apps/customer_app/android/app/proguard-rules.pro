# Fix-N-Go Customer App — ProGuard Rules
# Flutter-specific rules

# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Keep Dart plugin classes
-keep class com.google.** { *; }
-keep class io.grpc.** { *; }

# Keep Razorpay SDK
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Keep MQTT client
-keep class org.eclipse.paho.** { *; }
-dontwarn org.eclipse.paho.**

# Keep Stripe SDK  
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**
-keep class com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**

# Keep OkHttp (used by many SDKs)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# OkHttp2 (used by io.grpc.okhttp)
-dontwarn com.squareup.okhttp.**
-keep class com.squareup.okhttp.** { *; }

# Guava / Java reflect Annotations (used by io.grpc / Guava)
-dontwarn java.lang.reflect.AnnotatedType
-dontwarn com.google.common.reflect.**

# Keep JSON serialization
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }

# Prevent stripping of crash reporting metadata
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

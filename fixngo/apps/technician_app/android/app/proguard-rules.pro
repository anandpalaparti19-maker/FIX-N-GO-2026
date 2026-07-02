# Fix-N-Go Technician App — ProGuard Rules
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

# Keep OkHttp (used by many SDKs)
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Keep JSON serialization
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }

# Prevent stripping of crash reporting metadata
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

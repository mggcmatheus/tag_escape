# Regras de ofuscação/encolhimento para release.

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Flutter (mantido pelo plugin, reforçado aqui)
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

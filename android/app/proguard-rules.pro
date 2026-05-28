-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class com.backgroundlocator.** { *; }

# Защита для корректной работы SSL Pinning и криптографии
-keepclassmembers class * {
    native <methods>;
}
-dontwarn java.awt.**
-dontwarn javax.security.**

# Если используешь сериализацию данных (например json_serializable / built_value)
-keepattributes Signature
-keepattributes *Annotation*

# Запрещаем R8 ругаться на отсутствие OkHttp и Okio внутри библиотеки ucrop
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn com.yalantis.ucrop.**

# На всякий случай сохраняем саму структуру ucrop, чтобы она не обфусцировалась в кашу
-keep class com.yalantis.ucrop.** { *; }
-keep interface com.yalantis.ucrop.** { *; }
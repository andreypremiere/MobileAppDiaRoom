import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// 1. ИНИЦИАЛИЗАЦИЯ И ЧТЕНИЕ ФАЙЛА С КЛЮЧАМИ (Kotlin DSL вариант)
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "me.diaroom.dia_room"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    // ИСПРАВЛЕНО: Поднимаем версию Java до актуальной 17-й, чтобы убрать варнинги
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // ИСПРАВЛЕНО: Корректное приведение версии JVM для Kotlin
    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "me.diaroom.dia_room"
        minSdk = 24
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 2. НАСТРОЙКА КОНФИГУРАЦИИ ПОДПИСИ (Должна идти ДО buildTypes)
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    // 3. СБОРКА И ОПТИМИЗАЦИЯ (Один объединенный блок)
    buildTypes {
        getByName("release") {
            // Привязываем созданную выше конфигурацию подписи "release"
            signingConfig = signingConfigs.getByName("release")

            // Включаем ProGuard оптимизацию
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
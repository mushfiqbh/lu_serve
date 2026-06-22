plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.lu_serve"
    // compileSdk 36 is required by androidx.core 1.17.0 / androidx.browser
    // 1.9.0 (pulled in transitively by supabase_flutter). It also covers
    // the android:attr/lStar attribute used by sign_in_with_apple >= 6.0.0.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.lu_serve"
        // Plugins like file_picker require minSdk 21+; pin a safe floor.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Use a debug signing config for now so `flutter build apk` works
            // out of the box. Replace with a real release signing config
            // (see https://docs.flutter.dev/deployment/android#signing-the-app)
            // before publishing to the Play Store.
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

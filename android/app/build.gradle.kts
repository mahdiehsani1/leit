import java.util.Properties  // برای خواندن فایل key.properties لازم است

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mahdi.leit"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true  // لازم برای flutter_local_notifications
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    // 🔐 امضای ریلیز با keystore واقعی
    signingConfigs {
        create("release") {
            val props = Properties()
            val propsFile = rootProject.file("key.properties")
            if (propsFile.exists()) {
                props.load(propsFile.inputStream())
            }

            storeFile = file("leit-release-key.jks")
            storePassword = props["storePassword"]?.toString()
            keyAlias = props["keyAlias"]?.toString()
            keyPassword = props["keyPassword"]?.toString()
        }
    }

    defaultConfig {
        applicationId = "com.mahdi.leit"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // ❗ این خط مشکل Resource Shrinking را کامل حل می‌کند
            isMinifyEnabled = true    

            // امضای واقعی Release
            signingConfig = signingConfigs.getByName("release")
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // نسخه اصلاح شده برای رفع خطای بیلد
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
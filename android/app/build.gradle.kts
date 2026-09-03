import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Where the upload key lives, kept out of the repo by android/.gitignore.
//
// Absent on a machine that has never been given the keystore, which is the
// normal case for a fresh clone and for CI, so its absence must not break the
// build — see the release block below.
val keystoreProperties =
    Properties().apply {
        val file = rootProject.file("key.properties")
        if (file.exists()) {
            file.inputStream().use { load(it) }
        }
    }

val hasReleaseKey = keystoreProperties.getProperty("storeFile") != null

/** Opt-in to signing a release with the debug key, for a build nobody will install. */
val allowDebugSigning = project.findProperty("allowDebugSigning") == "true"

android {
    namespace = "com.xaistrying.ricetracker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.xaistrying.ricetracker"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKey) {
            create("release") {
                storeFile = rootProject.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // The real upload key, or a hard failure.
            //
            // Deliberately not a warning. A debug-signed release APK looks and
            // runs exactly like a properly signed one, so nothing downstream
            // would catch the mistake — and Gradle's logger.warn does not
            // survive `flutter build`'s output filtering, which was checked
            // here rather than assumed. A message nobody sees is no message.
            //
            // The escape hatch keeps `flutter run --release` and a fresh clone
            // workable. Naming it in the failure puts the trade-off in front of
            // whoever hits it, at the moment it matters.
            signingConfig =
                if (hasReleaseKey) {
                    signingConfigs.getByName("release")
                } else {
                    require(allowDebugSigning) {
                        "Refusing to sign a release build with the debug key: it cannot " +
                            "update an app signed by any other key, and the debug keystore " +
                            "is machine-local and disposable.\n" +
                            "  Fix: create android/key.properties (see key.properties.example).\n" +
                            "  Or:  pass -PallowDebugSigning=true for a build you will not distribute."
                    }
                    signingConfigs.getByName("debug")
                }
        }
    }
}

flutter {
    source = "../.."
}

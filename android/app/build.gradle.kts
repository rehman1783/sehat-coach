import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val releaseProperties = Properties()
val releasePropertiesFile = rootProject.file("key.properties")
if (releasePropertiesFile.exists()) {
    releasePropertiesFile.inputStream().use(releaseProperties::load)
}
val releaseApplicationId = releaseProperties.getProperty("applicationId")?.trim()
val releaseSigningValues = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
val hasReleaseSigning = releaseSigningValues.all {
    !releaseProperties.getProperty(it).isNullOrBlank()
}

android {
    namespace = "com.example.sehat_coach"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "30.0.16248370"

    buildFeatures {
        buildConfig = true
    }

    lint {
        checkReleaseBuilds = false
        abortOnError = false
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Debug builds retain the placeholder. Release builds are blocked below
        // until key.properties supplies the final Play Store application ID.
        applicationId = releaseApplicationId ?: "com.example.sehat_coach"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // Android 10 (API 29) is the minimum supported release for V1.
        minSdk = 29
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                storeFile = file(releaseProperties.getProperty("storeFile"))
                storePassword = releaseProperties.getProperty("storePassword")
                keyAlias = releaseProperties.getProperty("keyAlias")
                keyPassword = releaseProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
        }
    }
}

gradle.taskGraph.whenReady {
    val requestsRelease = allTasks.any {
        it.project == project && it.name.contains("Release", ignoreCase = true)
    }
    if (requestsRelease) {
        require(!releaseApplicationId.isNullOrBlank()) {
            "Release blocked: set applicationId in android/key.properties."
        }
        require(releaseApplicationId != "com.example.sehat_coach" &&
            !releaseApplicationId.startsWith("com.example.")) {
            "Release blocked: replace the placeholder Android application ID."
        }
        require(hasReleaseSigning) {
            "Release blocked: configure storeFile, storePassword, keyAlias and keyPassword in android/key.properties."
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

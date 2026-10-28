import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

// Keys and passwords go in local.properties, which is gitignored, and from
// there into BuildConfig - never into a tracked file. For example, with
// `example.key=...` in android/local.properties:
//   buildConfigField("String", "EXAMPLE_KEY", "\"${localProps.getProperty("example.key", "")}\"")
val localProps = Properties().apply {
    rootProject.file("local.properties").takeIf { it.exists() }
        ?.inputStream()?.use { load(it) }
}

android {
    namespace = "__APP_ID__"
    compileSdk = kit.versions.compileSdk.get().toInt()

    defaultConfig {
        applicationId = "__APP_ID__"
        // 26 for java.time.
        minSdk = 26
        targetSdk = kit.versions.targetSdk.get().toInt()
        versionCode = 1
        versionName = "0.1"
    }

    buildFeatures {
        buildConfig = true
    }

    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.toVersion(kit.versions.java.get())
        targetCompatibility = JavaVersion.toVersion(kit.versions.java.get())
    }
}

// kotlinOptions.jvmTarget is a hard error in Kotlin 2.3, not a warning.
kotlin {
    compilerOptions {
        jvmTarget.set(JvmTarget.fromTarget(kit.versions.java.get()))
    }
}

dependencies {
    implementation(kit.androidx.core)
    implementation(kit.androidx.activity)

    testImplementation(kit.junit)
}

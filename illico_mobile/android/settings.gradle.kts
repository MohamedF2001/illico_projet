pluginManagement {
    try {
        val processEnvironmentClass = Class.forName("java.lang.ProcessEnvironment")
        val theEnvironmentField = processEnvironmentClass.getDeclaredField("theEnvironment")
        theEnvironmentField.isAccessible = true
        val map = theEnvironmentField.get(null) as MutableMap<String, String>
        map.remove("ANDROID_PREFS_ROOT")

        val theCaseInsensitiveEnvironmentField = processEnvironmentClass.getDeclaredField("theCaseInsensitiveEnvironment")
        theCaseInsensitiveEnvironmentField.isAccessible = true
        val ciMap = theCaseInsensitiveEnvironmentField.get(null) as MutableMap<String, String>
        ciMap.remove("ANDROID_PREFS_ROOT")
        println("Successfully removed ANDROID_PREFS_ROOT from process environment via reflection.")
    } catch (e: Exception) {
        println("Failed to remove ANDROID_PREFS_ROOT: ${e.message}")
    }

    val localPropertiesFile = file("local.properties")
    if (localPropertiesFile.exists()) {
        val text = localPropertiesFile.readText()
        if (!text.contains("sdk.dir")) {
            localPropertiesFile.writeText(text + "\nsdk.dir=C:/Users/frdmo/AppData/Local/Android/Sdk\n")
        }
    }
    val debugProperties = java.util.Properties()
    if (file("local.properties").exists()) {
        file("local.properties").inputStream().use { debugProperties.load(it) }
    }
    println("DEBUG sdk.dir = " + debugProperties.getProperty("sdk.dir"))
    println("DEBUG flutter.sdk = " + debugProperties.getProperty("flutter.sdk"))

    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")

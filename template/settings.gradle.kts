pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
    // AGP, Kotlin, SDK levels and the common libraries, shared by every
    // app on the kit (android\kit is the Volv-G/android-kit submodule).
    versionCatalogs {
        create("kit") { from(files("kit/versions.toml")) }
    }
}

rootProject.name = "__PROJECT__"
include(":app")

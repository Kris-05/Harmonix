// Top-level build file where you can add configuration options common to all sub-projects/modules.

plugins {
    id("com.android.application") version "8.7.0" apply false 
    id("org.jetbrains.kotlin.android") version "1.8.22" apply false 
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Define custom build directory outside of project structure
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Ensure ':app' is evaluated first
subprojects {
    project.evaluationDependsOn(":app")
}

// Clean task to remove generated build files
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

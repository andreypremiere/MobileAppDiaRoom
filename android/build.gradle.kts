allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    tasks.withType<JavaCompile>().configureEach {
        if (sourceCompatibility == "1.8" || sourceCompatibility == "8") {
            sourceCompatibility = "17"
        }
        if (targetCompatibility == "1.8" || targetCompatibility == "8") {
            targetCompatibility = "17"
        }

        // 2. Правильное добавление аргумента в список для Kotlin DSL
        options.compilerArgs.add("-Xlint:-options")
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

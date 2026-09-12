import java.util.*

pluginManagement {
    repositories {
        mavenLocal()
        gradlePluginPortal()
        maven {
            name = "canvasmc"
            url = uri("https://maven.canvasmc.io/public")
        }
    }
}

plugins {
    id("org.gradle.toolchains.foojay-resolver-convention") version "1.0.0"
}

if (!file(".git").exists()) {
    val errorText = """
        
        =====================[ ERROR ]=====================
         The Aurora project directory is not a properly cloned Git repository.
         
         In order to build Aurora from source you must clone
         the Canvas repository using Git, not download a code
         zip from GitHub.
         
         Aurora is built from source; see the README at
         https://github.com/AtlasStudioMC/Aurora
         
         See https://github.com/AtlasStudioMC/Aurora/blob/HEAD/README.md
         for further information on building and modifying Aurora.
        ===================================================
    """.trimIndent()
    error(errorText)
}

enableFeaturePreview("TYPESAFE_PROJECT_ACCESSORS")

rootProject.name = "Aurora"
for (name in listOf("aurora-api", "aurora-server")) {
    val projName = name.lowercase(Locale.ENGLISH)
    include(projName)
    findProject(":$projName")!!.projectDir = file(name)
}

rootDir.listFiles()
    ?.filter { it.isDirectory && (it.name.endsWith("-debug", ignoreCase = true) || it.name.endsWith("-plugin", ignoreCase = true)) }
    ?.forEach { dir ->
        val projName = dir.name.lowercase(Locale.ENGLISH)
        include(projName)
        findProject(":$projName")!!.projectDir = dir
    }

gradle.lifecycle.beforeProject {
    val mcVersion = providers.gradleProperty("mcVersion").get().trim()
    val auroraChannel = providers.gradleProperty("channel").get().trim()
    val auroraBuildNumber = providers.environmentVariable("BUILD_NUMBER").orNull?.trim()?.toInt()
    val versionString = if (auroraBuildNumber == null) {
        "$mcVersion.local-SNAPSHOT"
    } else {
        "$mcVersion.build.$auroraBuildNumber-${auroraChannel.lowercase()}"
    }
    version = versionString
}

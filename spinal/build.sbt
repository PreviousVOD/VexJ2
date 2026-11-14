ThisBuild / organization := "org.j2"
ThisBuild / version      := "0.1.0-SNAPSHOT"
ThisBuild / scalaVersion := "2.13.14"

val spinalVersion = "1.14.2"

lazy val root = (project in file("."))
  .settings(
    name := "j2-spinal",
    libraryDependencies ++= Seq(
      "com.github.spinalhdl" %% "spinalhdl-core" % spinalVersion,
      "com.github.spinalhdl" %% "spinalhdl-lib" % spinalVersion,
      compilerPlugin("com.github.spinalhdl" %% "spinalhdl-idsl-plugin" % spinalVersion),
      "org.scalameta" %% "munit" % "1.0.4" % Test
    ),
    scalacOptions ++= Seq("-deprecation", "-feature", "-unchecked"),
    Test / fork := true,
    Test / parallelExecution := false
  )

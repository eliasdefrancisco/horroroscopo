name := """play-mongo-knockout"""

version := "1.0-SNAPSHOT"

libraryDependencies ++= Seq(
  // Reactive Mongo dependencies
  "org.reactivemongo" %% "play2-reactivemongo" % "0.10.2",
  // WebJars pull in client-side web libraries
  "org.webjars" %% "webjars-play" % "2.2.1",
  "org.webjars" % "bootstrap" % "3.0.0",
  "org.webjars" % "knockout" % "2.3.0",
  "org.webjars" % "requirejs" % "2.1.8"
  // Add your own project dependencies in the form:
  // "group" % "artifact" % "version"
)

play.Project.playScalaSettings

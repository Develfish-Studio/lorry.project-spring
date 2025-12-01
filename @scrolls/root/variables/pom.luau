---!strict

return {
  group_id = "org.example",
  artifact_id = "example",
  parent = {
    group_id = "org.springframework.boot",
    artifact_id = "spring-boot-starter-parent",
    version = "4.0.0",
  },
  modules = {},
  properties = {
    ["studio.develfish.guppy.version"] = "1.0.0-SNAPSHOT",
    ["maven-source-plugin.version"] = "3.3.1",
    ["flatten-maven-plugin.version"] = "1.5.0",
  },
  dependency_management = {
    dependencies = {
      { group_id = "studio.develfish.guppy", artifact_id = "common-api", version = "${studio.develfish.guppy.version}" },
      { group_id = "studio.develfish.guppy", artifact_id = "common-context", version = "${studio.develfish.guppy.version}" },
      { group_id = "studio.develfish.guppy", artifact_id = "common-text", version = "${studio.develfish.guppy.version}" },
      { group_id = "studio.develfish.guppy", artifact_id = "events-api", version = "${studio.develfish.guppy.version}" },
      { group_id = "studio.develfish.guppy", artifact_id = "events-context", version = "${studio.develfish.guppy.version}" },
      { group_id = "studio.develfish.guppy", artifact_id = "minio-context", version = "${studio.develfish.guppy.version}" },
      { group_id = "studio.develfish.guppy", artifact_id = "query-api", version = "${studio.develfish.guppy.version}" },
      { group_id = "studio.develfish.guppy", artifact_id = "query-context", version = "${studio.develfish.guppy.version}" },
      { group_id = "studio.develfish.guppy", artifact_id = "web-mvc-api", version = "${studio.develfish.guppy.version}" },
      { group_id = "studio.develfish.guppy", artifact_id = "web-mvc-context", version = "${studio.develfish.guppy.version}" },
      { group_id = "studio.develfish.guppy", artifact_id = "web-security-context", version = "${studio.develfish.guppy.version}" },
      { group_id = "studio.develfish.guppy", artifact_id = "web-ws-api", version = "${studio.develfish.guppy.version}" },
      { group_id = "studio.develfish.guppy", artifact_id = "web-ws-context", version = "${studio.develfish.guppy.version}" },
    }
  },
}

---!strict

return {
  group_id = "org.example",
  artifact_id = "example",
  parent = {
    group_id = "org.springframework.boot",
    artifact_id = "spring-boot-starter-parent",
    version = "4.0.1",
  },
  modules = {},
  properties = {
    ["guppy.version"] = "1.0.0-SNAPSHOT",
    ["maven-source-plugin.version"] = "3.3.1",
    ["flatten-maven-plugin.version"] = "1.5.0",
    ["postgresql.version"] = "42.7.8",
    ["mysql.version"] = "9.5.0",
  },
  dependency_management = {
    dependencies = {
      { group_id = "studio.develfish.guppy", artifact_id = "bom", version = "${guppy.version}", scope = "import", type = "pom" },
      { group_id = "org.postgresql", artifact_id = "postgresql", version = "${postgresql.version}" },
      { group_id = "com.mysql", artifact_id = "mysql-connector-j", version = "${mysql.version}" },
    }
  },
}

local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local Project = require('@develfish-repo.core/Project')
local Profile = require('@develfish-repo.spring/Profile')
local POM = require('@develfish-repo.spring/POM')
local Dependency = require('@develfish-repo.spring/module/Dependency')
local Datasource = require('@develfish-repo.spring/profile/Datasource')
local case = require('@develfish-repo.core/util/string/case')

export type Module = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Module',
  parent: POM.POM,
  name: string,
  kind: string,
  database: Datasource.Datasource,
  profiles: {[string]: Profile.Profile},
  plugins: {string},
  configs: {string},
  dependencies: {Dependency.Dependency},

  with_rules: (self: Module, children: {any}) -> Module,
  with_database: (self: Module, datasource: Datasource.Datasource) -> Module,
  with_profile: (self: Module, name: string, profile: Profile.Profile) -> Module,
  with_plugins: (self: Module, plugins: {string}) -> Module,
  with_configs: (self: Module, configs: {string}) -> Module,
  with_dependency: (self: Module, group_id: string, artifact_id: string, version: string) -> Module,

  unwrap_pom: (self: Module) -> UnwrappedPOM,
  unwrap_package: (self: Module) -> UnwrappedPackage,
  unwrap_module: (self: Module) -> UnwrappedModule,
  unwrap_profiles: (self: Module) -> {[string]: Profile.Unwrapped},
}

export type Unwrapped = {
  project: Project.UnwrappedProject,
  pom: UnwrappedPOM,
  package: UnwrappedPackage,
  module: UnwrappedModule,
  service: {
    path: string,
  },
  database: Datasource.Unwrapped,
  profiles: {[string]: Profile.Unwrapped},
  dependencies: {Dependency.Unwrapped},
  plugins: {string},
  configs: {string},
}

export type UnwrappedModule = {
  name: string,
  kind: string,
  pascal_name: string,
  camel_name: string,
  app_class: string,
  suite_class: string,
}

export type UnwrappedPOM = {
  artifact_id: string,
  parent: POM.UnwrappedPOM,
  dependencies: {Dependency.Unwrapped},
}

export type UnwrappedPackage = {
  name: string,
  path: string,
}

local Module = {
  __type = 'Module',

  Dependency = Dependency,

  parent = nil,
  name = nil,
  kind = nil,
  database = nil,
  profiles = nil,
  plugins = nil,
  configs = nil,
  dependencies = nil,
}

function Module:new(o): Module
  return Meta:type(o, self)
end

function Module:from(parent: POM.POM, kind: string, name: string): Module
  return Module:new({
    parent = parent,
    name = name,
    kind = kind,
    database = nil,
    profiles = Meta:array {},
    plugins = Meta:array {},
    configs = Meta:array {},
    dependencies = Meta:array {},
  })
end

function Module.with_rules(self: Module, children: {any}): Module
  children = children or {}

  for _, child in children do
    if child.__type == 'Dependency' then
      self.dependencies[#self.dependencies + 1] = child::Dependency.Dependency
    end
  end

  return self
end

function Module.with_database(self: Module, datasource: Datasource.Datasource): Module
  self.database = datasource
  return self
end

function Module.with_profile(self: Module, name: string, profile: Profile.Profile): Module
  self.profiles[name] = profile
  return self
end

function Module.with_plugins(self: Module, plugins: {string}): Module
  plugins = plugins or Meta:array {}
  for _, name in plugins do
    self.plugins[#self.plugins + 1] = name
  end
  return self
end

function Module.with_configs(self: Module, configs: {string}): Module
  configs = configs or Meta:array {}
  for _, name in configs do
    self.configs[#self.configs + 1] = name
  end
  return self
end

function Module.with_dependency(self: Module, group_id: string, artifact_id: string, version: string): Module
  self.dependencies[#self.dependencies + 1] = Dependency:from(group_id, artifact_id, version)
  return self
end

function Module.unwrap_package(self: Module): UnwrappedPackage
  local parent_pom = self.parent:unwrap_pom()
  local package_name = parent_pom.group_id .. '.' .. case.snakeToProp(self.name)
  return {
    name = package_name,
    path = case.propToPath(package_name)
  }
end

function Module.unwrap_profiles(self: Module): {[string]: Profile.Unwrapped}
  local profiles = Meta:table {}
  for _, profile in self.profiles do
    profiles[profile.name] = profile:unwrap()
  end
  return profiles
end

function Module.unwrap_pom(self: Module): UnwrappedPOM
  return {
    artifact_id = self.name,
    parent = self.parent:unwrap_pom(),
    dependencies = Wrapper:unwrap_array(self.dependencies),
  }
end

function Module.unwrap_module(self: Module): UnwrappedModule
  local pascal_name = case.snakeToPascal(self.name)
  local camel_name = case.snakeToCamel(self.name)

  return {
    name = self.name,
    kind = self.kind,
    pascal_name = pascal_name,
    camel_name = camel_name,
    app_class = pascal_name .. 'Application',
    suite_class = pascal_name .. 'Suite',
  }
end

function Module.unwrap(self: Module): Unwrapped
  return {
    project = self.parent.project:unwrap_project(),
    pom = self:unwrap_pom(),
    package = self:unwrap_package(),
    module = self:unwrap_module(),
    service = {
      path = '/api/' .. self.name
    },
    database = self.database,
    profiles = self:unwrap_profiles(),
    dependencies = Wrapper:unwrap_array(self.dependencies),
    plugins = self.plugins,
    configs = self.configs,
  }
end

return Module

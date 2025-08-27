--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Case = require('@lorry.utils/lib/Case')
local Wrapper = require('@lorry.project/lib/Wrapper')
local Project = require('@lorry.project/lib/Project')
local Profile = require('../Profile/Profile')
local SpringDatasource = require('../Profile/SpringDatasource')
local POM = require('../POM')
local Dependency = require('./Dependency')

local Module = {
  Dependency = Dependency,
}

export type Module = typeof(Module) & Wrapper.Unwrappable<Unwrapped> & {
  name: string,
  kind: string
}

export type ModuleProps = {
  parent: POM.POM,
  name: string,
  kind: string,
  database: SpringDatasource.SpringDatasource?,
  profiles: {[string]: Profile.Profile},
  plugins: {string},
  configs: {string},
  dependencies: {Dependency.Dependency},
}

export type ModuleImpl = Module & ModuleProps

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

export type Unwrapped = {
  project: Project.UnwrappedProject,
  pom: UnwrappedPOM,
  package: UnwrappedPackage,
  module: UnwrappedModule,
  service: {
    path: string,
  },
  database: SpringDatasource.Unwrapped?,
  profiles: {[string]: Profile.Unwrapped},
  dependencies: {Dependency.Unwrapped},
  plugins: {string},
  configs: {string},
}

export type ConfigurerFunc = (this: ModuleImpl) -> ()

export type AnyChild =
  | Dependency.Dependency

function Module:new(o: ModuleProps): Module
  return Meta:type(o, self, "Module")
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

function Module:configure(configurer: {ConfigurerFunc}): Module
  local this = self::ModuleImpl
  for _, func in configurer do
    func(this)
  end
  return this
end

function Module:setup(children: {AnyChild}): Module
  local this = self::ModuleImpl
  for _, child in children do
    this:with_child(child)
  end
  return self
end

function Module:with_child(child: AnyChild): Module
  local this = self::ModuleImpl
  local tag = Meta:typeof(child)
  if tag == 'Module.Dependency' then
    this.dependencies[#self.dependencies + 1] = child::Dependency.Dependency
  end
  return this
end

function Module:with_database(datasource: SpringDatasource.SpringDatasource): Module
  local this = self::ModuleImpl
  this.database = datasource
  return this
end

function Module:with_profile(name: string, profile: Profile.Profile): Module
  local this = self::ModuleImpl
  this.profiles[name] = profile
  return this
end

function Module:with_plugins(plugins: {string}): Module
  local this = self::ModuleImpl
  for _, name in plugins do
    this.plugins[#this.plugins + 1] = name
  end
  return this
end

function Module:with_configs(configs: {string}): Module
  local this = self::ModuleImpl
  for _, name in configs do
    this.configs[#this.configs + 1] = name
  end
  return this
end

function Module:with_dependency(group_id: string, artifact_id: string, version: string?): Module
  local this = self::ModuleImpl
  this:with_child(Dependency:from(group_id, artifact_id, version))
  return this
end

function Module:unwrap_package(): UnwrappedPackage
  local this = self::ModuleImpl
  local parent_pom = this.parent:unwrap_pom()
  local package_name = parent_pom.group_id .. '.' .. Case:snake_to_prop(this.name)
  return {
    name = package_name,
    path = Case:prop_to_path(package_name)
  }
end

function Module:unwrap_profiles(): {[string]: Profile.Unwrapped}
  local this = self::ModuleImpl
  local profiles = Meta:table {}
  for _, profile in this.profiles do
    profiles[profile.name] = profile:unwrap()
  end
  return profiles
end

function Module:unwrap_pom(): UnwrappedPOM
  local this = self::ModuleImpl
  return {
    artifact_id = this.name,
    parent = this.parent:unwrap_pom(),
    dependencies = Wrapper:unwrap_array(this.dependencies),
  }
end

function Module:unwrap_project()
  local this = self::ModuleImpl
  return this.parent:unwrap_project()
end

function Module:unwrap_module(): UnwrappedModule
  local this = self::ModuleImpl
  local pascal_name = Case:snake_to_pascal(this.name)
  local camel_name = Case:snake_to_camel(this.name)

  return {
    name = this.name,
    kind = this.kind,
    pascal_name = pascal_name,
    camel_name = camel_name,
    app_class = pascal_name .. 'Application',
    suite_class = pascal_name .. 'Suite',
  }
end

function Module:unwrap(): Unwrapped
  local this = self::ModuleImpl
  return {
    project = this:unwrap_project(),
    pom = this:unwrap_pom(),
    package = this:unwrap_package(),
    module = this:unwrap_module(),
    service = {
      path = '/api/' .. this.name
    },
    database = this.database and this.database:unwrap(),
    profiles = this:unwrap_profiles(),
    dependencies = Wrapper:unwrap_array(self.dependencies),
    plugins = this.plugins,
    configs = this.configs,
  }
end

return Module

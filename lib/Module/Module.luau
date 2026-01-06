--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Case = require('@lorry.utils/lib/Case')
local Wrapper = require('@lorry.project/lib/Wrapper')
local Project = require('@lorry.project/lib/Project')
local POM = require('../POM')
local Dependency = require('./Dependency')
local Reference = require('./Reference')

local Module = {
  Dependency = Dependency,
  Reference = Reference,
}

export type ModuleNature = 'app' | 'web' | 'data' | 'minio' | 'security'

export type Module = typeof(Module) & Wrapper.Unwrappable<Unwrapped> & {
  name: string,
  natures: {ModuleNature},
}

export type ModuleProps = {
  parent: POM.POM,
  name: string,
  natures: {ModuleNature},
  dependencies: {Dependency.Dependency},
  references: {Reference.Reference},
}

export type ModuleImpl = Module & ModuleProps

export type UnwrappedModule = {
  name: string,
  pascal_name: string,
  camel_name: string,
  snake_name: string,
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

export type UnwrappedService = {
  path: string,
}

export type Unwrapped = {
  project: Project.UnwrappedProject,
  pom: UnwrappedPOM,
  package: UnwrappedPackage,
  module: UnwrappedModule,
  service: UnwrappedService,
  natures: {ModuleNature},
  dependencies: {Dependency.Unwrapped},
  references: {Reference.Unwrapped},
}

export type ConfigurerFunc = (this: ModuleImpl) -> ()

export type AnyChild =
  | Dependency.Dependency
  | Reference.Reference

function Module:new(o: ModuleProps): Module
  return Meta:type(o, self, "Module")
end

function Module:from(parent: POM.POM, name: string): Module
  return Module:new({
    parent = parent,
    name = name,
    natures = Meta:array {},
    dependencies = Meta:array {},
    references = Meta:array {},
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
  elseif tag == 'Module.Reference' then
    this.references[#self.references + 1] = child::Reference.Reference
  end
  return this
end

function Module:with_natures(natures: {ModuleNature}): Module
  local this = self::ModuleImpl
  for _, nature in natures do
    this.natures[#this.natures + 1] = nature::ModuleNature
  end
  return this
end

function Module:with_dependency(group_id: string, artifact_id: string, version: string?): Module
  local this = self::ModuleImpl
  this:with_child(Dependency:from(group_id, artifact_id, version))
  return this
end

function Module:with_reference(module: Module): Module
  local this = self::ModuleImpl
  this:with_child(Reference:from(module::Reference.ReferenceTarget))
  return this
end

function Module:unwrap_package(): UnwrappedPackage
  local this = self::ModuleImpl
  local parent_pom = this.parent:unwrap_pom()
  local package_name = parent_pom.group_id .. '.' .. Case:any_to_prop(this.name)
  return {
    name = package_name,
    path = Case:prop_to_path(package_name)
  }
end

function Module:unwrap_pom(): UnwrappedPOM
  local this = self::ModuleImpl
  return {
    artifact_id = this.name,
    parent = this.parent:unwrap_pom(),
    dependencies = Wrapper:unwrap_array(this.dependencies),
  }
end

function Module:unwrap_project(): Project.UnwrappedProject
  local this = self::ModuleImpl
  return this.parent:unwrap_project()
end

function Module:unwrap_module(): UnwrappedModule
  local this = self::ModuleImpl
  local snake_name = Case:any_to_snake(this.name)
  local pascal_name = Case:snake_to_pascal(snake_name)
  local camel_name = Case:snake_to_camel(snake_name)
  return {
    name = Case:any_to_kebab(this.name),
    pascal_name = pascal_name,
    camel_name = camel_name,
    snake_name = snake_name,
  }
end

function Module:unwrap_service(): UnwrappedService
  local this = self::ModuleImpl
  return {
    path = '/api/' .. this.name
  }
end

function Module:unwrap(): Unwrapped
  local this = self::ModuleImpl
  return {
    project = this:unwrap_project(),
    pom = this:unwrap_pom(),
    package = this:unwrap_package(),
    module = this:unwrap_module(),
    service = this:unwrap_service(),
    natures = this.natures,
    dependencies = Wrapper:unwrap_array(this.dependencies),
    references = Wrapper:unwrap_array(this.references),
  }
end

return Module

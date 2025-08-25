--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Project = require('@develfish-repo.project/lib/Project')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local POM = {}

export type POM = typeof(POM)

export type POMProps = {
  project: Project.Project,
  group_id: string,
  artifact_id: string,
  version: string?,
  parent: POM?,
  modules: {string},
}

export type POMImpl = POM & POMProps & Wrapper.Unwrappable<Unwrapped>

export type Unwrapped = {
  project: Project.UnwrappedProject,
  pom: UnwrappedPOM,
  modules: {string}?,
}

export type UnwrappedPOM = {
  parent: Unwrapped?,
  group_id: string,
  artifact_id: string,
  version: string?,
  modules: {string}?,
}

function POM:new(o: POMProps): POM
  return Meta:type(o, self, "POM")
end

function POM:from_root(project: Project.Project, group_id: string, artifact_id: string, version: string?): POM
  return POM:new({
    project = project,
    group_id = group_id,
    version = version,
    artifact_id = artifact_id,
    parent = nil,
    modules = Meta:array {},
  })
end

function POM:from_parent(parent: POM, group_id: string, artifact_id: string, version: string?): POM
  return POM:new({
    project = (parent::POMImpl).project,
    group_id = group_id,
    version = version,
    artifact_id = artifact_id,
    parent = nil,
    modules = Meta:array {},
  })
end

function POM:with_group_id(group_id: string): POM
  local this = self::POMImpl
  this.group_id = group_id
  return this
end

function POM:with_artifact_id(artifact_id: string): POM
  local this = self::POMImpl
  this.artifact_id = artifact_id
  return this
end

function POM:with_version(version: string): POM
  local this = self::POMImpl
  this.version = version
  return self
end

function POM:with_parent(parent: POM): POM
  local this = self::POMImpl
  this.parent = parent
  return this
end

function POM:with_module(module: string): POM
  local this = self::POMImpl
  this.modules[#this.modules + 1] = module
  return this
end

function POM:unwrap_project(): Project.UnwrappedProject
  local this = self::POMImpl
  return this.project:unwrap_project()
end


function POM:unwrap_pom(): UnwrappedPOM
  local this = self::POMImpl
  return {
    parent = this.parent and this.parent:unwrap(),
    group_id = this.group_id,
    artifact_id = this.artifact_id,
    version = this.version,
    modules = this.modules,
  }
end

function POM:unwrap(): Unwrapped
  local this = self::POMImpl
  return {
    project = this.project:unwrap_project(),
    pom = this:unwrap_pom(),
  }
end

return POM

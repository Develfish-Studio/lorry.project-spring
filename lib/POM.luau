local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local Project = require('@develfish-repo.core/Project')

export type POM = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'POM',
  project: Project.Project,
  group_id: string,
  artifact_id: string,
  version: string,
  parent: POM?,
  modules: {string},

  with_group_id: (self: POM, group_id: string) -> POM,
  with_artifact_id: (self: POM, artifact_id: string) -> POM,
  with_version: (self: POM, version: string) -> POM,
  with_parent: (self: POM, parent: POM) -> POM,
  with_module: (self: POM, module: string) -> POM,

  unwrap_pom: (self: POM) -> UnwrappedPOM,
}

export type Unwrapped = {
  project: Project.UnwrappedProject,
  pom: UnwrappedPOM,
  modules: {string}?,
}

export type UnwrappedPOM = {
  parent: Unwrapped?,
  group_id: string,
  artifact_id: string,
  version: string,
}

local POM = {
  __type = 'POM',
  project = nil,
  group_id = nil,
  artifact_id = nil,
  version = '1.0-SNAPSHOT',
  parent = nil,
  modules = nil,
}

function POM:new(o): POM
  return Meta:type(o, self)
end

function POM:from(project: Project.Project, group_id: string, artifact_id: string, modules: {string}?): POM
  return POM:new({
    project = project,
    group_id = group_id,
    artifact_id = artifact_id,
    parent = nil,
    modules = modules or Meta:array {},
  })
end

function POM.with_group_id(self: POM, group_id: string): POM
  self.group_id = group_id
  return self
end

function POM.with_artifact_id(self: POM, artifact_id: string): POM
  self.artifact_id = artifact_id
  return self
end

function POM.with_version(self: POM, version: string): POM
  self.version = version
  return self
end

function POM.with_parent(self: POM, parent: POM): POM
  self.parent = parent
  return self
end

function POM.with_module(self: POM, module: string): POM
  self.modules[#self.modules + 1] = module
  return self
end

function POM.unwrap_pom(self: POM): UnwrappedPOM
  return {
    parent = self.parent and self.parent:unwrap(),
    group_id = self.group_id,
    artifact_id = self.artifact_id,
    version = self.version,
  }
end

function POM.unwrap(self: POM): Unwrapped
  return {
    project = self.project:unwrap_project(),
    pom = self:unwrap_pom(),
    modules = self.modules,
  }
end

return POM

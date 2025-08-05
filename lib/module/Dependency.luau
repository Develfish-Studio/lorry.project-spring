local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')

export type Dependency = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Dependency',
  group_id: string,
  artifact_id: string,
  version: string,
}

export type Unwrapped = {
  group_id: string,
  artifact_id: string,
  version: string,
}

local Dependency = {
  __type = 'Dependency',
  group_id = nil,
  artifact_id = nil,
  version = nil,
}

function Dependency:new(o): Dependency
  return Meta:type(o, self)
end

function Dependency:from(group_id: string, artifact_id: string, version: string): Dependency
  return Dependency:new({
    group_id = group_id,
    artifact_id = artifact_id,
    version = version,
  })
end

function Dependency.unwrap(self: Dependency): Unwrapped
  return {
    group_id = self.group_id,
    artifact_id = self.artifact_id,
    version = self.version,
  }
end

return Dependency

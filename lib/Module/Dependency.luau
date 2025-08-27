--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')

local Dependency = {}

export type Dependency = typeof(Dependency) & DependencyProps & Wrapper.Unwrappable<Unwrapped>

export type DependencyProps = {
  group_id: string,
  artifact_id: string,
  version: string?,
}

export type Unwrapped = DependencyProps

function Dependency:new(o: DependencyProps): Dependency
  return Meta:type(o, self, "Module.Dependency")
end

function Dependency:from(group_id: string, artifact_id: string, version: string?): Dependency
  return Dependency:new({
    group_id = group_id,
    artifact_id = artifact_id,
    version = version,
  })
end

function Dependency:unwrap(): Unwrapped
  local this = self::Dependency
  return {
    group_id = this.group_id,
    artifact_id = this.artifact_id,
    version = this.version,
  }
end

return Dependency

--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')
local POM = require('@root/lib/POM')

local Reference = {}

export type Reference = typeof(Reference) & ReferenceProps & Wrapper.Unwrappable<Unwrapped>

export type ReferenceTarget = any & Wrapper.Unwrappable<Unwrapped>

export type ReferenceProps = {
  target: ReferenceTarget,
}

export type Unwrapped = {
  pom: {
    artifact_id: string,
    parent: POM.UnwrappedPOM
  },
}

function Reference:new(o: ReferenceProps): Reference
  return Meta:type(o, self, "Module.Reference")
end

function Reference:from(target: ReferenceTarget): Reference
  return Reference:new({
    target = target,
  })
end

function Reference:unwrap(): Unwrapped
  local this = self::Reference
  return this.target:unwrap()
end

return Reference

local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local Module = require('@develfish-repo.spring/Module')

export type Assembly = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Assembly',
  module: Module.Module,
  nested_modules: {Module.Module},

  with_nested_module: (self: Assembly, nested_module: Module.Module) -> Assembly,
  with_nested_modules: (self: Assembly, nested_modules: {Module.Module}) -> Assembly,
}

export type Unwrapped = {
  pom: Module.UnwrappedPOM,
  package: Module.UnwrappedPackage,
  module: Module.UnwrappedModule,
  nested_modules: {Module.Unwrapped},
}

local Assembly = {
  module = nil,
  nested_modules = nil,
}

function Assembly:new(o): Assembly
  return Meta:type(o, self)
end

function Assembly:from(parent: Module.Module, nested_modules: {Module.Module}?): Assembly
  return Assembly:new({
    module = parent,
    nested_modules = nested_modules or Meta:array {},
  })
end

function Assembly.with_nested_module(self: Assembly, nested_module: Module.Module): Assembly
  self.nested_modules[#self.nested_modules + 1] = nested_module
  return self
end

function Assembly.with_nested_modules(self: Assembly, nested_modules: {Module.Module}): Assembly
  for _, m in nested_modules do
    self.nested_modules[#self.nested_modules + 1] = m
  end
  return self
end

function Assembly.unwrap(self: Assembly): Unwrapped
  return {
    pom = self.module:unwrap_pom(),
    package = self.module:unwrap_package(),
    module = self.module:unwrap_module(),
    nested_modules = Wrapper:unwrap_array(self.nested_modules)
  }
end

return Assembly

--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')
local Module = require('./Module/Module')

local Assembly = {}

export type Assembly = typeof(Assembly)

export type AssemblyProps = {
  module: Module.Module,
  nested_modules: {Module.Module},
}

export type Unwrapped = {
  pom: Module.UnwrappedPOM,
  package: Module.UnwrappedPackage,
  module: Module.UnwrappedModule,
  nested_modules: {Module.Unwrapped},
}

export type AssemblyImpl = Assembly & AssemblyProps & Wrapper.Unwrappable<Unwrapped>

export type ConfigurerFunc = (this: AssemblyImpl) -> ()

export type AnyChild =
  | Module.Module

function Assembly:new(o: AssemblyProps): Assembly
  return Meta:type(o, self, "Assembly")
end

function Assembly:from(parent: Module.Module, nested_modules: {Module.Module}?): Assembly
  return Assembly:new({
    module = parent,
    nested_modules = nested_modules or Meta:array {},
  })
end

function Assembly:configure(configurer: {ConfigurerFunc}): Assembly
  local this = self::AssemblyImpl
  for _, func in configurer do
    func(this)
  end
  return this
end

function Assembly:setup(children: {AnyChild}): Assembly
  local this = self::AssemblyImpl
  for _, child in children do
    this:with_child(child)
  end
  return this
end

function Assembly:with_child(child: AnyChild): Assembly
  local this = self::AssemblyImpl
  local tag = Meta:typeof(child)
  if tag == 'Module' then
    this.nested_modules[#this.nested_modules + 1] = child::Module.Module
  end
  return this
end

function Assembly:with_nested_module(nested_module: Module.Module): Assembly
  local this = self::AssemblyImpl
  this:with_child(nested_module)
  return this
end

function Assembly:with_nested_modules(nested_modules: {Module.Module}): Assembly
  local this = self::AssemblyImpl
  for _, m in nested_modules do
    this:with_child(m)
  end
  return this
end

function Assembly:unwrap(): Unwrapped
  local this = self::AssemblyImpl
  return {
    project = this.module:unwrap_project(),
    pom = this.module:unwrap_pom(),
    package = this.module:unwrap_package(),
    module = this.module:unwrap_module(),
    nested_modules = Wrapper:unwrap_array(this.nested_modules)
  }
end

return Assembly

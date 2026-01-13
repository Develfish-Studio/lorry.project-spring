--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Case = require('@lorry.utils/lib/Case')
local Wrapper = require('@lorry.project/lib/Wrapper')
local Project = require('@lorry.project/lib/Project')
local Module = require('../Module/Module')

local Listener = {}

export type Listener = typeof(Listener)

export type ListenerProps = {
  module: Module.Module,
  name: string,
  id: string?,
  container_factory: string?,
  topic_pattern: string?,
  group_id: string?,
  client_id_prefix: string?,
  concurrency: string?,
  batch: boolean?,
}

export type UnwrappedModule = {
  name: string,
  camel_name: string,
  pascal_name: string,
}

export type UnwrappedListener = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  kebab_name: string,
  id: string?,
  container_factory: string?,
  topic_pattern: string,
  group_id: string,
  client_id_prefix: string?,
  concurrency: string?,
  batch: boolean?,
}

export type Unwrapped = {
  project: Project.UnwrappedProject,
  module: UnwrappedModule,
  listener: UnwrappedListener,
  package: Module.UnwrappedPackage,
}

export type ListenerImpl = Listener & ListenerProps & Wrapper.Unwrappable<Unwrapped>

function Listener:new(o: ListenerProps): Listener
  return Meta:type(o, self, "Exchange.Listener")
end

function Listener:from(module: Module.Module, name: string, batch: boolean?): Listener
  return Listener:new({
    module = module,
    name = name,
    batch = batch,
  })
end

function Listener:with_id(id: string): Listener
  local this = self::ListenerImpl
  this.id = id
  return this
end

function Listener:with_container_factory(container_factory: string): Listener
  local this = self::ListenerImpl
  this.container_factory = container_factory
  return this
end

function Listener:with_topic_pattern(topic_pattern: string): Listener
  local this = self::ListenerImpl
  this.topic_pattern = topic_pattern
  return this
end

function Listener:with_group_id(group_id: string): Listener
  local this = self::ListenerImpl
  this.group_id = group_id
  return this
end

function Listener:with_client_id_prefix(client_id_prefix: string): Listener
  local this = self::ListenerImpl
  this.client_id_prefix = client_id_prefix
  return this
end

function Listener:with_concurrency(concurrency: string): Listener
  local this = self::ListenerImpl
  this.concurrency = concurrency
  return this
end

function Listener:with_batch(batch: boolean?): Listener
  local this = self::ListenerImpl
  this.batch = batch == nil or batch == true
  return this
end

function Listener:unwrap_listener(): UnwrappedListener
  local this = self::ListenerImpl
  local kebab_name = Case:snake_to_kebab(this.name)
  return {
    name = this.name,
    snake_name = this.name,
    camel_name = Case:snake_to_camel(this.name),
    pascal_name = Case:snake_to_pascal(this.name),
    kebab_name = kebab_name,
    id = this.id,
    container_factory = this.container_factory,
    topic_pattern = this.topic_pattern or kebab_name,
    group_id = this.group_id or this.module.name .. '.' .. this.name,
    client_id_prefix = this.client_id_prefix,
    concurrency = this.concurrency,
    batch = this.batch,
  }
end

function Listener:unwrap_module(): UnwrappedModule
  local this = self::ListenerImpl
  return {
    name = this.module.name,
    camel_name = Case:snake_to_camel(this.module.name),
    pascal_name = Case:snake_to_pascal(this.module.name),
  }
end

function Listener:unwrap(): Unwrapped
  local this = self::ListenerImpl
  return {
    project = this.module:unwrap_project(),
    module = this:unwrap_module(),
    listener = this:unwrap_listener(),
    package = this.module:unwrap_package(),
  }
end

return Listener

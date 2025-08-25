local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local Project = require('@develfish-repo.core/Project')
local Module = require('@develfish-repo.spring/Module')
local case = require('@develfish-repo.core/util/string/case')

export type Listener = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Listener',
  module: Module.Module,
  name: string,
  id: string?,
  container_factory: string?,
  topic_pattern: string?,
  group_id: string?,
  client_id_prefix: string?,
  concurrency: string?,
  batch: boolean,

  with_id: (self: Listener, id: string) -> Listener,
  with_container_factory: (self: Listener, container_factory: string) -> Listener,
  with_topic_pattern: (self: Listener, topic_pattern: string) -> Listener,
  with_group_id: (self: Listener, group_id: string) -> Listener,
  with_client_id_prefix: (self: Listener, client_id_prefix: string) -> Listener,
  with_concurrency: (self: Listener, concurrency: string) -> Listener,
  with_batch_flag: (self: Listener, batch: boolean) -> Listener,

  unwrap_listener: (self: Listener) -> UnwrappedListener,
  unwrap_module: (self: Listener) -> UnwrappedModule,
}

export type Unwrapped = {
  project: Project.UnwrappedProject,
  module: UnwrappedModule,
  listener: UnwrappedListener,
  package: Module.UnwrappedPackage,
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
  batch: boolean,
}

local Listener = {
  __type = 'Listener',
  module = nil,
  name = nil,
  id = nil,
  container_factory = nil,
  topic_pattern = nil,
  group_id = nil,
  client_id_prefix = nil,
  concurrency = nil,
  batch = false,
}

function Listener:new(o): Listener
  return Meta:type(o, self)
end

function Listener:from(module: Module.Module, name: string, batch: boolean?): Listener
  return Listener:new({
    module = module,
    name = name,
    batch = batch,
  })
end

function Listener.with_id(self: Listener, id: string): Listener
  self.id = id
  return self
end

function Listener.with_container_factory(self: Listener, container_factory: string): Listener
  self.container_factory = container_factory
  return self
end

function Listener.with_topic_pattern(self: Listener, topic_pattern: string): Listener
  self.topic_pattern = topic_pattern
  return self
end

function Listener.with_group_id(self: Listener, group_id: string): Listener
  self.group_id = group_id
  return self
end

function Listener.with_client_id_prefix(self: Listener, client_id_prefix: string): Listener
  self.client_id_prefix = client_id_prefix
  return self
end

function Listener.with_concurrency(self: Listener, concurrency: string): Listener
  self.concurrency = concurrency
  return self
end

function Listener.with_batch_flag(self: Listener, batch: boolean): Listener
  self.batch = batch
  return self
end

function Listener.unwrap_listener(self: Listener): UnwrappedListener
  return {
    name = self.name,
    snake_name = self.name,
    camel_name = case.snakeToCamel(self.name),
    pascal_name = case.snakeToPascal(self.name),
    kebab_name = case.snakeToKebab(self.name),
    id = self.id,
    container_factory = self.container_factory,
    topic_pattern = self.topic_pattern or self.name,
    group_id = self.group_id or self.module.name .. '.' .. self.name,
    client_id_prefix = self.client_id_prefix,
    concurrency = self.concurrency,
    batch = self.batch,
  }
end

function Listener.unwrap_module(self: Listener): UnwrappedModule
  return {
    name = self.module.name,
    camel_name = case.snakeToCamel(self.module.name),
    pascal_name = case.snakeToPascal(self.module.name),
  }
end

function Listener.unwrap(self: Listener): Unwrapped
  return {
    project = self.module.parent.project:unwrap_project(),
    module = self:unwrap_module(),
    listener = self:unwrap_listener(),
    package = self.module:unwrap_package(),
  }
end

return Listener

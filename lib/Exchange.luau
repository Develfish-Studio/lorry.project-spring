local case = require('@develfish-repo.core/util/string/case')
local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local Project = require('@develfish-repo.core/Project')
local Module = require('@develfish-repo.spring/Module')
local Topic = require('@develfish-repo.spring/exchange/Topic')

export type Exchange = Wrapper.Unwrappable<Unwrapped> & Wrapper.Copy<Exchange> & {
  module: Module.Module,
  name: string?,
  topics: {Topic.Topic},

  with_rules: (self: Exchange, children: {any}) -> Exchange,
  with_module: (self: Exchange, module: Module.Module) -> Exchange,
  with_topic: (self: Exchange, topic: Topic.Topic) -> Exchange,
  with_topics: (self: Exchange, topics: {Topic.Topic}) -> Exchange,

  unwrap_exchange: (self: Exchange) -> UnwrappedExchange,
}

export type Unwrapped = {
  project: Project.UnwrappedProject,
  module: Module.UnwrappedModule,
  package: Module.UnwrappedPackage,
  exchange: UnwrappedExchange,
  topics: {Topic.Unwrapped},
}

export type UnwrappedExchange = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  kebab_name: string,
}

local Exchange = {
  module = nil,
  name = nil,
  topics = nil,
}

function Exchange:new(o): Exchange
  return Meta:type(o, self)
end

function Exchange.copy(self: Exchange): Exchange
  return Exchange
    :from(self.module, self.name)
    :with_topics(self.topics)
end

function Exchange:from(module: Module.Module, name: string?): Exchange
  return Exchange:new({
    module = module,
    name = name,
    topics = Meta:array {},
  })
end

function Exchange.with_module(self: Exchange, module: Module.Module): Exchange
  self.module = module
  return self
end

function Exchange.with_topic(self: Exchange, topic: Topic.Topic): Exchange
  self.topics[#self.topics + 1] = topic
  return self
end

function Exchange.with_topics(self: Exchange, topics: {Topic.Topic}): Exchange
  for _, topic in topics do
    self.topics[#self.topics + 1] = topic
  end

  return self
end

function Exchange.with_rules(self: Exchange, children: {any}): Exchange
  children = children or {}

  for _, child in children do
    if child.__type == 'Topic' then
      self.topics[#self.topics + 1] = child::Topic.Topic
    end
  end

  return self
end

function Exchange.unwrap_exchange(self: Exchange): UnwrappedExchange
  local name = self.name or self.module.name

  return {
    name = name,
    snake_name = name,
    camel_name = case.snakeToCamel(name),
    pascal_name = case.snakeToPascal(name),
    kebab_name = case.snakeToKebab(name),
  }
end

function Exchange.unwrap(self: Exchange): Unwrapped
  return {
    project = self.module.parent.project:unwrap_project(),
    module = self.module:unwrap_module(),
    package = self.module:unwrap_package(),
    exchange = self:unwrap_exchange(),
    topics = Wrapper:unwrap_array(self.topics),
  }
end

return Exchange

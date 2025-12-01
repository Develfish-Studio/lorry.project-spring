--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Case = require('@lorry.utils/lib/Case')
local Wrapper = require('@lorry.project/lib/Wrapper')
local Project = require('@lorry.project/lib/Project')
local Module = require('../Module/Module')
local Topic = require('./Topic')

local Exchange = {
  Topic = Topic
}

export type Exchange = typeof(Exchange) & Wrapper.Unwrappable<Unwrapped>

export type ExchangeProps = {
  module: Module.Module,
  name: string?,
  topics: {Topic.Topic},
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

export type ExchangeImpl = Exchange & ExchangeProps & Wrapper.Copy<Exchange>

export type ConfigurerFunc = (this: ExchangeImpl) -> ()

export type AnyChild =
  | Topic.Topic


function Exchange:new(o: ExchangeProps): Exchange
  return Meta:type(o, self)
end

function Exchange:copy(): Exchange
  local this = self::ExchangeImpl
  return Exchange
    :from(this.module, this.name)
    :with_topics(this.topics)
end

function Exchange:from(module: Module.Module, name: string?): Exchange
  return Exchange:new({
    module = module,
    name = name,
    topics = Meta:array {},
  })
end

function Exchange:configure(configurer: {ConfigurerFunc}): Exchange
  local this = self::ExchangeImpl
  for _, func in configurer do
    func(this)
  end
  return this
end

function Exchange:setup(children: {AnyChild}): Exchange
  local this = self::ExchangeImpl
  for _, child in children do
    this:with_child(child)
  end
  return self
end

function Exchange:with_child(child: AnyChild): Exchange
  local this = self::ExchangeImpl
  local tag = Meta:typeof(child)
  if tag == 'Exchange.Topic' then
    this.topics[#this.topics + 1] = child::Topic.Topic
  end
  return this
end

function Exchange:with_module(module: Module.Module): Exchange
  local this = self::ExchangeImpl
  this.module = module
  return this
end

function Exchange:with_topic(topic: Topic.Topic): Exchange
  local this = self::ExchangeImpl
  this:with_child(topic)
  return this
end

function Exchange.with_topics(self: Exchange, topics: {Topic.Topic}): Exchange
  local this = self::ExchangeImpl
  for _, topic in topics do
    this:with_child(topic)
  end
  return this
end

function Exchange.unwrap_exchange(self: Exchange): UnwrappedExchange
  local this = self::ExchangeImpl
  local name = this.name or Case:any_to_snake(this.module.name)
  return {
    name = name,
    snake_name = name,
    camel_name = Case:snake_to_camel(name),
    pascal_name = Case:snake_to_pascal(name),
    kebab_name = Case:snake_to_kebab(name),
  }
end

function Exchange:unwrap(): Unwrapped
  local this = self::ExchangeImpl
  return {
    project = this.module:unwrap_project(),
    module = this.module:unwrap_module(),
    package = this.module:unwrap_package(),
    exchange = this:unwrap_exchange(),
    topics = Wrapper:unwrap_array(this.topics),
  }
end

return Exchange

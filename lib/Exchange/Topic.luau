--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Case = require('@lorry.utils/lib/Case')
local Wrapper = require('@lorry.project/lib/Wrapper')

local Topic = {}

export type Topic = typeof(Topic) & TopicProps & Wrapper.Unwrappable<Unwrapped>

export type TopicProps = {
  name: string,
  partitions: number?,
  replicas: number?,
  compact: boolean?,
}

export type Unwrapped = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  kebab_name: string,
  partitions: number?,
  replicas: number?,
  compact: boolean?,
}

function Topic:new(o: TopicProps): Topic
  return Meta:type(o, self, 'Exchange.Topic')
end

function Topic:from(name: string, partitions: number?, replicas: number?, compact: boolean?): Topic
  return Topic:new({
    name = name,
    partitions = partitions,
    replicas = replicas,
    compact = compact,
  })
end

function Topic:with_partitions(partitions: number): Topic
  local this = self::Topic
  this.partitions = partitions
  return this
end

function Topic:with_replicas(replicas: number): Topic
  local this = self::Topic
  this.replicas = replicas
  return this
end

function Topic:with_compact(compact: boolean): Topic
  local this = self::Topic
  this.compact = compact
  return this
end

function Topic:unwrap(): Unwrapped
  local this = self::Topic
  return {
    name = this.name,
    snake_name = this.name,
    camel_name = Case:snake_to_camel(this.name),
    pascal_name = Case:snake_to_pascal(this.name),
    kebab_name = Case:snake_to_kebab(this.name),
    partitions = this.partitions,
    replicas = this.replicas,
    compact = this.compact,
  }
end

return Topic

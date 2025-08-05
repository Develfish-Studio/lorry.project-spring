local case = require('@develfish-repo.core/util/string/case')
local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')

export type Topic = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Topic',
  name: string,
  partitions: number,
  replicas: number,
  compact: boolean?,

  with_partitions: (self: Topic, partitions: number) -> Topic,
  with_replicas: (self: Topic, replicas: number) -> Topic,
  with_compact: (self: Topic, compact: boolean) -> Topic,
}

export type Unwrapped = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  kebab_name: string,
  partitions: number,
  replicas: number,
  compact: boolean?,
}

local Topic = {
  __type = 'Topic',
  name = nil,
  partitions = 1,
  replicas = 1,
  compact = nil,
}

function Topic:new(o): Topic
  return Meta:type(o, self)
end

function Topic:from(name: string, partitions: number?, replicas: number?, compact: boolean?): Topic
  return Topic:new({
    name = name,
    partitions = partitions,
    replicas = replicas,
    compact = compact,
  })
end

function Topic.with_partitions(self: Topic, partitions: number): Topic
  self.partitions = partitions
  return self
end

function Topic.with_replicas(self: Topic, replicas: number): Topic
  self.replicas = replicas
  return self
end

function Topic.with_compact(self: Topic, compact: boolean): Topic
  self.compact = compact
  return self
end

function Topic.unwrap(self: Topic): Unwrapped
    return {
      name = self.name,
      snake_name = self.name,
      camel_name = case.snakeToCamel(self.name),
      pascal_name = case.snakeToPascal(self.name),
      kebab_name = case.snakeToKebab(self.name),
      partitions = self.partitions,
      replicas = self.replicas,
      compact = self.compact,
    }
end

return Topic

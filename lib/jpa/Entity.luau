local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local PK = require('@develfish-repo.spring/jpa/PK')
local Ref = require('@develfish-repo.spring/jpa/Ref')
local Prop = require('@develfish-repo.spring/jpa/Prop')
local Formula = require('@develfish-repo.spring/jpa/Formula')

export type Entity = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Entity',
  table: string,
  schema: string,
  keys: {PK.PK},
  columns: {Prop.Prop},
  refs: {Ref.Ref},
  formulas: {Formula.Formula},

  with_columns: (self: Entity, children: {any}) -> Entity,

  unwrap_keys: (self: Entity) -> UnwrappedIndexed<PK.Unwrapped>,
  unwrap_columns: (self: Entity) -> UnwrappedIndexed<Prop.Unwrapped>,
  unwrap_refs: (self: Entity) -> UnwrappedIndexed<Ref.Unwrapped>,
  unwrap_formulas: (self: Entity) -> UnwrappedIndexed<Formula.Unwrapped>,
}

export type Unwrapped = {
  pk: PK.Unwrapped?,
  schema: string,
  table: string,
  keys: {PK.Unwrapped},
  columns: {Prop.Unwrapped},
  refs: {Ref.Unwrapped},
  formulas: {Formula.Unwrapped},
}

export type UnwrappedIndexed<T> = {
  by_name: {[string]: T},
  array: {T}
}

local Entity = {
  __type = 'Entity',
  table = nil,
  schema = nil,
  keys = nil,
  columns = nil,
  refs = nil,
  formulas = nil,
}

function Entity:new(o): Entity
  return Meta:type(o, self)
end

function Entity:from(name: string, children: {any}): Entity
  local schema, table = name:match("([^.]+).([^.]+)")

  return Entity
    :new({
      schema = schema,
      table = table,
      keys = Meta:array {},
      columns = Meta:array {},
      refs = Meta:array {},
      formulas = Meta:array {}
    })
    :with_columns(children or Meta:array {})
end

function Entity.with_columns(self: Entity, children: {any}): Entity
  for _, child in children do
    if child.__type == 'PK' then
      self.keys[#self.keys + 1] = child::PK.PK
    elseif child.__type == 'Prop' then
      self.columns[#self.columns + 1] = child::Prop.Prop
    elseif child.__type == 'Ref' then
      self.refs[#self.refs + 1] = child::Ref.Ref
    elseif child.__type == 'Formula' then
      self.formulas[#self.formulas + 1] = child::Formula.Formula
    end
  end

  return self
end

function Entity.unwrap_keys(self: Entity): UnwrappedIndexed<PK.Unwrapped>
  local by_name = Meta:table {}
  local array = Meta:array {}

  for i, key in self.keys do
    local unwrapped = key:unwrap()
    array[#array + 1] = unwrapped
    by_name[unwrapped.name] = unwrapped
  end

  return {
    by_name = by_name,
    array = array,
  }
end

function Entity.unwrap_columns(self: Entity): UnwrappedIndexed<Prop.Unwrapped>
  local by_name = Meta:table {}
  local array = Meta:array {}

  for i, column in self.columns do
    local unwrapped = column:unwrap()
    array[#array + 1] = unwrapped
    by_name[unwrapped.name] = unwrapped
  end

  return {
    by_name = by_name,
    array = array,
  }
end

function Entity.unwrap_refs(self: Entity): UnwrappedIndexed<Ref.Unwrapped>
  local by_name = Meta:table {}
  local array = Meta:array {}

  for i, ref in self.refs do
    local unwrapped = ref:unwrap()
    array[#array + 1] = unwrapped
    by_name[unwrapped.name] = unwrapped
  end

  return {
    by_name = by_name,
    array = array,
  }
end

function Entity.unwrap_formulas(self: Entity): UnwrappedIndexed<Formula.Unwrapped>
  local by_name = Meta:table {}
  local array = Meta:array {}

  for i, formula in self.formulas do
    local unwrapped = formula:unwrap()
    array[#array + 1] = unwrapped
    by_name[unwrapped.name] = unwrapped
  end

  return {
    by_name = by_name,
    array = array,
  }
end

function Entity.unwrap(self: Entity): Unwrapped
  local pk = (if #self.keys > 0 then self.keys[1] else nil)

  return {
    pk = pk and pk:unwrap() or nil,
    schema = self.schema,
    table = self.table,
    keys = self:unwrap_keys(),
    columns = self:unwrap_columns(),
    refs = self:unwrap_refs(),
    formulas = self:unwrap_formulas(),
  }
end

return Entity

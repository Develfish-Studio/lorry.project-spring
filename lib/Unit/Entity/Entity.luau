--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')
local Key = require('./Key')
local Ref = require('./Ref')
local Prop = require('./Prop')
local Formula = require('./Formula')

local Entity = {
  Key = Key,
  Ref = Ref,
  Prop = Prop,
  Formula = Formula,
}

export type Entity = typeof(Entity) & Wrapper.Unwrappable<Unwrapped>

export type EntityProps = {
  table: string,
  schema: string,
  keys: {Key.Key},
  columns: {Prop.Prop},
  refs: {Ref.Ref},
  formulas: {Formula.Formula},
}

export type Unwrapped = {
  schema: string,
  table: string,
  keys: {Key.Unwrapped},
  columns: {Prop.Unwrapped},
  refs: {Ref.Unwrapped},
  formulas: {Formula.Unwrapped},
}

export type UnwrappedIndexed<T> = {
  by_name: {[string]: T},
  array: {T}
}

export type EntityImpl = Entity & EntityProps

export type ConfigurerFunc = (this: EntityImpl) -> ()

export type AnyChild =
  | Key.Key
  | Prop.Prop
  | Ref.Ref
  | Formula.Formula

function Entity:new(o: EntityProps): Entity
  return Meta:type(o, self, 'Unit.Entity')
end

function Entity:from(name: string, children: {any}): Entity
  local schema, table = name:match("([^.]+).([^.]+)")
  assert(schema ~= nil)
  assert(table ~= nil)
  return Entity
    :new({
      schema = schema,
      table = table,
      keys = Meta:array {},
      columns = Meta:array {},
      refs = Meta:array {},
      formulas = Meta:array {}
    })
    :setup(children or Meta:array {})
end

function Entity:configure(configurer: {ConfigurerFunc}): Entity
  local this = self::EntityImpl
  for _, func in configurer do
    func(this)
  end
  return this
end

function Entity:setup(children: {AnyChild}): Entity
  local this = self::EntityImpl
  for _, child in children do
    this:with_child(child)
  end
  return self
end

function Entity:with_child(child: AnyChild): Entity
  local this = self::EntityImpl
  local tag = Meta:typeof(child)
  if tag == 'Unit.Entity.Key' then
      this.keys[#this.keys + 1] = child::Key.Key
    elseif tag == 'Unit.Entity.Prop' then
      this.columns[#this.columns + 1] = child::Prop.Prop
    elseif tag == 'Unit.Entity.Ref' then
      this.refs[#this.refs + 1] = child::Ref.Ref
    elseif tag == 'Unit.Entity.Formula' then
      this.formulas[#this.formulas + 1] = child::Formula.Formula
    end
  return this
end

function Entity:unwrap_keys(): UnwrappedIndexed<Key.Unwrapped>
  local this = self::EntityImpl
  local by_name = Meta:table {}
  local array = Meta:array {}

  for i, key in this.keys do
    local unwrapped = key:unwrap()
    array[#array + 1] = unwrapped
    by_name[unwrapped.name] = unwrapped
  end

  return {
    by_name = by_name,
    array = array,
  }
end

function Entity:unwrap_columns(): UnwrappedIndexed<Prop.Unwrapped>
  local this = self::EntityImpl
  local by_name = Meta:table {}
  local array = Meta:array {}

  for i, column in this.columns do
    local unwrapped = column:unwrap()
    array[#array + 1] = unwrapped
    by_name[unwrapped.name] = unwrapped
  end

  return {
    by_name = by_name,
    array = array,
  }
end

function Entity:unwrap_refs(): UnwrappedIndexed<Ref.Unwrapped>
  local this = self::EntityImpl
  local by_name = Meta:table {}
  local array = Meta:array {}

  for i, ref in this.refs do
    local unwrapped = ref:unwrap()
    array[#array + 1] = unwrapped
    by_name[unwrapped.name] = unwrapped
  end

  return {
    by_name = by_name,
    array = array,
  }
end

function Entity:unwrap_formulas(): UnwrappedIndexed<Formula.Unwrapped>
  local this = self::EntityImpl
  local by_name = Meta:table {}
  local array = Meta:array {}

  for i, formula in this.formulas do
    local unwrapped = formula:unwrap()
    array[#array + 1] = unwrapped
    by_name[unwrapped.name] = unwrapped
  end

  return {
    by_name = by_name,
    array = array,
  }
end

function Entity:unwrap(): Unwrapped
  local this = self::EntityImpl

  return {
    schema = this.schema,
    table = this.table,
    keys = this:unwrap_keys(),
    columns = this:unwrap_columns(),
    refs = this:unwrap_refs(),
    formulas = this:unwrap_formulas(),
  }
end

return Entity

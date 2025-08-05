local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')

export type Override = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Override',
  name: string,
  expression: string?,
  context_value: string?,
  value: string?,
  is_hidden: boolean,

  with_expression: (self: Override, expression: string) -> Override,
  with_context_value: (self: Override, context_value: string) -> Override,
  with_value: (self: Override, value: string) -> Override,
  with_hidden: (self: Override) -> Override,
}

export type Unwrapped = {
  name: string,
  value: string?,
  context_value: Wrapper.UnwrappedName?,
  expression: string?,
  is_hidden: boolean,
}

export type Data = {
  value: string?,
  expression: string?,
  context_value: string?,
  is_hidden: boolean,
}

export type UnwrappedContextValue = {
  name: string,
  snake_name: string,
  camel_name: string,
  pascal_name: string,
  kebab_name: string,
}

local Override = {
  __type = 'Override',
  name = nil,
  expression = nil,
  context_value = nil,
  value = nil,
  is_hidden = false,
}

function Override:new(o): Override
  return Meta:type(o, self)
end

function Override:from(name: string, options: Data): Override
  options = options or Meta:table({})
  return Override:new({
    name = name,
    expression = options.expression,
    context_value = options.context_value,
    value = options.value,
    is_hidden = options.is_hidden,
  })
end

function Override:from_context(name: string, context_value: string?): Override
  return Override:from(name, {
    is_hidden = true,
    context_value = context_value or name
  })
end

function Override:from_value(name: string, value: string): Override
  return Override:from(name, {
    is_hidden = true,
    value = value
  })
end

function Override:from_expression(name: string, expression: string): Override
  return Override:from(name, {
    is_hidden = true,
    expression = expression
  })
end

function Override:from_hidden(name: string): Override
  return Override:from(name, {
    is_hidden = true,
  })
end

function Override.with_expression(self: Override, expression: string): Override
  self.expression = expression
  return self
end

function Override.with_context_value(self: Override, context_value: string): Override
  self.context_value = context_value
  return self
end

function Override.with_value(self: Override, value: string): Override
  self.value = value
  return self
end

function Override.with_hidden(self: Override): Override
  self.is_hidden = true
  return self
end

function Override.unwrap(self: Override): Unwrapped
  return {
    name = self.name,
    value = self.value,
    context_value = Wrapper:unwrap_name_or_nil(self.context_value),
    expression = self.expression,
    is_hidden = self.is_hidden,
  }
end

return Override

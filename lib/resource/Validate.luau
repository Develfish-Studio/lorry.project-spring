local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local Arg = require('@develfish-repo.spring/validate/Arg')

export type Validate = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Validate',

  status_code: number,
  message: string,
  predicate: string?,
  args: {Arg.Arg},

  with_rules: (self: Validate, children: {any}) -> Validate,
}

export type Unwrapped = {
}

local Validate = {
  __type = 'Validate',

  Arg = Arg,

  status_code = 400,
  message = 'Bad Request',
  predicate = nil,
  args = nil,
}

function Validate:new(o): Validate
  return Meta:type(o, self)
end

function Validate:from(predicate: string, args: {Arg.Arg}?): Validate
  return Validate:new({
    predicate = predicate,
    args = args or Meta:array({}),
  })
end

function Validate:equals(a_path: string, b_path: string): Validate
  return Validate:from('equals'):with_rules {
    Arg:from_path(a_path),
    Arg:from_path(b_path),
  }
end

function Validate:not_null(path: string): Validate
  return Validate:from('notNull'):with_rules {
    Arg:from_path(path),
  }
end

function Validate:is_true(path: string): Validate
  return Validate:from('isTrue'):with_rules {
    Arg:from_path(path),
  }
end

function Validate.with_status(self: Validate, status_code: number, message: string): Validate
  self.status_code = status_code
  self.message = message
  return self
end

function Validate.with_status_code(self: Validate, status_code: number): Validate
  self.status_code = status_code
  return self
end

function Validate.with_message(self: Validate, message: string): Validate
  self.message = message
  return self
end

function Validate.with_rules(self: Validate, children: {any}): Validate
  children = children or Meta:array({})

  for _, child in children do
    if child.__type == 'Arg' then
      self.args[#self.args + 1] = child::Arg.Arg
    end
  end

  return self
end

function Validate.unwrap(self: Validate): Unwrapped
  return {
    status_code = self.status_code,
    message = self.message,
    predicate = self.predicate,
    args = Wrapper:unwrap_array(self.args),
  }
end

return Validate

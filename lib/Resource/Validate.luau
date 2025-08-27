--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')
local Arg = require('./Arg')

local Validate = {
  Arg = Arg,
}

export type Validate = typeof(Validate)

export type ValidateProps = {
  status_code: number,
  message: string,
  predicate: string?,
  args: {Arg.Arg},
}

export type Unwrapped = {
  status_code: number,
  message: string,
  predicate: string?,
  args: {Arg.Unwrapped},
}

export type ValidateImpl = Validate & ValidateProps & Wrapper.Unwrappable<Unwrapped>

export type ConfigurerFunc = (this: ValidateImpl) -> ()

export type AnyChild =
  | Arg.Arg

function Validate:new(o: ValidateProps): Validate
  return Meta:type(o, self, "Resource.Validate")
end

function Validate:from(predicate: string, args: {Arg.Arg}?): Validate
  return Validate:new({
    status_code = 400,
    message = 'Bad Request',
    predicate = predicate,
    args = args or Meta:array({}),
  })
end

function Validate:equals(a_path: string, b_path: string): Validate
  return Validate:from('equals'):setup {
    Arg:from_path(a_path),
    Arg:from_path(b_path),
  }
end

function Validate:not_null(path: string): Validate
  return Validate:from('notNull'):setup {
    Arg:from_path(path),
  }
end

function Validate:is_true(path: string): Validate
  return Validate:from('isTrue'):setup {
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

function Validate:configure(configurer: {ConfigurerFunc}): Validate
  local this = self::ValidateImpl
  for _, func in configurer do
    func(this)
  end
  return this
end

function Validate:setup(children: {AnyChild}): Validate
  local this = self::ValidateImpl
  for _, child in children do
    this:with_child(child)
  end
  return this
end

function Validate:with_child(child: AnyChild): Validate
  local this = self::ValidateImpl
  local tag = Meta:typeof(child)
  if tag == 'Resource.Arg' then
    this.args[#this.args + 1] = child::Arg.Arg
  end
  return this
end

function Validate:unwrap(): Unwrapped
  local this = self::ValidateImpl
  return {
    status_code = this.status_code,
    message = this.message,
    predicate = this.predicate,
    args = Wrapper:unwrap_array(this.args),
  }
end

return Validate

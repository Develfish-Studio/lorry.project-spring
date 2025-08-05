local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')

export type Datasource = Config & Wrapper.Unwrappable<Unwrapped> & Wrapper.Copy<Datasource> & {
}

export type Config = {
  url: string,
  username: string?,
  password: string?,
}

export type Unwrapped = {
  url: string,
  username: string?,
  password: string?,
}

local Datasource = {
  __type = 'Datasource',
  url = nil,
  username = nil,
  password = nil,
}

function Datasource:new(o): Datasource
  return Meta:type(o, self)
end

function Datasource:from_config(config: Config): Datasource
  return Datasource:new({
    url = config.url,
    username = config.username,
    password = config.password,
  })
end

function Datasource.copy(self: Datasource): Datasource
  return Datasource:new({
    url = self.url,
    username = self.username,
    password = self.password,
  })
end

function Datasource.unwrap(self: Datasource): Unwrapped
  return {
    url = self.url,
    username = self.username,
    password = self.password,
  }
end

return Datasource

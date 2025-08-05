local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')

export type Server = Wrapper.Unwrappable<Unwrapped> & Wrapper.Copy<Server> & {
  __type: 'Server',
  port: number,
  with_port: (self: Server, port: number) -> Server,
}

export type Unwrapped = {
  port: number,
}

local Server = {
  __type = 'Server',
  port = nil,
}

function Server:new(o): Server
  return Meta:type(o, self)
end

function Server:from(port: number)
  return Server:new({
    port = port,
  })
end

function Server.with_port(self: Server, port: number): Server
  self.port = port
  return self
end

function Server.copy(self: Server): Server
  return Server:new({
    port = self.port,
  })
end

function Server.unwrap(self: Server): Unwrapped
  return {
    port = self.port,
  }
end

return Server

--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local Server = {}

export type Server = typeof(Server) & ServerProps & Wrapper.Unwrappable<Unwrapped> & Wrapper.Copy<Server>

export type ServerProps = {
  port: number,
}

export type Unwrapped = ServerProps

function Server:new(o: ServerProps): Server
  return Meta:type(o, self, "Profile.Server")
end

function Server:from_port(port: number)
  return Server:new({
    port = port,
  })
end

function Server:with_port(port: number): Server
  local this = self::Server
  this.port = port
  return this
end

function Server:copy(): Server
  local this = self::Server
  return Server:new(this:unwrap())
end

function Server:unwrap(): Unwrapped
  local this = self::Server
  return {
    port = this.port,
  }
end

return Server

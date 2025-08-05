local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')

export type OpenIdClient = Config & Wrapper.Unwrappable<Unwrapped> & Wrapper.Copy<OpenIdClient> & {
  __type: 'OpenIdClient',
}

export type Config = {
  issuer_uri: string?,
  client_id: string?,
  client_secret: string?,
  redirect_uri: string?,
}

export type Unwrapped = {
  client: {
    ["issuer-uri"]: string?,
    ["client-id"]: string?,
    ["client-secret"]: string?,
    ["redirect-uri"]: string?
  }
}

local OpenIdClient = {
  __type = 'OpenIdClient',
  issuer_uri = nil,
  client_id = nil,
  client_secret = nil,
  redirect_uri = nil
}

function OpenIdClient:new(o): OpenIdClient
  return Meta:type(o, self)
end

function OpenIdClient:from_config(config: Config): OpenIdClient
  return OpenIdClient:new({
    client_id = config.client_id,
    client_secret = config.client_secret,
    issuer_uri = config.issuer_uri,
    redirect_uri = config.redirect_uri,
  })
end

function OpenIdClient.copy(self: OpenIdClient): OpenIdClient
  return OpenIdClient:new({
    client_id = self.client_id,
    client_secret = self.client_secret,
    issuer_uri = self.issuer_uri,
    redirect_uri = self.redirect_uri,
  })
end

function OpenIdClient.unwrap(self: OpenIdClient): Unwrapped
  return {
    client = {
      ["issuer-uri"] = self.issuer_uri,
      ["client-id"] = self.client_id,
      ["client-secret"] = self.client_secret,
      ["redirect-uri"] = self.redirect_uri
    }
  }
end

return OpenIdClient

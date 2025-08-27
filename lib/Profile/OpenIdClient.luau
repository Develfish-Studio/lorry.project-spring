--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')
local PropTypes = require('@lorry.project/lib/PropTypes')

local OpenIdClient = {}

export type OpenIdClient = typeof(OpenIdClient) & Wrapper.Unwrappable<Unwrapped> & Wrapper.Copy<OpenIdClient>

export type OpenIdClientProps = {
  issuer_uri: string,
  client_id: string,
  client_secret: string,
  redirect_uri: string,
}

export type OpenIdClientImpl = OpenIdClient & OpenIdClientProps

export type Unwrapped = {
  client: {
    ["issuer-uri"]: string,
    ["client-id"]: string,
    ["client-secret"]: string,
    ["redirect-uri"]: string
  }
}

function OpenIdClient:new(o: OpenIdClientProps): OpenIdClient
  return Meta:type(o, self, "Profile.OpenIdClient")
end

function OpenIdClient:from_remote(remote: PropTypes.OpenidRemote): OpenIdClient
  return OpenIdClient:new({
    client_id = remote.client_id,
    client_secret = remote.client_secret,
    issuer_uri = remote.issuer_uri,
    redirect_uri = remote.redirect_uri,
  })
end

function OpenIdClient:copy(): OpenIdClient
  local this = self::OpenIdClientImpl
  return OpenIdClient:new({
    client_id = this.client_id,
    client_secret = this.client_secret,
    issuer_uri = this.issuer_uri,
    redirect_uri = this.redirect_uri,
  })
end

function OpenIdClient:unwrap(): Unwrapped
  local this = self::OpenIdClientImpl
  return {
    client = {
      ["issuer-uri"] = this.issuer_uri,
      ["client-id"] = this.client_id,
      ["client-secret"] = this.client_secret,
      ["redirect-uri"] = this.redirect_uri
    }
  }
end

return OpenIdClient

local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local ARRAY = require('@develfish-repo.core/util/array')
local OBJECT = require('@develfish-repo.core/util/object')
local Datasource = require('@develfish-repo.spring/profile/Datasource')
local Entry = require('@develfish-repo.spring/profile/Entry')
local MinioClient = require('@develfish-repo.spring/profile/MinioClient')
local OpenIdClient = require('@develfish-repo.spring/profile/OpenIdClient')
local Server = require('@develfish-repo.spring/profile/Server')

export type Profile = Wrapper.Unwrappable<Unwrapped> & Wrapper.Copy<Profile> & {
  __type: 'Profile',

  name: string,
  server: Server.Server?,
  spring_datasource: Datasource.Datasource?,
  app_minio_client: MinioClient.MinioClient?,
  app_openid_client: OpenIdClient.OpenIdClient?,
  app_entries: {Entry.Entry},
  trace_sql: boolean,

  with_rules: (self: Profile, children: {any}) -> Profile,
  with_server_port: (self: Profile, port: number) -> Profile,
  with_spring_datasource: (self: Profile, datasource: Datasource.Config) -> Profile,
  with_app_openid_client: (self: Profile, openid_client: OpenIdClient.Config) -> Profile,
  with_app_minio_client: (self: Profile, minio_client: MinioClient.Config) -> Profile,
  with_app_entry: (self: Profile, name: string, config: Entry.Data) -> Profile,
  with_trace_sql: (self: Profile) -> Profile,

  unwrap_app: (self: Profile) -> UnwrappedApp,
  unwrap_spring: (self: Profile) -> UnwrappedSpring,
  unwrap_spring_jpa: (self: Profile) -> UnwrappedSpringJPA,
}

export type Unwrapped = {
  server: Server.Unwrapped?,
  spring: UnwrappedSpring?,
  app: UnwrappedApp?,
}

export type UnwrappedSpring = {
  jpa: UnwrappedSpringJPA?,
  datasource: Datasource.Unwrapped?,
}

export type UnwrappedSpringJPA = {
  ['show-sql']: boolean,
  properties: {
    hibernate: {
      format_sql: boolean,
    }
  }
}

export type UnwrappedApp = {
  minio: MinioClient.Unwrapped?,
  openid: OpenIdClient.Unwrapped?,
  [string]: Entry.Data,
}

local Profile = {
  __type = 'Profile',

  Entry = Entry,
  Datasource = Datasource,
  MinioClient = MinioClient,
  OpenIdClient = OpenIdClient,
  Server = Server,

  name = nil,
  server = nil,
  spring_datasource = nil,
  app_minio_client = nil,
  app_openid_client = nil,
  app_entries = nil,
  trace_sql = false
}

function Profile:new(o): Profile
  return Meta:type(o, self)
end

function Profile:from(name: string): Profile
  assert(name ~= nil)
  return Profile:new({
    name = name,
    app_entries = Meta:array {},
  })
end

function Profile.with_rules(self: Profile, children: {any}): Profile
  children = children or {}

  for _, child in children do
    if child.__type == 'Entry' then
      self.app_entries[#self.app_entries + 1] = child
    elseif child.__type == 'Datasource' then
      self.spring_datasource = child::Datasource.Datasource
    elseif child.__type == 'MinioClient' then
      self.app_minio_client = child::MinioClient.MinioClient
    elseif child.__type == 'OpenIdClient' then
      self.app_openid_client = child::OpenIdClient.OpenIdClient
    elseif child.__type == 'Server' then
      self.server = child::Server.Server
    end
  end

  return self
end

function Profile.with_server_port(self: Profile, port: number): Profile
  if self.server == nil then
    self.server = Server:from(port)
  else
    self.server:with_port(port)
  end
  return self
end

function Profile.with_spring_datasource(self: Profile, datasource: Datasource.Config): Profile
  self.spring_datasource = Datasource:from_config(datasource)
  return self
end

function Profile.with_app_openid_client(self: Profile, openid_client: OpenIdClient.Config): Profile
  self.app_openid_client = OpenIdClient:from_config(openid_client)
  return self
end

function Profile.with_app_minio_client(self: Profile, minio_client: MinioClient.Config): Profile
  self.app_minio_client = MinioClient:from_config(minio_client)
  return self
end

function Profile.with_app_entry(self: Profile, name: string, config: Entry.Data): Profile
  self.app_entries[#self.app_entries + 1] = Entry:from(name, config)
  return self
end

function Profile.with_trace_sql(self: Profile): Profile
  self.trace_sql = true
  return self
end

function Profile.unwrap_spring_jpa(self: Profile): UnwrappedSpringJPA?
  if self.trace_sql == true then
    return {
      ['show-sql'] = true,
      properties = {
        hibernate = {
          format_sql = true
        }
      }
    }
  end
  return nil
end

function Profile.unwrap_spring(self: Profile): UnwrappedSpring
  return {
    jpa = self:unwrap_spring_jpa(),
    datasource = self.spring_datasource and self.spring_datasource:unwrap() or nil,
  }
end

function Profile.unwrap_app(self: Profile): UnwrappedApp?
  local config = {
    minio = self.app_minio_client ~= nil and self.app_minio_client:unwrap() or nil,
    openid = self.app_openid_client ~= nil and self.app_openid_client:unwrap() or nil,
  }
  for _, entry in self.app_entries do
    config[entry.name] = entry.config
  end
  return OBJECT.is_empty(config) ~= true and config or nil
end

function Profile.copy(self: Profile): Profile
  return Profile:new({
    name = self.name,
    server = self.server ~= nil and self.server:copy() or nil,
    spring_datasource = self.spring_datasource ~= nil and self.spring_datasource:copy() or nil,
    app_minio_client = self.app_minio_client ~= nil and self.app_minio_client:copy() or nil,
    app_openid_client = self.app_openid_client ~= nil and self.app_openid_client:copy() or nil,
    app_entries = ARRAY.copy(self.app_entries),
    trace_sql = self.trace_sql,
  })
end

function Profile.unwrap(self: Profile): Unwrapped
  return {
    server = self.server ~= nil and self.server:unwrap() or nil,
    spring = self:unwrap_spring(),
    app = self:unwrap_app(),
  }
end

return Profile

--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Table = require('@lorry.utils/lib/Table')
local Array = require('@lorry.utils/lib/Array')
local Wrapper = require('@lorry.project/lib/Wrapper')
local PropTypes = require('@lorry.project/lib/PropTypes')
local Server = require('./Server')
local SpringDatasource = require('./SpringDatasource')
local SpringJpa = require('./SpringJpa')
local OpenIdClient = require('./OpenIdClient')
local MinioClient = require('./MinioClient')
local Entry = require('./Entry')

local Profile = {
  Server = Server,
  SpringDatasource = SpringDatasource,
  SpringJpa = SpringJpa,
  OpenIdClient = OpenIdClient,
  MinioClient = MinioClient,
  Entry = Entry,
}

export type Profile = typeof(Profile) & Wrapper.Unwrappable<Unwrapped> & Wrapper.Copy<Profile> & {
  name: string,
}

export type ProfileProps = {
  name: string,
  server: Server.Server?,
  spring_datasource: SpringDatasource.SpringDatasource?,
  spring_jpa: SpringJpa.SpringJpa?,
  app_minio_client: MinioClient.MinioClient?,
  app_openid_client: OpenIdClient.OpenIdClient?,
  app_entries: {Entry.Entry},
}

export type ProfileImpl = Profile & ProfileProps

export type Unwrapped = {
  server: Server.Unwrapped?,
  spring: UnwrappedSpring?,
  app: UnwrappedApp?,
}

export type UnwrappedSpring = {
  jpa: SpringJpa.Unwrapped?,
  datasource: SpringDatasource.Unwrapped?,
}

export type UnwrappedApp = {
  minio: MinioClient.Unwrapped?,
  openid: OpenIdClient.Unwrapped?,
  [string]: Entry.Data,
}

export type ConfigurerFunc = (impl: ProfileImpl) -> ()

export type AnyChild =
  | Server.Server
  | SpringDatasource.SpringDatasource
  | SpringJpa.SpringJpa
  | OpenIdClient.OpenIdClient
  | MinioClient.MinioClient
  | Entry.Entry

function Profile:new(o: ProfileProps): Profile
  return Meta:type(o, self, "Profile")
end

function Profile:from(name: string): Profile
  assert(name ~= nil)
  return Profile:new({
    name = name,
    app_entries = Meta:array {},
  })
end

function Profile:setup(children: {AnyChild}): Profile
  local this = self::ProfileImpl
  children = children or {}
  for _, child in children do
    this:with_child(child)
  end
  return this
end

function Profile:configure(configurer: {ConfigurerFunc}): Profile
  local this = self::ProfileImpl
  for _, func in configurer do
    func(this)
  end
  return this
end

function Profile:with_child(child: AnyChild): Profile
  local this = self::ProfileImpl
  local tag = Meta:typeof(child)
  if tag == 'Profile.Server' then
    this.server = child::Server.Server
  elseif tag == 'Profile.SpringDatasource' then
    this.spring_datasource = child::SpringDatasource.SpringDatasource
  elseif tag == 'Profile.SpringJpa' then
    this.spring_jpa = child::SpringJpa.SpringJpa
  elseif tag == 'Profile.MinioClient' then
    this.app_minio_client = child::MinioClient.MinioClient
  elseif tag == 'Profile.OpenIdClient' then
    this.app_openid_client = child::OpenIdClient.OpenIdClient
  elseif tag == 'Profile.Entry' then
    this.app_entries[#this.app_entries + 1] = child::Entry.Entry
  end
  return this
end

function Profile:with_server_port(port: number): Profile
  local this = self::ProfileImpl
  this:with_child(Server:from_port(port))
  return this
end

function Profile:with_spring_datasource(datasource: PropTypes.Datasource): Profile
  local this = self::ProfileImpl
  this:with_child(SpringDatasource:from_datasource(datasource))
  return this
end

function Profile:with_spring_jpa(show_sql: boolean, properties: SpringJpa.Properties?): Profile
  local this = self::ProfileImpl
  this:with_child(SpringJpa:from(show_sql, properties))
  return this
end

function Profile:with_app_openid_remote(remote: PropTypes.OpenidRemote): Profile
  local this = self::ProfileImpl
  this:with_child(OpenIdClient:from_remote(remote))
  return this
end

function Profile:with_app_minio_client(remote: PropTypes.MinioRemote): Profile
  local this = self::ProfileImpl
  this:with_child(MinioClient:from_remote(remote))
  return this
end

function Profile:with_app_entry(name: string, config: Entry.Data): Profile
  local this = self::ProfileImpl
  this:with_child(Entry:from(name, config))
  return this
end

function Profile:unwrap_spring(): UnwrappedSpring
  local this = self::ProfileImpl
  return {
    jpa = this.spring_jpa ~= nil and this.spring_jpa:unwrap() or nil,
    datasource = this.spring_datasource ~= nil  and this.spring_datasource:unwrap() or nil,
  }
end

function Profile:unwrap_app(): UnwrappedApp?
  local this = self::ProfileImpl
  local config = {
    minio = this.app_minio_client ~= nil and this.app_minio_client:unwrap() or nil,
    openid = this.app_openid_client ~= nil and this.app_openid_client:unwrap() or nil,
  }
  for _, entry in this.app_entries do
    config[entry.name] = entry.config
  end
  return Table:is_empty(config) ~= true and config or nil
end

function Profile:copy(): Profile
  local this = self::ProfileImpl
  return Profile:new({
    name = this.name,
    server = this.server ~= nil and this.server:copy() or nil,
    spring_datasource = this.spring_datasource ~= nil and this.spring_datasource:copy() or nil,
    spring_jpa = this.spring_jpa ~= nil and this.spring_jpa:copy() or nil,
    app_minio_client = this.app_minio_client ~= nil and this.app_minio_client:copy() or nil,
    app_openid_client = this.app_openid_client ~= nil and this.app_openid_client:copy() or nil,
    app_entries = Array:copy(this.app_entries),
  })
end

function Profile:unwrap(): Unwrapped
  local this = self::ProfileImpl
  return {
    server = this.server ~= nil and this.server:unwrap() or nil,
    spring = this:unwrap_spring(),
    app = this:unwrap_app(),
  }
end

return Profile

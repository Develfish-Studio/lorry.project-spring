local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local Bucket = require('@develfish-repo.spring/profile/Bucket')
local ARRAY = require('@develfish-repo.core/util/array')

export type MinioClient = Config & Wrapper.Unwrappable<Unwrapped> & Wrapper.Copy<MinioClient> & {
  __type: 'MinioClient',

  buckets: {Bucket.Bucket},

  with_bucket: (self: MinioClient, bucket: Bucket.Config) -> MinioClient,
}

export type Config = {
  endpoint: string?,
  access_key: string?,
  secret_key: string?,
}

export type Unwrapped = {
  client: {
    ["endpoint"]: string?,
    ["access-key"]: string?,
    ["secret-key"]: string?,
  },
  buckets: {Bucket.Unwrapped}?
}

local MinioClient = {
  __type = 'MinioClient',
  endpoint = nil,
  access_key = nil,
  secret_key = nil,
  buckets = nil,
}

function MinioClient:new(o): MinioClient
  return Meta:type(o, self)
end

function MinioClient:from_config(config: Config): MinioClient
  return MinioClient:new({
    endpoint = config.endpoint,
    access_key = config.access_key,
    secret_key = config.secret_key,
    buckets = Meta:array {},
  })
end

function MinioClient.with_bucket(self: MinioClient, bucket: Bucket.Config): MinioClient
  self.buckets[#self.buckets + 1] = Bucket:from_config(bucket)
  return self
end

function MinioClient.copy(self: MinioClient): MinioClient
  return MinioClient:new({
    endpoint = self.endpoint,
    access_key = self.access_key,
    secret_key = self.secret_key,
    buckets = ARRAY.copy(self.buckets),
  })
end

function MinioClient.unwrap(self: MinioClient): Unwrapped
  return {
    client = {
      ["endpoint"] = self.endpoint,
      ["access-key"] = self.access_key,
      ["secret-key"] = self.secret_key,
    },
    buckets = Wrapper:unwrap_array_or_nil(self.buckets),
  }
end

return MinioClient

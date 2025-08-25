--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')
local Array = require('@develfish-repo.utils/lib/Array')
local PropTypes = require('@develfish-repo.project/lib/PropTypes')
local Bucket = require('./Bucket')

local MinioClient = {}

export type MinioClient = typeof(MinioClient) & Wrapper.Unwrappable<Unwrapped> & Wrapper.Copy<MinioClient>

export type MinioClientProps = {
  endpoint: string,
  access_key: string,
  secret_key: string,
  buckets: {Bucket.Bucket},
}

export type MinioClientImpl = MinioClient & MinioClientProps

export type Unwrapped = {
  client: {
    ["endpoint"]: string?,
    ["access-key"]: string?,
    ["secret-key"]: string?,
  },
  buckets: {Bucket.Unwrapped}?
}

function MinioClient:new(o: MinioClientProps): MinioClient
  return Meta:type(o, self, "Profile.MinioClient")
end

function MinioClient:from_remote(remote: PropTypes.MinioRemote): MinioClient
  return MinioClient:new({
    endpoint = remote.target_server,
    access_key = remote.access_key,
    secret_key = remote.secret_key,
    buckets = Meta:array {},
  })
end

function MinioClient:with_bucket(name: string, upload_policy: Bucket.UploadPolicy?): MinioClient
  local this = self::MinioClientImpl
  this.buckets[#this.buckets + 1] = Bucket:from(name, upload_policy)
  return self
end

function MinioClient:copy(): MinioClient
  local this = self::MinioClientImpl
  return MinioClient:new({
    endpoint = this.endpoint,
    access_key = this.access_key,
    secret_key = this.secret_key,
    buckets = Array:copy(this.buckets),
  })
end

function MinioClient:unwrap(): Unwrapped
  local this = self::MinioClientImpl
  return {
    client = {
      ["endpoint"] = this.endpoint,
      ["access-key"] = this.access_key,
      ["secret-key"] = this.secret_key,
    },
    buckets = Wrapper:unwrap_array_or_nil(this.buckets),
  }
end

return MinioClient

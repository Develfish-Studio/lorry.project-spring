--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local Bucket = {}

export type Bucket = typeof(Bucket) & BucketProps & Wrapper.Unwrappable<Unwrapped> & Wrapper.Copy<Bucket>

export type UploadPolicy = {
  content_type: string?,
  content_length: string?,
}

export type BucketProps = {
  name: string,
  upload_policy: UploadPolicy?,
}

export type Unwrapped = BucketProps

function Bucket:new(o: BucketProps): Bucket
  return Meta:type(o, self, 'Profile.MinioClient.Bucket')
end

function Bucket:from(name: string, upload_policy: UploadPolicy?): Bucket
  return Bucket:new({
    name = name,
    upload_policy = upload_policy,
  })
end

function Bucket:with_content_type(content_type: string?): Bucket
  local this = self::Bucket
  local upload_policy = this.upload_policy or Meta:table {}
  upload_policy.content_type = content_type
  this.upload_policy = upload_policy
  return this
end

function Bucket:with_content_length(content_length: string?): Bucket
  local this = self::Bucket
  local upload_policy = this.upload_policy or Meta:table {}
  upload_policy.content_length = content_length
  this.upload_policy = upload_policy
  return this
end

function Bucket:with_upload_policy(content_type: string?, content_length: string?): Bucket
  local this = self::Bucket
  this.upload_policy = {
    content_type = content_type,
    content_length = content_length,
  }
  return this
end

function Bucket:copy(): Bucket
  local this = self::Bucket
  return Bucket:new(this:unwrap())
end

function Bucket:unwrap(): Unwrapped
  local this = self::Bucket
  return {
    name = this.name,
    upload_policy = this.upload_policy,
  }
end

return Bucket

local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')

export type Bucket = Config & Wrapper.Unwrappable<Unwrapped> & Wrapper.Copy<Bucket> & {
  __type: 'Bucket',
  unwrap_upload_policy: (self: Bucket) -> UnwrappedUploadPolicy?,
}

export type Config = {
  name: string,
  content_type: string?,
  content_length: string?,
}

export type Unwrapped = {
  name: string,
  upload_policy: UnwrappedUploadPolicy?,
}

export type UnwrappedUploadPolicy = {
  content_type: string?,
  content_length: string?,
}

local Bucket = {
  __type = 'Bucket',
  name = nil,
  content_type = nil,
  content_length = nil,
}

function Bucket:new(o): Bucket
  return Meta:type(o, self)
end

function Bucket:from_config(config: Config): Bucket
  return Bucket:new(config)
end

function Bucket:from(name: string, content_type: string?, content_length: string?): Bucket
  return Bucket:new({
    name = name,
    content_type = content_type,
    content_length = content_length,
  })
end

function Bucket.copy(self: Bucket): Bucket
  return Bucket:new({
    name = self.name,
    content_type = self.content_type,
    content_length = self.content_length,
  })
end

function Bucket.unwrap_upload_policy(self: Bucket): UnwrappedUploadPolicy?
  if self.content_type ~= nil or self.content_length ~= nil then
    return {
      content_type = self.content_type,
      content_length = self.content_length,
    }
  end

  return nil
end

function Bucket.unwrap(self: Bucket): Unwrapped
  return {
    name = self.name,
    upload_policy = self:unwrap_upload_policy(),
  }
end

return Bucket

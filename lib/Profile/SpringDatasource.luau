--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')
local PropTypes = require('@lorry.project/lib/PropTypes')

local SpringDatasource = {}

export type SpringDatasource = typeof(SpringDatasource) & SpringDatasourceProps & Wrapper.Unwrappable<Unwrapped> & Wrapper.Copy<SpringDatasource>

export type SpringDatasourceProps = {
  url: string,
  username: string?,
  password: string?,
}

export type Unwrapped = SpringDatasourceProps

function SpringDatasource:new(o: SpringDatasourceProps): SpringDatasource
  return Meta:type(o, self, 'Profile.SpringDatasource')
end

function SpringDatasource:from_datasource(datasource: PropTypes.Datasource): SpringDatasource
  return SpringDatasource:new(datasource)
end

function SpringDatasource:copy(): SpringDatasource
  local this = self::SpringDatasource
  return SpringDatasource:new(this:unwrap())
end

function SpringDatasource:unwrap(): Unwrapped
  local this = self::SpringDatasource
  return {
    url = this.url,
    username = this.username,
    password = this.password,
  }
end

return SpringDatasource

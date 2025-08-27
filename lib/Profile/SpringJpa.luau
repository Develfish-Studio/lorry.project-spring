--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Wrapper = require('@lorry.project/lib/Wrapper')
local Table = require('@lorry.utils/lib/Table')
local SpringJpa = {}

export type SpringJpa = typeof(SpringJpa) & SpringJpaProps & Wrapper.Unwrappable<Unwrapped> & Wrapper.Copy<SpringJpa>

export type SpringJpaProps = {
  show_sql: boolean,
  properties: Properties?,
}

export type Properties = {
  [string]: any,
  hibernate: {
    [string]: any,
    format_sql: boolean,
  },
}

export type Unwrapped = {
  ['show-sql']: boolean,
  properties: Properties?
}

function SpringJpa:new(o: SpringJpaProps): SpringJpa
  return Meta:type(o, self, 'Profile.SpringJpa')
end

function SpringJpa:from(show_sql: boolean, properties: Properties?): SpringJpa
  return SpringJpa:new({
    show_sql = show_sql,
    properties = properties,
  })
end

function SpringJpa:copy(): SpringJpa
  local this = self::SpringJpa
  return SpringJpa:new({
    show_sql = this.show_sql,
    properties = this.properties and Table:copy(this.properties),
  })
end

function SpringJpa:unwrap(): Unwrapped
  local this = self::SpringJpa
  return {
    ['show-sql'] = this.show_sql,
    properties = this.properties,
  }
end

return SpringJpa

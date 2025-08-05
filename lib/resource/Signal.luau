local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')

export type Signal = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Signal',

  action: string,
  topic: string,
  payload_el: string,
  event_type: string,
  condition_el: string?,
}

export type Unwrapped = {
  action: string,
  topic: string,
  payload_el: string,
  event_type: string,
  condition_el: string?,
}

local Signal = {
  __type = 'Signal',

  action = nil,
  topic = nil,
  payload_el = nil,
  event_type = nil,
  condition_el = nil,
}

function Signal:new(o): Signal
  return Meta:type(o, self)
end

function Signal:from(action: string, topic: string, payload_el: string, event_type: string): Signal
  return Signal:new({
    action = action,
    topic = topic,
    payload_el = payload_el,
    event_type = event_type,
    condition_el = nil,
  })
end

function Signal:create(topic: string, payload_el: string, event_type: string?): Signal
  return Signal:from('create', topic, payload_el, event_type or 'created')
end

function Signal:update(topic: string, payload_el: string, event_type: string?): Signal
  return Signal:from('update', topic, payload_el, event_type or 'updated')
end

function Signal:upsert(topic: string, payload_el: string, event_type: string?): Signal
  return Signal:from('upsert', topic, payload_el, event_type or 'upserted')
end

function Signal:remove(topic: string, payload_el: string, event_type: string?): Signal
  return Signal:from('remove', topic, payload_el, event_type or 'removed')
end

function Signal:replace(topic: string, payload_el: string, event_type: string?): Signal
  return Signal:from('replace', topic, payload_el, event_type or 'replaced')
end

function Signal.with_payload_el(self: Signal, payload_el: string): Signal
  self.payload_el = payload_el
  return self
end

function Signal.with_condition_el(self: Signal, condition_el: string): Signal
  self.condition_el = condition_el
  return self
end

function Signal.unwrap(self: Signal): Unwrapped
  return {
    action = self.action,
    topic = self.topic,
    payload_el = self.payload_el,
    event_type = self.event_type,
    condition_el = self.condition_el,
  }
end

return Signal

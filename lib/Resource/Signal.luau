--!strict

local Meta = require('@develfish-repo.utils/lib/Meta')
local Wrapper = require('@develfish-repo.project/lib/Wrapper')

local Signal = {}

export type Signal = typeof(Signal) & Wrapper.Unwrappable<Unwrapped>

export type SignalProps = {
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

export type SignalImpl = Signal & SignalProps

function Signal:new(o: SignalProps): Signal
  return Meta:type(o, self, "Resource.Signal")
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

function Signal:with_payload_el(payload_el: string): Signal
  local this = self::SignalImpl
  this.payload_el = payload_el
  return this
end

function Signal:with_condition_el(condition_el: string): Signal
  local this = self::SignalImpl
  this.condition_el = condition_el
  return this
end

function Signal:unwrap(): Unwrapped
  local this = self::SignalImpl
  return {
    action = this.action,
    topic = this.topic,
    payload_el = this.payload_el,
    event_type = this.event_type,
    condition_el = this.condition_el,
  }
end

return Signal

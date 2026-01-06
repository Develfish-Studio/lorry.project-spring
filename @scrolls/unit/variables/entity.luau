local Entity = require('@root/lib/Unit/Entity')

return Entity:from('public.record', {
  Entity.Key:uuid 'id',
  Entity.Prop:text 'name',
  Entity.Prop:text 'description',
  Entity.Prop:decimal 'price',
}):unwrap()

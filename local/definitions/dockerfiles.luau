local Docker = require('@lorry.spring/docker/Docker')

local poms = require('./poms')

local dockerfiles = {}

dockerfiles.docker = Docker
  :from(poms.pom)
  :with_image('assembly_web')
  :with_namespace('store')

return dockerfiles

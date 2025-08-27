--!strict

local Meta = require('@lorry.utils/lib/Meta')
local Project = require('@lorry.project/lib/Project')
local Wrapper = require('@lorry.project/lib/Wrapper')
local POM = require('../POM')

local Docker = {}

export type Docker = typeof(Docker)

export type DockerProps = {
  pom: POM.POM,
  name: string?,
  filename: string?,
  namespace: string?,
  images: {string},
}

export type Unwrapped = {
  project: Project.UnwrappedProject,
  docker: {
    name: string?,
    filename: string,
    namespace: string?,
    version: string?,
    modules: {string}?,
    images: {string}?,
  }
}

export type DockerImpl = Docker & DockerProps & Wrapper.Unwrappable<Unwrapped>

function Docker:new(o: DockerProps): Docker
  return Meta:type(o, self, 'Docker')
end

function Docker:from(pom: POM.POM, name: string?, images: {string}?): Docker
  return Docker:new({
    pom = pom,
    name = name,
    namespace = name,
    images = images or Meta:array {},
  })
end

function Docker:with_namespace(namespace: string): Docker
  local this = self::DockerImpl
  this.namespace = namespace
  return self
end

function Docker:with_filename(filename: string): Docker
  local this = self::DockerImpl
  this.filename = filename
  return this
end

function Docker:with_image(image: string): Docker
  local this = self::DockerImpl
  this.images[#this.images + 1] = image
  return self
end

function Docker:unwrap(): Unwrapped
  local this = self::DockerImpl
  local pom = this.pom::POM.POMImpl
  return {
    project = this.pom:unwrap_project(),
    docker = {
      name = this.name,
      filename = this.filename or 'Dockerfile',
      namespace = this.namespace,
      version = pom.version,
      modules = pom.modules,
      images = this.images
    }
  }
end

return Docker

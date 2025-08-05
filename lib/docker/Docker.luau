local Meta = require('@develfish-repo.core/Meta')
local Wrapper = require('@develfish-repo.core/Wrapper')
local POM = require('@develfish-repo.spring/POM')
local Project = require('@develfish-repo.core/Project')

export type Docker = Wrapper.Unwrappable<Unwrapped> & {
  __type: 'Docker',
  pom: POM.POM,
  name: string?,
  filename: string?,
  namespace: string?,
  images: {string},

  with_image: (self: Docker, image: string) -> Docker,
  with_namespace: (self: Docker, namespace: string) -> Docker,
  with_filename: (self: Docker, filename: string) -> Docker,
}

export type Unwrapped = {
  project: Project.UnwrappedProject,
  docker: {
    name: string?,
    filename: string,
    namespace: string?,
    version: string,
    modules: {string}?,
    images: {string}?,
  }
}

local Docker = {
  __type = 'Docker',
  pom = nil,
  name = nil,
  filename = nil,
  namespace = nil,
  images = nil,
}

function Docker:new(o): Docker
  return Meta:type(o, self)
end

function Docker:from(pom: POM.POM, name: string?, images: {string}?): Docker
  return Docker:new({
    pom = pom,
    name = name,
    namespace = name,
    images = images or Meta:array {},
  })
end

function Docker.with_namespace(self: Docker, namespace: string): Docker
  self.namespace = namespace
  return self
end

function Docker.with_filename(self: Docker, filename: string): Docker
  self.filename = filename
  return self
end

function Docker.with_image(self: Docker, image: string): Docker
  self.images[#self.images + 1] = image
  return self
end

function Docker.unwrap(self: Docker): Unwrapped
  return {
    project = self.pom.project:unwrap_project(),
    docker = {
      name = self.name,
      filename = self.filename or 'Dockerfile',
      namespace = self.namespace,
      version = self.pom.version,
      modules = self.pom.modules,
      images = self.images
    }
  }
end

return Docker

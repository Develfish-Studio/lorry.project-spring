local Project = require('@lorry.core/Project')

local projects = {}

projects.project = Project:from('store_backend')
projects.project_ddl = Project:from('store_migrate')

return projects

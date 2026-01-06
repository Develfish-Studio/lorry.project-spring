--!strict

local Lorry = require('@lorry.utils/lib/Lorry')
local Profile = require('@root/lib/Profile/Profile')

local variables: Profile.Unwrapped = Lorry:variables()

Lorry.Template:print(Lorry.Yaml:stringify(variables))

using module Bops.Lib.Config # This loads the Config type defined by Add-Type
using module Cs.Type.Configuration 

$path = Join-Path $PSScriptRoot "Bops.Lib.json"

[Configuration[Config]] $Config = [Configuration[Config]]::new($path)

Export-ModuleMember -Variable 'Config'


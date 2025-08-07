# Import all project modules
using module '.\modules\.modules.psm1'

using module Bop.U.Logger

$logger = [Logger]::new()
$logger.Blank()
$logger.Start("[L] Modules Loaded")
$logger.Enter($MyInvocation.MyCommand.Path)

function Load {
    # Custom loading script here

}


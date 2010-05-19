#----------------------------------------------------------------#
# SQLPSX.PSM1
# Author: Bernd, 05/18/2010
# 
# Comment: Replaces Max version of the SQLPSX.psm1
#----------------------------------------------------------------#

$PSXloadModules = @()
$PSXloadModules = "SQLmaint","SQLServer","Agent","Repl","SSIS","Showmbrs"
$PSXloadModules += "SQLParser","adolib" 
if ($psIse) { 
   $PSXloadModules += "SQLIse" 
}

$oraAssembly = [System.Reflection.Assembly]::LoadWithPartialName("Oracle.DataAccess") 
if ($oraAssembly) {
   $PSXloadModules += "OracleClient"
   if ($psIse) { 
       $PSXloadModules += "OracleIse" 
   }
}
else { Write-Host  -ForegroundColor Yellow "No Oracle found" }


$PSXremoveModules = $PSXloadModules[($PSXloadModules.count)..0]

$mInfo = $MyInvocation.MyCommand.ScriptBlock.Module
$mInfo.OnRemove = {
   foreach($PSXmodule in $PSXremoveModules){
       if (gmo $PSXmodule)
       {    
         Write-Host  -ForegroundColor Yellow "Removing SQLPSX Module - $PSXModule"
         Remove-Module $PSXmodule
       }
   }

   # Remomve $psScriptRoot from $env:PSModulePath
   $pathes = $env:PSModulePath -split ';' | ? { $_ -ne "$psScriptRoot\modules"}
   $env:PSModulePath = $pathes -join ';'
   #$env:PSModulePath   

   Write-Host  -ForegroundColor Yellow "$($MyInvocation.MyCommand.ScriptBlock.Module.name) removed on $(Get-Date)"
}

if (($env:PSModulePath -split ';') -notcontains "$psScriptRoot\modules")
{
   $env:PSModulePath += ";" + "$psScriptRoot\modules"
}

foreach($PSXmodule in $PSXloadModules){
 Write-Host  -ForegroundColor Yellow "Loading SQLPSX Module - $PSXModule"
 Import-Module $PSXmodule -global
}
Write-Host  -ForegroundColor Yellow "Loading SQLPSX Modules is Done!"

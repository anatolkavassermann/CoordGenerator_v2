param (
    [parameter(Mandatory=$false)] [System.Int64] $InitialTime = 0,
    [parameter(Mandatory=$false)] [string] $EachPC
)
New-Alias -Name "tp" -Value "Test-Path" -ErrorAction SilentlyContinue
Import-Module "./modules/Errors.psm1"  -ErrorAction Stop
Import-Module "./modules/ReturnFormattedData.psm1"  -ErrorAction Stop
Import-Module "./engines/CoordsCalculation.psm1" -ErrorAction Stop
Import-Module "./engines/PlaneObjectCreationEngine.psm1" -ErrorAction Stop
Import-Module "./engines/WorldCoordsCreationEngine.psm1" -ErrorAction Stop
Import-Module "./parsers/WorldSectionParser.psm1"  -ErrorAction Stop
Import-Module "./parsers/PlaneSectionConfigurationParser.psm1" -ErrorAction Stop
Import-Module "./parsers/MainSectionConfigurationParser.psm1" -ErrorAction Stop
Import-Module "./engines/MainEngine.psm1" -ErrorAction Stop
Add-Type ((Get-Content .\classes\myData.cs) -as [String]) -ReferencedAssemblies "System","System.Collections" -ErrorAction SilentlyContinue
./geo.ps1 -InitialTime $InitialTime -EachPC $EachPC
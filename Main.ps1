param (
    [parameter(Mandatory=$false)] [int] $InitialTime = 0
)
nal -Name "tp" -Value "Test-Path" -ErrorAction SilentlyContinue
ipmo "./modules/Errors.psm1"  -ErrorAction Stop
ipmo "./modules/ReturnFormattedData.psm1"  -ErrorAction Stop
ipmo "./engines/CoordsCalculation.psm1" -ErrorAction Stop
ipmo "./engines/PlaneObjectCreationEngine.psm1" -ErrorAction Stop
ipmo "./engines/WorldCoordsCreationEngine.psm1" -ErrorAction Stop
ipmo "./parsers/WorldSectionParser.psm1"  -ErrorAction Stop
ipmo "./parsers/PlaneSectionConfigurationParser.psm1" -ErrorAction Stop
ipmo "./parsers/MainSectionConfigurationParser.psm1" -ErrorAction Stop
Add-Type ((gc .\classes\myData.cs) -as [String]) -ReferencedAssemblies "System","System.Collections" -ErrorAction SilentlyContinue
./geo.ps1 -InitialTime 5000
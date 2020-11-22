param (
    [parameter(Mandatory=$true)][System.Int16]$InitialTime = 0
)

tp ".\conf\Output.txt" | % {if ($_ -eq $false) {ni -i File -p ".\conf\Output.txt" | rvpa}; if ($_ -eq $true) {gci ".\conf\Output.txt" | rvpa}} | sv OutputConfigFilepath
try {
    (gc .\conf\main_conf.xml -ErrorAction Stop) -as [xml] | sv -Name Configuration
}
catch {
    ShowMessageWrongConf -ErrorType "File" -ErrorMessage $Error[0].exception.Message
}
[GEO_classes.World] $WorldCoordConfiguration = CalculateWorldsCoords -WorldConfiguration (CheckWorldSectionConfiguration -WorldSection $Configuration.conf.sectionWorld)
$PlanePatternConfiguration = CheckPlaneSectionConfiguration -PlaneSection $Configuration.conf.sectionPlanePattern 
$PatternsToGenerateConfiguration = CheckMainSectionConfiguration -MainSection $Configuration.conf.sectionMain
GenerateCoords -_OutputConfigFilepath $OutputConfigFilepath -_CompleteConfiguration (GenerateCompleteConfiguration -_WorldCoordConfiguration $WorldCoordConfiguration -_PlanePatternConfiguration $PlanePatternConfiguration -_PatternsToGenerateConfiguration $PatternsToGenerateConfiguration)
Pause
Write-Host -Object "Finished!" -ForegroundColor Green
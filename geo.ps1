param (
    [parameter(Mandatory=$true)] [System.Int64] $InitialTime,
    [parameter(Mandatory=$false)] [string] $EachPC
)
if ($EachPC -eq "") {
    $EachPC = "low"
}
tp ".\conf\Output.txt" | ForEach-Object {if ($_ -eq $false) {New-Item -i File -p ".\conf\Output.txt" | Resolve-Path}; if ($_ -eq $true) {Get-ChildItem ".\conf\Output.txt" | Resolve-Path}} | Set-Variable OutputConfigFilepath
try {
    (Get-Content .\conf\main_conf.xml -ErrorAction Stop) -as [xml] | Set-Variable -Name Configuration
}
catch {
    ShowMessageWrongConf -ErrorType "File" -ErrorMessage $Error[0].exception.Message
}
[GEO_classes.World] $WorldCoordConfiguration = CalculateWorldsCoords -WorldConfiguration (CheckWorldSectionConfiguration -WorldSection $Configuration.conf.sectionWorld)
[hashtable] $PlanePatternConfiguration = CheckPlaneSectionConfiguration -PlaneSection $Configuration.conf.sectionPlanePattern 
switch ($EachPC) {
    "low" {
        [hashtable] $PatternsToGenerateConfiguration = CheckMainSectionConfiguration -MainSection $Configuration.conf.sectionMain         
    }
    default {
        [hashtable] $PatternsToGenerateConfiguration = CheckMainSectionConfiguration -MainSection $Configuration.conf.sectionMain -EachPC $EachPC
    }
}
GenerateCoords -_InitialTime $InitialTime -_OutputConfigFilepath $OutputConfigFilepath -_CompleteConfiguration (GenerateCompleteConfiguration -_WorldCoordConfiguration $WorldCoordConfiguration -_PlanePatternConfiguration $PlanePatternConfiguration -_PatternsToGenerateConfiguration $PatternsToGenerateConfiguration)
Write-Host -Object "Finished!" -ForegroundColor Green
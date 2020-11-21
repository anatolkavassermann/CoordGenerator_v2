using module "./classes/Plane.psm1"

param (
    [parameter(Mandatory=$false)][System.Int16]$InitialTime = 0
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
$CompleteConfiguration = @{}
for ($PatternIndex = 0; $PatternIndex -lt $PatternsToGenerateConfiguration.Count-1; $PatternIndex++) {
    switch ($PlanePatternConfiguration.Contains($PatternsToGenerateConfiguration[$PatternIndex.ToString()].PatternName)) {
        $true {
            $TempData = @{}
            $TempData.Add("PatternConfiguration",$PlanePatternConfiguration[$PatternsToGenerateConfiguration[$PatternIndex.ToString()].PatternName])
            $TempData.Add("Count",$PatternsToGenerateConfiguration[$PatternIndex.ToString()].Count)
            $CompleteConfiguration.Add($PatternIndex.ToString(),$TempData)
            break;
        }
        $false {
            ShowMessageWrongConf -Section $Configuration.conf.sectionMain.Name -ParameterName "PatternsToUse" -ErrorMessage ("The template " + $PatternsToGenerateConfiguration[$PatternIndex.ToString()].PatternName +" is not described! Check config file!")
            break;
        }
    }
}
[System.Random]$rnd = [System.Random]::new()
for ($PatternIndex = 0; $PatternIndex -lt $CompleteConfiguration.Count; $PatternIndex++) {
    for ($PatternCount = 0; $PatternCount -lt $CompleteConfiguration[$PatternIndex.ToString()].Count; $PatternCount++) {
        [Plane]$Plane = CreatePlane -PlanePatternConfiguration $CompleteConfiguration[$PatternIndex.ToString()].PatternConfiguration -World $WorldCoordConfiguration -rnd $rnd
        $PlaneIsOnMap = $false
        Write-Host -Object ("Generating coords for " + $Plane.PlaneID) -ForegroundColor Green
        $Step = $rnd.Next($InitialTime,($InitialTime+5000))
        $CurrStep = -1
        while ($Plane.CanFly) {
            $CurrStep++
            if ($CurrStep -ge 5000) {
                break;
            }
            switch ($PlaneIsOnMap) {
                $false {
                    [System.Int64]$Milisecond = $Step
                    [System.String]$OutputResult = ($Plane.Coords.latitude.ToString() + ":" + $Plane.Coords.longtitude.ToString())
                    $OutputResult = "<" + $Milisecond.ToString() + ">" + $OutputResult + ";" + $Plane.CurrentHeight.ToString() + ";" + $Plane.CurrentAngle.ToString() + ";" + $Plane.PlaneID
                    Add-Content -Path $OutputConfigFilepath -Value $OutputResult
                    $PlaneIsOnMap = $true
                    break;
                }
            }
            $Plane.MakeStep()
            switch ($Plane.CanFly) {
                $true {
                    $Step ++
                    [System.Int64]$Milisecond = $Plane.RefreshRate + $Milisecond
                    [System.String]$OutputResult = ($Plane.Coords.latitude.ToString() + ":" + $Plane.Coords.longtitude.ToString())
                    $OutputResult = "<" + $Milisecond.ToString() + ">" + $OutputResult + ";" + $Plane.CurrentHeight.ToString() + ";" + $Plane.CurrentAngle.ToString() + ";" + $Plane.PlaneID
                    Add-Content -Path $OutputConfigFilepath -Value $OutputResult
                    break;
                }
                $false {
                    break;
                }
            }
        }
    }
    Get-Content $OutputConfigFilepath | Sort-Object -Property {$_.Substring(1,$_.IndexOf(">")).Length;"$_[0..9]"} | Set-Content $OutputConfigFilepath
}
using module "./classes/Plane.psm1"
function GenerateCompleteConfiguration {
    param (
        [parameter(Mandatory=$true)] [GEO_classes.World] $_WorldCoordConfiguration,
        [parameter(Mandatory=$true)] [hashtable] $_PlanePatternConfiguration,
        [parameter(Mandatory=$true)] [hashtable] $_PatternsToGenerateConfiguration
    )
    $_CompleteConfiguration = @{}
    for ($PatternIndex = 0; $PatternIndex -lt $_PatternsToGenerateConfiguration.Count-1; $PatternIndex++) {
        switch ($_PlanePatternConfiguration.Contains($_PatternsToGenerateConfiguration[$PatternIndex.ToString()].PatternName)) {
            $true {
                $TempData = @{}
                $TempData.Add("PatternConfiguration",$_PlanePatternConfiguration[$_PatternsToGenerateConfiguration[$PatternIndex.ToString()].PatternName])
                $TempData.Add("Count",$_PatternsToGenerateConfiguration[$PatternIndex.ToString()].Count)
                $_CompleteConfiguration.Add($PatternIndex.ToString(),$TempData)
                break;
            }
            $false {
                ShowMessageWrongConf -Section $Configuration.conf.sectionMain.Name -ParameterName "PatternsToUse" -ErrorMessage ("The template " + $_PatternsToGenerateConfiguration[$PatternIndex.ToString()].PatternName +" is not described! Check config file!")
                break;
            }
        }
    }
    $_CompleteConfiguration.Add("WorldCoordConfiguration", $_WorldCoordConfiguration)
    return $_CompleteConfiguration;
}
function GenerateCoords {
    param (
        [parameter(Mandatory=$true)] [hashtable] $_CompleteConfiguration,
        [parameter(Mandatory=$true)] $_OutputConfigFilepath,
        [parameter(Mandatory=$true)] $_InitialTime
    )
    [System.Random]$rnd = [System.Random]::new()
    for ($PatternIndex = 0; $PatternIndex -lt $_CompleteConfiguration.Count; $PatternIndex++) {
        for ($PatternCount = 0; $PatternCount -lt $_CompleteConfiguration[$PatternIndex.ToString()].Count; $PatternCount++) {
            [Plane]$Plane = CreatePlane -PlanePatternConfiguration $_CompleteConfiguration[$PatternIndex.ToString()].PatternConfiguration -World $_CompleteConfiguration['WorldCoordConfiguration'] -rnd $rnd
            $PlaneIsOnMap = $false
            Write-Host -Object ("Generating coords for " + $Plane.PlaneID) -ForegroundColor Green
            $Step = $rnd.Next($_InitialTime,($_InitialTime+5000))
            $CurrStep = -1
            while ($Plane.CanFly) {
                $CurrStep++
                if ($CurrStep -ge 1000) {
                    break;
                }
                switch ($PlaneIsOnMap) {
                    $false {
                        [System.Int64]$Milisecond = $Step
                        [System.String]$OutputResult = ($Plane.Coords.latitude.ToString() + ":" + $Plane.Coords.longtitude.ToString())
                        "<" + $Milisecond.ToString() + ">" + $OutputResult + ";" + $Plane.CurrentHeight.ToString() + ";" + $Plane.CurrentAngle.ToString() + ";" + $Plane.PlaneID | Add-Content -Path $_OutputConfigFilepath -NoNewline:$false
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
                        "<" + $Milisecond.ToString() + ">" + $OutputResult + ";" + $Plane.CurrentHeight.ToString() + ";" + $Plane.CurrentAngle.ToString() + ";" + $Plane.PlaneID | Add-Content -Path $_OutputConfigFilepath -NoNewline:$false
                        break;
                    }
                    $false {
                        break;
                    }
                }
            }
        }
    }
    Get-Content $_OutputConfigFilepath | Sort-Object -Property {$_.Substring(1,$_.IndexOf(">")).Length;"$_[0..9]"} | Set-Content $_OutputConfigFilepath
}
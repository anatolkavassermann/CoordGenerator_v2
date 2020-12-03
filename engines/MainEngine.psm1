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
function PlaneFly {
    param (
        [parameter(Mandatory=$true)] $Plane,
        [parameter(Mandatory=$true)] $_World,
        [parameter(Mandatory=$true)] $_rnd,
        [parameter(Mandatory=$true)] $__InitialTime
    )
    $PlaneIsOnMap = $false
    $Step = $_rnd.Next($__InitialTime,($__InitialTime+10000))
    $CurrStep = -1
    [System.Text.StringBuilder]$Coords = [System.Text.StringBuilder]::new()
    while ($Plane.CanFly) {
        $CurrStep++
        if ($CurrStep -gt 500) {
            break;
        }
        switch ($PlaneIsOnMap) {
            $false {
                [System.Int64]$Milisecond = $Step
                [System.String]$OutputResult = ($Plane.Coords.latitude.ToString() + ":" + $Plane.Coords.longtitude.ToString())
                [System.String]$OutputResult = ($Plane.Coords.latitude.ToString() + ":" + $Plane.Coords.longtitude.ToString())
                "<" + $Milisecond.ToString() + ">" + $OutputResult + ";" + $Plane.CurrentHeight.ToString() + ";" + $Plane.CurrentAngle.ToString() + ";" + $Plane.PlaneID | % {[void] $Coords.AppendLine($_)}
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
                "<" + $Milisecond.ToString() + ">" + $OutputResult + ";" + $Plane.CurrentHeight.ToString() + ";" + $Plane.CurrentAngle.ToString() + ";" + $Plane.PlaneID | % {[void] $Coords.AppendLine($_)}
                break;
            }
            $false {
                break;
            }
        }
    }
    switch ($CurrStep -gt 5) {
        $true {
            return $Coords.ToString()
        }
        $false {
            return "Rejected"
        }
    }
}
function GenerateCoords {
    param (
        [parameter(Mandatory=$false)] [hashtable] $_CompleteConfiguration,
        [parameter(Mandatory=$false)] $_OutputConfigFilepath,
        [parameter(Mandatory=$false)] $_InitialTime,
        [parameter(Mandatory=$false)] $_JustSort
    )
    switch ($_JustSort) {
        $true {
            Get-Content $_OutputConfigFilepath | Sort-Object -Property {$_.Substring(1,$_.IndexOf(">")).Length;"$_[0..9]"}| Set-Content $_OutputConfigFilepath
        }
        default {
            [System.Random]$rnd = [System.Random]::new()
            for ($PatternIndex = 0; $PatternIndex -lt $_CompleteConfiguration.Count; $PatternIndex++) {
                for ($PatternCount = 0; $PatternCount -lt $_CompleteConfiguration[$PatternIndex.ToString()].Count; $PatternCount++) {
                    $IsAccepted = $false
                    while ($IsAccepted -eq $false) {
                        [GEO_classes.Plane]$_Plane = CreatePlane -PlanePatternConfiguration $_CompleteConfiguration[$PatternIndex.ToString()].PatternConfiguration -World $_CompleteConfiguration['WorldCoordConfiguration'] -rnd $rnd
                        Write-Host -Object ("Generating coords for " + $_Plane.PlaneID + ". ") -ForegroundColor Green -NoNewline:$true
                        $Result = PlaneFly -Plane $_Plane -_World $_CompleteConfiguration['WorldCoordConfiguration'] -_rnd $rnd -__InitialTime $_InitialTime
                        if ($Result -eq "Rejected") {
                            Write-Host -Object ($_Plane.PlaneID + " - Rejected!") -ForegroundColor Red -NoNewline:$false
                        }
                        else {
                            Write-Host -Object ($_Plane.PlaneID + " - Accepted!") -ForegroundColor Green -NoNewline:$false
                            $CanWrite = $false
                            while ($CanWrite -eq $false) {
                                try {
                                    $Result | Add-Content -Path $_OutputConfigFilepath -NoNewline:$true -ErrorAction Stop
                                    $CanWrite = $true
                                }   
                                catch {
                                    Start-Sleep -Milliseconds 500
                                }
                            }
                            $IsAccepted = $true
                            break;
                        }
                    }
                    Get-Content $_OutputConfigFilepath | Sort-Object -Property {$_.Substring(1,$_.IndexOf(">")).Length;"$_[0..9]"}| Set-Content $_OutputConfigFilepath
                }
            }    
        }
    }
}
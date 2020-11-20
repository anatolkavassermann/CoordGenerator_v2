ipmo "./modules/Errors.psm1"  -ErrorAction Stop
ipmo "./modules/ReturnFormattedData.psm1" -ErrorAction Stop

function CheckWorldSectionConfiguration {
    param (
        [parameter(Mandatory=$true)] [System.Xml.XmlNode] $WorldSection
    )
    switch ($WorldSection.ChildNodes.Count) {
        2 {
            foreach ($parameter in $WorldSection.param) {
                switch ($parameter.ParamName) {
                    "Point" {
                        $WorldLeftCornerCoords = ReturnFormattedData -Section $WorldSection.Name -Parameter $parameter
                        break;
                    }
                    "Distance" {
                        $WorldSide = ReturnFormattedData -Section $WorldSection.Name -Parameter $parameter
                        break;
                    }
                }
            }
        }
        default {
            [string]$ErrorMessage = "Not enough params! Check config file!"
            ShowMessageWrongConf -ErrorType "Config" -ErrorMessage $ErrorMessage -Section $WorldSection.Name
        }
    }
    switch ($WorldLeftCornerCoords.DataIsCorrect -and $WorldSide.DataIsCorrect) {
        $true {
            $WorldConfiguration = @{'WorldLeftCornerCoords'=$WorldLeftCornerCoords.FormattedData; 'WorldSide' = $WorldSide.FormattedData}
            return $WorldConfiguration;
        }
        $false {
            switch ($null -eq $WorldLeftCornerCoords) {
                $true {
                    ShowMessageWrongConf -Section $WorldSection.Name -ParameterName "Point" -ErrorMessage "Parameter is not specified"
                    return $null;
                }
            }
            switch ($null -eq $WorldSide) {
                $true {
                    ShowMessageWrongConf -Section $WorldSection.Name -ParameterName "Distance" -ErrorMessage "Parameter is not specified"
                    return $null;
                }
            }
            switch ($false -eq $WorldLeftCornerCoords.DataIsCorrect) {
                $true {
                    ShowMessageWrongConf -Section $WorldSection.Name -ParameterName "Point" -ErrorMessage $WorldsLeftCornerCoords.ErrorMessage
                    return $null;
                }
            }
            switch ($null -eq $WorldSide.DataIsCorrect) {
                $true {
                    ShowMessageWrongConf -Section $WorldSection.Name -ParameterName "Distance" -ErrorMessage $WorldsSide.ErrorMessage
                    return $null;
                }
            }
        }
    }
}
Add-Type ((Get-Content .\classes\myData.cs) -as [String]) -ReferencedAssemblies "System","System.Collections"

function ReturnFormattedData {
    param (
        [parameter (Mandatory=$true)] [System.String] $Section,
        [parameter (Mandatory=$false)] [System.Xml.XmlNode] $Parameter,
        [parameter(Mandatory=$false)] [System.String] $PatternName
    )
    switch (($Parameter.ParamName -ne "") -and ($Parameter.Data -ne "") -and ($Parameter.ParamDataType -ne "")) {
        $true {
            switch ($Parameter.ParamDataType) {
                "Point" { 
                    [GEO_classes.Point] $Data = [GEO_classes.Point]::new($Parameter.Data,$Parameter.ParamName,$Section)
                    return $Data;
                }
                "Angle" { 
                    [GEO_classes.Angle] $Data = [GEO_classes.Angle]::new($Parameter.Data,$Parameter.ParamName,$PatternName,$Section)
                    return $Data;
                }
                "Distance" { 
                    [GEO_classes.Distance] $Data = [GEO_classes.Distance]::new($Parameter.Data,$Parameter.ParamName,$Section)
                    return $Data;
                }
                "Speed" { 
                    [GEO_classes.Speed] $Data = [GEO_classes.Speed]::new($Parameter.Data,$Parameter.ParamName,$PatternName,$Section)
                    return $Data;
                }
                "Height" { 
                    [GEO_classes.Height] $Data = [GEO_classes.Height]::new($Parameter.Data,$Parameter.ParamName,$PatternName,$Section)
                    return $Data;
                }
            }
            break;
        }
        $false {
            [string]$ErrorMessage = "ParamName, Data and ParamDataType cannot be empty! Check config file!"
            ShowMessageWrongConf -ErrorType "Config" -ErrorMessage $ErrorMessage -Section $Section -ParameterName $Parameter.ParamName -PatternName $PatternName
            break;
        }
    }
}
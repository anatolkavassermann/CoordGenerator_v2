ipmo "./modules/Errors.psm1"  -ErrorAction Stop
ipmo "./parsers/WorldSectionParser.psm1"  -ErrorAction Stop
ipmo "./engines/WorldCoordsCreationEngine.psm1" -ErrorAction Stop
function CheckPlaneSectionConfiguration () {
	param(
        [parameter (Mandatory=$true)] [System.Xml.XmlNode] $PlaneSection
	)
	[hashtable] $PlanePatterns = @{ }
	[System.Int16]$PatternCount = $PlaneSection.ChildNodes.Count
	switch ($PatternCount -gt 0) {
		$true {
			switch ($PatternCount -eq 1) {
				$true {
					$CurrentPlanePattern = Checker -PlanePattern $PlaneSection.Pattern -Section $PlaneSection.Name
					$PlanePatterns.Add($CurrentPlanePattern['PatternName'],$CurrentPlanePattern)
					return $PlanePatterns
				}
				$false {
					for ($PlanePatternsIndex = 0; $PlanePatternsIndex -lt $PatternCount; $PlanePatternsIndex++) {
						$CurrentPlanePattern = Checker -PlanePattern $PlaneSection.Pattern[$PlanePatternsIndex] -Section $PlaneSection.Name
						$PlanePatterns.Add($CurrentPlanePattern['PatternName'],$CurrentPlanePattern)
					}
					return $PlanePatterns
				}
			}
		 }
		$false {
			ShowMessageWrongConf -Section $PlaneSection.Name -ErrorMessage "No patterns specified!"
		}
	}
}
function Checker () {
	param (
		[parameter(Mandatory=$true)] [System.Xml.XmlNode] $PlanePattern,
		[parameter (Mandatory=$true)] [System.String] $Section
	)

	$ParametersInEachPatternCount = $PlanePattern.Params.ChildNodes.Count
	switch ($PlanePattern.PatternName -eq "") {
		$true {
			ShowMessageWrongConf -Section $Section -ParameterName "PatternName" -ErrorMessage "PatternName cannot be empty! Check config file!"
		}
		$false {
			switch ($PlanePattern.RefreshRate -eq "") {
				$true {
					ShowMessageWrongConf -Section $Section -ParameterName "RefreshRate" -ErrorMessage "RefreshRate cannot be empty! Check config file!"
				}
			}
		}
	}
	[System.String]$PatternName = $PlanePattern.PatternName
	[System.Int16]$RefreshRate = $PlanePattern.RefreshRate
	switch ($ParametersInEachPatternCount -eq 8) {
		$true {
			foreach ($Parameter in $PlanePattern.Params.Param) {
				switch ($Parameter.ParamName) {
					"MinSpeed" {
						$MinSpeed = ReturnFormattedData -Section $Section -Parameter $Parameter -PatternName $PatternName
						switch ($MinSpeed.DataIsCorrect) {
                            $false {
                                ShowMessageWrongConf -Section $Section -PatternName $PatternName -ParameterName $Parameter.ParamName -ErrorMessage $MinSpeed.ErrorMessage
                            }
                        }
					}
					"MaxSpeed" {
						$MaxSpeed = ReturnFormattedData -Section $Section -Parameter $Parameter -PatternName $PatternName
						switch ($MaxSpeed.DataIsCorrect) {
                            $false {
                                ShowMessageWrongConf -Section $Section -PatternName $PatternName -ParameterName $Parameter.ParamName -ErrorMessage $MaxSpeed.ErrorMessage
                            }
                        }
					}
					"SpeedAdj" {
						$SpeedAdj = ReturnFormattedData -Section $Section -Parameter $Parameter -PatternName $PatternName
						switch ($SpeedAdj.DataIsCorrect) {
                            $false {
                                ShowMessageWrongConf -Section $Section -PatternName $PatternName -ParameterName $Parameter.ParamName -ErrorMessage $SpeedAdj.ErrorMessage
                            }
                        }
					}
					"SpeedDec" {
						$SpeedDec = ReturnFormattedData -Section $Section -Parameter $Parameter -PatternName $PatternName
						switch ($SpeedDec.DataIsCorrect) {
                            $false {
                                ShowMessageWrongConf -Section $Section -PatternName $PatternName -ParameterName $Parameter.ParamName -ErrorMessage $SpeedDec.ErrorMessage
                            }
                        }
					}
					"MinHeight" {
						$MinHeight = ReturnFormattedData -Section $Section -Parameter $Parameter -PatternName $PatternName
						switch ($MinHeight.DataIsCorrect) {
                            $false {
                                ShowMessageWrongConf -Section $Section -PatternName $PatternName -ParameterName $Parameter.ParamName -ErrorMessage $MinHeight.ErrorMessage
                            }
                        }
					}
					"MaxHeight" {
						$MaxHeight = ReturnFormattedData -Section $Section -Parameter $Parameter -PatternName $PatternName
						switch ($MaxHeight.DataIsCorrect) {
                            $false {
                                ShowMessageWrongConf -Section $Section -PatternName $PatternName -ParameterName $Parameter.ParamName -ErrorMessage $MaxHeight.ErrorMessage
                            }
                        }
					}
					"MaxUpAngle" {
						$MaxUpAngle = ReturnFormattedData -Section $Section -Parameter $Parameter -PatternName $PatternName
						switch ($MaxUpAngle.DataIsCorrect) {
                            $false {
                                ShowMessageWrongConf -Section $Section -PatternName $PatternName -ParameterName $Parameter.ParamName -ErrorMessage $MaxUpAngle.ErrorMessage
                            }
                        }
					}
					"MaxRotAngle" {
						$MaxRotAngle = ReturnFormattedData -Section $Section -Parameter $Parameter -PatternName $PatternName
						switch ($MaxRotAngle.DataIsCorrect) {
                            $false {
                                ShowMessageWrongConf -Section $Section -PatternName $PatternName -ParameterName $Parameter.ParamName -ErrorMessage $MaxRotAngle.ErrorMessage
                            }
                        }
					}
				}
			}
            switch (($MinSpeed.FormattedData -le $MaxSpeed.FormattedData) -and ($MinHeight.FormattedData -le $MaxHeight.FormattedData)) {
                $true { 
                    $PlanePatternConfiguration = @{
                        'PatternName'	    = $PatternName;
                        'RefreshRate'	    = $RefreshRate;
                        'MinSpeed'		    = $MinSpeed.FormattedData;
                        'MaxSpeed'		    = $MaxSpeed.FormattedData;
                        'SpeedAdjust'	    = $SpeedAdj.FormattedData;
                        'SpeedDecrease'	    = $SpeedDec.FormattedData;
                        'MinHeight'	 	   	= $MinHeight.FormattedData;
                        'MaxHeight'	    	= $MaxHeight.FormattedData;
                        'MaxUpDownAngle'    = $MaxUpAngle.FormattedData;
                        'MaxRotateAngle'    = $MaxRotAngle.FormattedData;
                    }
                    return $PlanePatternConfiguration
                }
                $false {
                    ShowMessageWrongConf -Section $Section -PatternName $PatternName -ErrorMessage "MinHeight param must be less than or equal to the MaxHeight param and MinSpeed param must be less than or equal to the MaxSpeed param"
                }
            }	
		}
		$false {
			ShowMessageWrongConf -Section $Section -PatternName $PatternName -ErrorMessage "Not enough parameters specified"
		}
	}
}
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
			break;
		}
		$false {
			ShowMessageWrongConf -Section $PlaneSection.Name -ErrorMessage "No patterns specified!"
			break;
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
			break;
		}
		$false {
			switch ($PlanePattern.RefreshRate -eq "") {
				$true {
					ShowMessageWrongConf -Section $Section -ParameterName "RefreshRate" -ErrorMessage "RefreshRate cannot be empty! Check config file!"
					break;
				}
			}
			break;
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
								break;
							}
						}
						break;
					}
					"MaxSpeed" {
						$MaxSpeed = ReturnFormattedData -Section $Section -Parameter $Parameter -PatternName $PatternName
						switch ($MaxSpeed.DataIsCorrect) {
                            $false {
                                ShowMessageWrongConf -Section $Section -PatternName $PatternName -ParameterName $Parameter.ParamName -ErrorMessage $MaxSpeed.ErrorMessage
								break;
							}
						}
						break;
					}
					"SpeedAdjust" {
						$SpeedAdjust = ReturnFormattedData -Section $Section -Parameter $Parameter -PatternName $PatternName
						switch ($SpeedAdjust.DataIsCorrect) {
                            $false {
                                ShowMessageWrongConf -Section $Section -PatternName $PatternName -ParameterName $Parameter.ParamName -ErrorMessage $SpeedAdjust.ErrorMessage
								break;
							}
						}
						break;
					}
					"SpeedDecrease" {
						$SpeedDecrease = ReturnFormattedData -Section $Section -Parameter $Parameter -PatternName $PatternName
						switch ($SpeedDecrease.DataIsCorrect) {
                            $false {
                                ShowMessageWrongConf -Section $Section -PatternName $PatternName -ParameterName $Parameter.ParamName -ErrorMessage $SpeedDecrease.ErrorMessage
								break;
							}
						}
						break;
					}
					"MinHeight" {
						$MinHeight = ReturnFormattedData -Section $Section -Parameter $Parameter -PatternName $PatternName
						switch ($MinHeight.DataIsCorrect) {
                            $false {
                                ShowMessageWrongConf -Section $Section -PatternName $PatternName -ParameterName $Parameter.ParamName -ErrorMessage $MinHeight.ErrorMessage
								break;
							}
						}
						break;
					}
					"MaxHeight" {
						$MaxHeight = ReturnFormattedData -Section $Section -Parameter $Parameter -PatternName $PatternName
						switch ($MaxHeight.DataIsCorrect) {
                            $false {
                                ShowMessageWrongConf -Section $Section -PatternName $PatternName -ParameterName $Parameter.ParamName -ErrorMessage $MaxHeight.ErrorMessage
								break;
							}
						}
						break;
					}
					"MaxUpDownAngle" {
						$MaxUpDownAngle = ReturnFormattedData -Section $Section -Parameter $Parameter -PatternName $PatternName
						switch ($MaxUpDownAngle.DataIsCorrect) {
                            $false {
                                ShowMessageWrongConf -Section $Section -PatternName $PatternName -ParameterName $Parameter.ParamName -ErrorMessage $MaxUpDownAngle.ErrorMessage
								break;
							}
						}
						break;
					}
					"MaxRotateAngle" {
						$MaxRotateAngle = ReturnFormattedData -Section $Section -Parameter $Parameter -PatternName $PatternName
						switch ($MaxRotateAngle.DataIsCorrect) {
                            $false {
                                ShowMessageWrongConf -Section $Section -PatternName $PatternName -ParameterName $Parameter.ParamName -ErrorMessage $MaxRotateAngle.ErrorMessage
								break;
							}
						}
						break;
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
                        'SpeedAdjust'	    = $SpeedAdjust.FormattedData;
                        'SpeedDecrease'	    = $SpeedDecrease.FormattedData;
                        'MinHeight'	 	   	= $MinHeight.FormattedData;
                        'MaxHeight'	    	= $MaxHeight.FormattedData;
                        'MaxUpDownAngle'    = $MaxUpDownAngle.FormattedData;
                        'MaxRotateAngle'    = $MaxRotateAngle.FormattedData;
                    }
                    return $PlanePatternConfiguration
                }
                $false {
					ShowMessageWrongConf -Section $Section -PatternName $PatternName -ErrorMessage "MinHeight param must be less than or equal to the MaxHeight param and MinSpeed param must be less than or equal to the MaxSpeed param"
					break;
                }
			}	
			break;
		}
		$false {
			ShowMessageWrongConf -Section $Section -PatternName $PatternName -ErrorMessage "Not enough parameters specified"
			break;
		}
	}
}
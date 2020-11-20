function CheckMainSectionConfiguration () {
    param (
        [parameter (Mandatory=$true)] [System.Xml.XmlNode] $MainSection
    )

    [System.Int32]$PlanesToGenerate = 0
    switch ($MainSection.ChildNodes.Count -eq 2) {
        $true {
            foreach ($Parameter in $MainSection.Param) {
                switch (($Parameter.ParamName -ne "") -and ($Parameter.Data -ne "") -and ($Parameter.ParamDataType -ne "")) {
                    $true {
                        switch ($Parameter.ParamName)
						{
							"PatternsToUse"
							{
                                [System.String[]]$PatternNames = $Parameter.Data.Split("|")
                                $PatternNames | % {if ($_ -eq ""){ShowMessageWrongConf -Section $MainSection.Name -ParameterName $Parameter.ParamName -ErrorMessage "Pattern name cannot be empty"}}
							}
							"EachPatternCount"
							{
								[System.String[]]$EachPatternCountStr = $Parameter.Data.Split("|")
								[System.Int16[]]$EachPatternCount = [System.Int16[]]::new($PatternNames.Length)
								for ($EPC = 0; $EPC -lt $PatternNames.Length; $EPC++)
								{
                                    $EachPatternCount[$EPC] = [System.Convert]::ToInt16($EachPatternCountStr[$EPC])
								}
							}
						}
                     }
                    $false {
                        ShowMessageWrongConf -Section $MainSection.Name -ErrorMessage "Not enough information about parameter!"
                    }
                }
            }
            $PatternsToUseAndPlanesToGenerate = @{ }
            for ($EachPatternNameIndex = 0; $EachPatternNameIndex -lt $PatternNames.Length; $EachPatternNameIndex++) {
                $TempData = @{}
                $TempData.Add("Count",$EachPatternCount[$EachPatternNameIndex])
                $TempData.Add("PatternName", $PatternNames[$EachPatternNameIndex])
                $PatternsToUseAndPlanesToGenerate.Add($EachPatternNameIndex.ToString(), $TempData)
                $PlanesToGenerate += $EachPatternCount[$EachPatternNameIndex]
            }
            $PatternsToUseAndPlanesToGenerate.Add("PlanesToGenerateCount",$PlanesToGenerate)
         }
        $false {
            ShowMessageWrongConf -Section $MainSection.Name -ErrorMessage "Not enough parameters specified"
        }
    }
    return $PatternsToUseAndPlanesToGenerate
}
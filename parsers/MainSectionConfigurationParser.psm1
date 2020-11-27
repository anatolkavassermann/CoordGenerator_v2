function CheckMainSectionConfiguration () {
    param (
        [parameter (Mandatory=$true)] [System.Xml.XmlNode] $MainSection,
        [parameter (Mandatory=$false)] [System.String] $EachPC = "low"
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
                                $PatternNames | ForEach-Object {if ($_ -eq ""){ShowMessageWrongConf -Section $MainSection.Name -ParameterName $Parameter.ParamName -ErrorMessage "Pattern name cannot be empty"}}
                                break;
							}
							"EachPatternCount"
							{
                                switch ($EachPC) {
                                    default {
                                        [System.Collections.ArrayList]$EachPatternCount = [System.Collections.ArrayList]::new()
                                        $EachPC.Split("|") | ForEach-Object {$tmp = 0; $s = [System.Int32]::TryParse($_, [ref] $tmp); if ($s -eq $true) {[void] $EachPatternCount.Add($tmp)}}
                                        break;
                                    }
                                    "low" {
                                        [System.Collections.ArrayList]$EachPatternCount = [System.Collections.ArrayList]::new()
                                        $Parameter.Data.Split("|") | ForEach-Object {$tmp = 0; $s = [System.Int32]::TryParse($_, [ref] $tmp); if ($s -eq $true) {[void] $EachPatternCount.Add($tmp)}}
                                        break;
                                    }
                                }
							}
                        }
                        break;
                    }
                    $false {
                        ShowMessageWrongConf -Section $MainSection.Name -ErrorMessage "Not enough information about parameter!"
                        break;
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
            break;
        }
        $false {
            ShowMessageWrongConf -Section $MainSection.Name -ErrorMessage "Not enough parameters specified"
            break;
        }
    }
    return $PatternsToUseAndPlanesToGenerate
}
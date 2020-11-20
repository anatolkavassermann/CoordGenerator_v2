function ShowMessageWrongConf {
    param {
        [System.String] $ErrorType,
        [System.String] $Section,
        [System.String] $ParameterName,
        [System.String] $PatternName,
        [System.String] $ErrorMessage
    }
    $ErrorData = [System.Text.StringBuilder]::new()
    switch ($ErrorType) {
        "File" {
            [void] $ErrorData.AppendLine("Error Message: " + $ErrorMessage)
            break;
        }
        default {
            [void] $ErrorData.AppendLine("Error Message: " + $ErrorMessage)
            [void] $ErrorData.AppendLine("Section: " + $Section)
            [void] $ErrorData.AppendLine("ParameterName: " + $ParameterName)
            [void] $ErrorData.AppendLine("PatternName: " + $PatternName)
            break;
        }
    }
    Write-Host -Object $ErrorData.ToString() -ForegroundColor Red
    pause
    exit;
}
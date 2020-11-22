param (
    [parameter(Mandatory=$false)] [System.Int32] $shift = 10000
)
$DataForExcel = [System.Collections.ArrayList]::new()
$i = 0
$TimeShift = $shift
$OutputConfigFile = gc "./conf/Output.txt"
$OutputConfigFile | % {
    $t = 0
    $s = [System.Int32]::TryParse($_.Substring(1,$_.IndexOf(">")-1), [ref] $t)
    if ($s -eq $true) {
        if ($t -ge $TimeShift) {
            $Matches = $OutputConfigFile | Select-String $_
            $k = $Matches.Matches.Count
            if ($k -gt 1) {
                $k = $Matches.LineNumber
                $k = $k[$k.Count-1]
            }
            if ($k -eq 1) {
                $k = $Matches.LineNumber
            }
            $Count = ($OutputConfigFile[$i..$k] | % {$j = $_ -split ";"; [array]::Reverse($j); return $j[0]} | sort -Unique).Count
            [void] $DataForExcel.Add(($TimeShift, $Count))
            $i = $k
            $TimeShift += $shift
        }
    }
}
Add-Type -AssemblyName Microsoft.Office.Interop.Excel
$xl = New-Object -ComObject Excel.Application
$xl.DisplayAlerts = $false
$OutputData = $DataForExcel|%{[PSCustomObject][Ordered]@{'Count'=$_[0];"TimeShift"=$_[1]}}
$wb = $xl.workbooks.Add()
$ws = $wb.ActiveSheet
$xl.Visible = $true
$OutputData | ConvertTo-Csv -NoTypeInformation -Delimiter "`t" | C:\Windows\System32\clip.exe
$ws.Range("A1").Select | Out-Null
$ws.paste()
$ws.UsedRange.Columns.AutoFit() | Out-Null
#TODO
#[void]($range = $WS.UsedRange)
#$transposedRange  = $xl.WorksheetFunction.Transpose($range.Value2)
#[void] $range.Delete()
#$xl.ActiveSheet.Range("A1").Resize($transposedRange.GetUpperBound(0), $transposedRange.GetUpperBound(1)) = $transposedRange
[void]$ws.UsedRange.Select()
$Chart = $ws.Shapes.AddChart().Chart
$Chart.ChartType = [Microsoft.Office.Interop.Excel.XLChartType]::xlLine
Pause
$wb.CLose()
$xl.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
Get-Process "*excel*" | ? {$_.MainWindowHandle -eq 0} | Stop-Process
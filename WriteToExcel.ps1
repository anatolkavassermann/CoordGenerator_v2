param (
    [parameter(Mandatory=$false)] [System.Int32] $shift = 20000
)
$DataForExcel = [System.Collections.ArrayList]::new()
$i = 0
$TimeShift = 0
$OutputConfigFile = gc "./conf/Output.txt"
$OutputConfigFile | % {
    $t = 0
    $s = [System.Int32]::TryParse($_.Substring(1,$_.IndexOf(">")-1), [ref] $t)
    if ($s -eq $true) {
        if ($t -ge $TimeShift) {
            $Matchess = $OutputConfigFile | Select-String $_
            switch ($Matchess.Matches.Count -eq 1) {
                $true {
                    $k = $Matchess.LineNumber
                    break;
                }
                $false {
                    $k = $Matchess.LineNumber[$Matchess.LineNumber.Count-1]
                    break;
                }
            }
            $Count = (($OutputConfigFile[$i..$k] | foreach {$_ -split ";" | select -Index 3}) | sort -Unique).Count
            [void] $DataForExcel.Add(($TimeShift,$Count))
            $i = $k
            $TimeShift += $shift
        }
    }
}
[void] $DataForExcel.Add(($TimeShift,0))
Add-Type -AssemblyName Microsoft.Office.Interop.Excel
$xl = New-Object -ComObject Excel.Application
$xl.DisplayAlerts = $false
$OutputData = $DataForExcel | % { [PSCustomObject][Ordered]@{"TimeShift" = $_[0]; 'Count'=$_[1]}} | ConvertTo-Csv -NoTypeInformation -Delimiter "`t" 
$wb = $xl.workbooks.Add()
[void] $wb.ActiveSheet.Select()
$ws = $wb.ActiveSheet
$xl.Visible = $true
$OutputData | Set-Clipboard
[void] $ws.Range("A1").Select()
$ws.paste()
[void] $ws.UsedRange.Columns.AutoFit()
$r = $ws.UsedRange
$tr = $xl.WorksheetFunction.Transpose($r.Value2)
$r.Delete()
$xl.ActiveSheet.Range("A1").Resize($tr.GetUpperBound(0), $tr.GetUpperBound(1)) = $tr
$Chart = $ws.Shapes.AddChart().Chart
$Chart.Parent.Height = 560
$Chart.Parent.Width = 1000
$Chart.ChartType = [Microsoft.Office.Interop.Excel.XLChartType]::xlXYScatterLinesNoMarkers
$Chart.SetSourceData($ws.UsedRange, [Microsoft.Office.Core.XlAxisType]::xlCategory)
#$Chart.Axes([Microsoft.Office.Core.XlAxisType]::xlCategory).AxisBetweenCategories = $false 
Pause
$wb.CLose()
$xl.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
Get-Process "*excel*" | ? {$_.MainWindowHandle -eq 0} | Stop-Process
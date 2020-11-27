param (
    [parameter(Mandatory=$false)] [System.Int32] $shift = 20000,
    [parameter(Mandatory=$false)] [System.Int32] $finish = 0
)

switch ([System.Environment]::OSVersion.VersionString -match "Unix") {
    $true { 
        Write-Host -ForegroundColor Red -Object "Excel does not support Unix! Exiting"
        exit;
    }
}
$DataForExcel = [System.Collections.ArrayList]::new()
$i = 0
$TimeShift = 0
$OutputConfigFile = gc "./conf/Output1.txt"
$lineCount = 0
$t = 0
while ($lineCount -lt $OutputConfigFile.Count-1) {
    [void] [System.Int32]::TryParse($OutputConfigFile[$lineCount].Substring(1,$OutputConfigFile[$lineCount].IndexOf(">")-1), [ref] $t)
    if ($t -lt $TimeShift) {
        while ($t -lt $TimeShift) {
            try {
                [void] [System.Int32]::TryParse($OutputConfigFile[$lineCount].Substring(1,$OutputConfigFile[$lineCount].IndexOf(">")-1), [ref] $t)
            }
            catch {
                break;
            }
            $lineCount++
        }
        $lineCount--
        $Cnt = (($OutputConfigFile[$i..($lineCount-1)] | foreach {$_ -split ";" | select -Index 3}) | sort -Unique).Count
        [void] $DataForExcel.Add(($TimeShift, $Cnt))
        $i = $lineCount-1
        $TimeShift += $shift
    }
    if (($t -gt $finish) -and ($finish -ne 0)) {
        break;
    }
    if ($t -ge $TimeShift) {
        [void] $DataForExcel.Add(($TimeShift,0))
        $TimeShift += $shift
    }
}
switch ($finish) {
    0 {
        [void] $DataForExcel.Add(($TimeShift,0))
    }
}
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
$r = $ws.UsedRange
$tr = $xl.WorksheetFunction.Transpose($r.Value2)
$r.Delete()
$xl.ActiveSheet.Range("A1").Resize($tr.GetUpperBound(0), $tr.GetUpperBound(1)) = $tr
[void] $ws.UsedRange.Columns.AutoFit()
$Chart = $ws.Shapes.AddChart().Chart
$Chart.Parent.Height = 280
$Chart.Parent.Width = 500
$Chart.ChartType = [Microsoft.Office.Interop.Excel.XLChartType]::xlXYScatterLinesNoMarkers
$Chart.SetSourceData($ws.UsedRange, [Microsoft.Office.Core.XlAxisType]::xlCategory) 
Pause
$wb.CLose()
$xl.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
Get-Process "*excel*" | ? {$_.MainWindowHandle -eq 0} | Stop-Process
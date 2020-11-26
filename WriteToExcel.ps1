param (
    [parameter(Mandatory=$true)] [System.Int32] $shift = 20000,
    [parameter(Mandatory=$true)] [System.Int32] $finish = 0
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
$OutputConfigFile = gc "./conf/Output.txt"
$OutputConfigFile | % {
    if (($TimeShift -gt $finish) -and ($finish -ne 0)) {
        return;
    }
    #Write-Host "done"
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
[void] $ws.UsedRange.Columns.AutoFit()
$r = $ws.UsedRange
$tr = $xl.WorksheetFunction.Transpose($r.Value2)
$r.Delete()
$xl.ActiveSheet.Range("A1").Resize($tr.GetUpperBound(0), $tr.GetUpperBound(1)) = $tr
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
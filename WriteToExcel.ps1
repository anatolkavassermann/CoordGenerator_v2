[System.String[]]$AllMillisecondsStr = gc -Path "./conf/Output.txt" | % {$_.Substring(1,$_.IndexOf("t")-1)}
[System.Int64[]]$AllMilliseconds = $AllMillisecondsStr | Sort-Object -Unique
[System.Array]::Sort($AllMilliseconds)
$OutputConfigFile = Get-Content "./conf/Output.txt"
$DataForExcel = [System.Collections.ArrayList]::new()
$shift = 5000
$Count = 0
$i = 0
$l = 0
while ($i -lt $AllMilliseconds.Count-1) {
    while (($AllMilliseconds[$i] -le $shift) -and ($i -lt $AllMilliseconds.Count)) {
        $i++
    }
    if ($i -gt $AllMilliseconds.Count-1) {
        $i --
    }
    $k = ($OutputConfigFile| Select-String -Pattern ("s" + $AllMilliseconds[$i] + "t")).Matches.Count
    if ($k -gt 1) {
        $k = ($OutputConfigFile| Select-String -Pattern ("s" + $AllMilliseconds[$i] + "t")).LineNumber
        $k = $k[$k.Count-1]
    }
    if ($k -eq 1) {
        $k = ($OutputConfigFile| Select-String -Pattern ("s" + $AllMilliseconds[$i] + "t")).LineNumber
    }
    $Count = ($OutputConfigFile[$l..$k] | % {$j = $_.Substring($_.IndexOf("t")+1,$_.Length -$_.IndexOf("t")-1 ) -split ";"; [array]::Reverse($j); return $j[0]} | Sort-Object -Unique).Count
    [void] $DataForExcel.Add(($shift,$Count))
    $l = $k
    $shift+= 10000
}

Add-Type -AssemblyName Microsoft.Office.Interop.Excel
$xl = New-Object -ComObject Excel.Application
$xl.DisplayAlerts = $false
$OutputData = $DataForExcel|ForEach-Object{[PSCustomObject][Ordered]@{'Milliseconds'=$_[0];'Count'=$_[1]}}
$wb = $xl.workbooks.Add()
$ws = $wb.ActiveSheet
$xl.Visible = $true

$OutputData | ConvertTo-Csv -NoTypeInformation -Delimiter "`t" | C:\Windows\System32\clip.exe
$ws.Range("A1").Select | Out-Null
$ws.paste()
$ws.UsedRange.Columns.AutoFit() | Out-Null

$ws.Range("B1:B"+$DataForExcel.Count).Select()
$Chart = $ws.Shapes.AddChart().Chart
$Chart.ChartType = [Microsoft.Office.Interop.Excel.XLChartType]::xlLine
Pause
$wb.CLose()
$xl.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
Get-Process "*excel*" | ? {$_.MainWindowHandle -eq 0} | Stop-Process
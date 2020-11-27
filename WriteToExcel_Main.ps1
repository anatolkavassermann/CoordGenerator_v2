param (
    [parameter(Mandatory=$false)] [System.Int32] $shift = 10000,
    [parameter(Mandatory=$false)] [System.Int32] $finish = 1500000,
    [parameter(Mandatory=$false)] [System.Int32] $c = 1
)
function CountDataForExcel_Count {
    param (
        [parameter(Mandatory=$true)] [System.String[]] $File,
        [parameter(Mandatory=$true)] [System.String] $_OutputConfigFilepath,
        [parameter(Mandatory=$true)] [System.Int64] $_finish,
        [parameter(Mandatory=$true)] [System.Int64] $_shift
    )
    $Count = [System.Collections.ArrayList]::new()
    $TimeShift = 0
    $i = 0
    $lineCount = 0
    $t = 0
    while ($lineCount -lt $file.Count) {
        [void] [System.Int32]::TryParse($file[$lineCount].Substring(1,$file[$lineCount].IndexOf(">")-1), [ref] $t)
        if ($t -lt $TimeShift) {
            $lineCount--
            while ($t -lt $TimeShift) {
                $lineCount++
                try {
                    [void] [System.Int32]::TryParse($file[$lineCount].Substring(1,$file[$lineCount].IndexOf(">")-1), [ref] $t)
                }
                catch {
                    break;
                }
            }
            $Cnt = (($File[$i..($lineCount-1)] | foreach {$_ -split ";" | select -Index 3}) | sort -Unique).Count
            [void] $Count.Add($Cnt)
            $i = $lineCount-1
            $TimeShift += $_shift
        }
        if (($t -gt $_finish) -and ($_finish -ne 0)) {
            break;
        }
        if ($t -ge $TimeShift) {
            [void] $Count.Add(0)
            $TimeShift += $_shift
        }
    }
    ac -Path $_OutputConfigFilepath -Value $file -NoNewline:$false
    if (($_finish -eq 0) -or ($_finish -gt $TimeShift)) {
        [void]$Count.Add(0)
    }
    return $Count
}
function WriteTo-Excel {
    param (
        [parameter(Mandatory=$true)] $_DataForExcel_Count,
        [parameter(Mandatory=$true)] [System.Int64] $_finish,
        [parameter(Mandatory=$true)] [Bool] $ifAvg,
        [parameter(Mandatory=$true)] $_wb,
        [parameter(Mandatory=$true)] $Chart
    )
    [System.Collections.ArrayList] $DataForExcel_TimeShift =  [System.Collections.ArrayList]::new()
    $maxCount = 0
    $_DataForExcel_Count | % {if ($_.Count -ge $maxCount) {$maxCount = $_.Count}}
    for ($ts = 0; $ts -le $maxCount*$shift+1; $ts += $shift) {
        [void] $DataForExcel_TimeShift.Add($ts)
    }
    switch ($ifAvg) {
        $false {
            [System.Collections.ArrayList] $OutputData_Count = [System.Collections.ArrayList]::new()
            for ($ind = 0; $ind -lt $maxCount; $ind++) {
                $tmp = [Ordered]@{}
                $tmp.Add("timeShift",$DataForExcel_TimeShift[$ind])
                for ($_ind = 0; $_ind -lt $_DataForExcel_Count.Count; $_ind++) {
                    if ($null -eq $_DataForExcel_Count[$_ind][$ind]) {
                        $tmp.Add("iteration $_ind",0)
                    }
                    elseif ($null -ne $_DataForExcel_Count[$_ind][$ind]) {
                        $tmp.Add("iteration $_ind", $_DataForExcel_Count[$_ind][$ind])
                    }
                }
                [void] $OutputData_Count.Add($tmp)
            }
            break;
        }
        $true {
            [System.Collections.ArrayList] $OutputData_Count = [System.Collections.ArrayList]::new()
            for ($ind = 0; $ind -lt $maxCount; $ind++) {
                $tmp = [Ordered]@{}
                $tmp.Add("timeShift",$DataForExcel_TimeShift[$ind])
                [double] $Avg = 0;
                for ($_ind = 0; $_ind -lt $_DataForExcel_Count.Count; $_ind++) {
                    if ($null -eq $_DataForExcel_Count[$_ind][$ind]) {
                        $Avg += 0
                    }
                    elseif ($null -ne $_DataForExcel_Count[$_ind][$ind]) {
                        $Avg += $_DataForExcel_Count[$_ind][$ind]
                    }
                }
                $tmp.Add("Count",$Avg)
                [void] $OutputData_Count.Add($tmp)
            }
            break;
        }
    }
    $OutputData_Count_1 = $OutputData_Count | % { [PSCustomObject]$_} | ConvertTo-Csv -NoTypeInformation -Delimiter "`t"
    switch ($ifAvg) {
        $true {
            $_wb.Worksheets['Avg'].select()
            $ws = $_wb.ActiveSheet
            break;
        }
        $false {
            $_wb.Worksheets['Iterations'].select()
            $ws = $_wb.ActiveSheet
            break;
        }
    }
    [void] $ws.UsedRange.Clear()
    [void] $ws.Range("A1").Select()
    $OutputData_Count_1 | Set-Clipboard
    $ws.Paste()
    $r = $ws.UsedRange
    $tr = $xl.WorksheetFunction.Transpose($r.Value2)
    [void] $r.Delete()
    $xl.ActiveSheet.Range("A1").Resize($tr.GetUpperBound(0), $tr.GetUpperBound(1)) = $tr
    [void] $ws.UsedRange.Columns.AutoFit()
    $Chart.SetSourceData($ws.UsedRange, [Microsoft.Office.Core.XlAxisType]::xlCategory) 
    Pause   
}
switch ([System.Environment]::OSVersion.VersionString -match "Unix") {
    $true { 
        Write-Host -ForegroundColor Red -Object "Excel does not support Unix! Exiting"
        exit;
    }
}
$j = 0
Add-Type -AssemblyName Microsoft.Office.Interop.Excel
$xl = New-Object -ComObject Excel.Application
$xl.Visible = $true
$xl.DisplayAlerts = $false
$wb = $xl.workbooks.Add()
$ws = $wb.Worksheets.Add()
$ws.Select()
$ws.Name = "Iterations"
$ChartNoAvg = $ws.Shapes.AddChart().Chart
$ChartNoAvg.Parent.Height = 280
$ChartNoAvg.Parent.Width = 1000
$ChartNoAvg.ChartType = [Microsoft.Office.Interop.Excel.XLChartType]::xlXYScatterLinesNoMarkers
$ChartNoAvg.Axes([Microsoft.Office.Core.XlAxisType]::xlCategory).MajorUnit = $shift
#$ChartNoAvg.Axes([Microsoft.Office.Core.XlAxisType]::xlCategory).MajorUnit = $shift
$ws1 = $wb.Worksheets.Add()
$ws1.Select()
$ws1.Name = "Avg"
$ChartAvg = $ws1.Shapes.AddChart().Chart
$ChartAvg.Parent.Height = 280
$ChartAvg.Parent.Width = 1000
$ChartAvg.ChartType = [Microsoft.Office.Interop.Excel.XLChartType]::xlXYScatterLinesNoMarkers
$ChartAvg.Axes([Microsoft.Office.Core.XlAxisType]::xlCategory).MajorUnit = $shift
$wb.Worksheets[$wb.Worksheets.Count].Delete()
$OutputConfigFile = gci "./conf/Output.txt" | rvpa
Test-Path ".\conf\Output1.txt" | ForEach-Object {if ($_ -eq $false) {New-Item -i File -p ".\conf\Output1.txt" | Resolve-Path}; if ($_ -eq $true) {Get-ChildItem ".\conf\Output1.txt" | Resolve-Path}} | Set-Variable OutputConfigFilepath
sc -Path $OutputConfigFilepath -Value $null
$Main = gci "./Main.ps1" | rvpa
[System.Collections.ArrayList] $DataForExcel_Count =  [System.Collections.ArrayList]::new()
0..$c | % {
    (Read-Host -Prompt "Do you want to exit? [y/n]") | sv IfExit 
    if ($IfExit -eq "y") {
            Read-Host -Prompt "Save data before exiting. If you exit, all unsaved data will be lost"
            $wb.CLose()
            $xl.Quit()
            [System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
            Get-Process "*excel*" | ? {$_.MainWindowHandle -eq 0} | Stop-Process
            break;
        
    }
    (Read-Host -Prompt "Input InitialTime. Default is 0") -as [int] | sv InitialTime 
    (Read-Host -Prompt "Set pattern Count. Default is set in main_conf.xml") -as [String] | sv EachPC
    switch ($EachPC) {
        "" {
            $EachPC = "low"
            break;
        }
    }
    & $Main -InitialTime ($InitialTime) -EachPC ($EachPC); 
    $t = gc $OutputConfigFile; 
    $flag = $false ;
    while ($flag -eq $false) {
        try {
            sc -Value $null -Path $OutputConfigFile -ErrorAction Stop;
            sleep -Milliseconds 1000;
            $flag = $true
        }
        catch {
            Sleep -Milliseconds 1000
        }
    }
    [void] $DataForExcel_Count.Add((CountDataForExcel_Count -File $t -_OutputConfigFilepath $OutputConfigFilepath -_finish $finish -_shift $shift))
    (Read-Host -Prompt "Do you want to view excel? [y/n]") -as [String] | sv ViewExcel
    switch ($ViewExcel) {
        "y" {
            WriteTo-Excel -_DataForExcel_Count $DataForExcel_Count -_finish $finish -ifAvg $false -_wb $wb -Chart $ChartNoAvg
        }
        "" {
            WriteTo-Excel -_DataForExcel_Count $DataForExcel_Count -_finish $finish -ifAvg $false -_wb $wb -Chart $ChartNoAvg
        }
    }
    (Read-Host -Prompt "Do you want to view excel with avg data? [y/n]") -as [String] | sv ViewExcel
    switch ($ViewExcel) {
        "y" {
            WriteTo-Excel -_DataForExcel_Count $DataForExcel_Count -_finish $finish -ifAvg $true -_wb $wb -Chart $ChartAvg
        }
        "" {
            WriteTo-Excel -_DataForExcel_Count $DataForExcel_Count -_finish $finish -ifAvg $true -_wb $wb -Chart $ChartAvg
        }
    }
}
$wb.CLose()
$xl.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($xl) | Out-Null
Get-Process "*excel*" | ? {$_.MainWindowHandle -eq 0} | Stop-Process
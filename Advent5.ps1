[CmdletBinding(PositionalBinding = $False)]
param(
    [string]$testFile
)

$inputs = Get-Content -Path $testFile

$lines = $inputs | ForEach-Object { 
    if($_ -match "(\d+,\d+) -> (\d+,\d+)")
    {
        return @{ 
            Start = ($Matches.1).Split(",") | ForEach-Object{ [int]::Parse($_)} 
            End = ($Matches.2).Split(",") | ForEach-Object{ [int]::Parse($_)} 
        }
    }
}

$onlyAxisAlignedLines = $lines | Where-Object { ($_.Start[0] -eq $_.End[0]) -or ($_.Start[1] -eq $_.End[1])}

$touchedCoords = @{}

function Clamp {
    param (
        [int]$val,
        [int]$lowerbound,
        [int]$upperbound
    )
    return [Math]::Min([Math]::Max($val,$lowerbound),$upperbound)
}

function AddVector {
    param (
        [int[]]$A,
        [int[]]$B
    )
    return [int[]]@( [int]($A[0]+$B[0]) , [int]($A[1]+$B[1]) )
}

$onlyAxisAlignedLines | ForEach-Object {
    $start = $_.Start
    $end = $_.End
    $runningDir = @( (Clamp -val ($end[0]-$start[0]) -lowerbound -1 -upperbound 1) , (Clamp -val ($end[1]-$start[1]) -lowerbound -1 -upperbound 1) )
    for($currentCoord = $start; $currentCoord[0] -ne $end[0]+$runningDir[0] -or $currentCoord[1] -ne $end[1]+$runningDir[1]; $currentCoord = (AddVector -A $currentCoord -B $runningDir)){

        $key = $currentCoord -join ","
        if(-not $touchedCoords.ContainsKey($key)){
            $touchedCoords.Add($key,@{Touches = 0})
        }
        $touchedCoords[$key].Touches = ([int]$touchedCoords[$key].Touches) + 1
    }

}

Write-Output "Part1 Line overlaps"
Write-Output ($touchedCoords.Keys | Where-Object { ($touchedCoords[$_].Touches) -gt 1} | ForEach-Object{$touchedCoords[$_]}).Count

$touchedCoords = @{}
$lines | ForEach-Object {
    $start = $_.Start
    $end = $_.End
    $runningDir = @( (Clamp -val ($end[0]-$start[0]) -lowerbound -1 -upperbound 1) , (Clamp -val ($end[1]-$start[1]) -lowerbound -1 -upperbound 1) )
    for($currentCoord = $start; $currentCoord[0] -ne $end[0]+$runningDir[0] -or $currentCoord[1] -ne $end[1]+$runningDir[1]; $currentCoord = (AddVector -A $currentCoord -B $runningDir)){

        $key = $currentCoord -join ","
        if(-not $touchedCoords.ContainsKey($key)){
            $touchedCoords.Add($key,@{Touches = 0})
        }
        $touchedCoords[$key].Touches = ([int]$touchedCoords[$key].Touches) + 1
    }

}

Write-Output "Part2 Line overlaps"
Write-Output ($touchedCoords.Keys | Where-Object { ($touchedCoords[$_].Touches) -gt 1} | ForEach-Object{$touchedCoords[$_]}).Count
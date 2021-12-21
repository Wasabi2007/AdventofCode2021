[CmdletBinding(PositionalBinding = $False)]
param(
    [string]$testFile,
    [int]$sleepMS,
    [Switch]$Animate
)

$eneregymap = @{    
    energyMapData = Get-Content -Path $testFile | ForEach-Object { 
        $row = $_.ToCharArray() | ForEach-Object { [int]::Parse($_)}
        return ,[int[]]$row
    }
}
$eneregymap +=  @{ 
    collumCount = $eneregymap.energyMapData.Length
    rowCount = $eneregymap.energyMapData[0].Length
}

Write-Output $eneregymap
Write-Output $eneregymap.energyMapData | ForEach-Object { $_ -join ","}

$simulationSteps = 1000
$flashes = 0
for ($simulationStep = 0; $simulationStep -lt $simulationSteps; $simulationStep++) {
    $eneregymap.energyMapData = $eneregymap.energyMapData | ForEach-Object { ,[int[]]($_ | ForEach-Object { $_+1})}
    $FlashyOctopus = @()
    $eneregymap.energyMapData | ForEach-Object {$x = 0}{ ($_ | ForEach-Object {$y = 0}{ if( $_ -gt 9){$FlashyOctopus +=, @($x,$y)}; $y++ });  $x++ }

    #Write-Output (($FlashyOctopus | ForEach-Object { $_ -join ","}) -join " | ")
    $stepflashes = 0
    while ($FlashyOctopus.Length -gt 0) {
        $pos, $FlashyOctopus = $FlashyOctopus
        if($FlashyOctopus.Length -eq 2 -and $FlashyOctopus[0].Length -eq 1)
        {
            $FlashyOctopus = @(,@($FlashyOctopus[0][0],$FlashyOctopus[1][0]))
        }

        $x = $pos[0]
        $y = $pos[1]
        if($eneregymap.energyMapData[$x][$y] -eq 0) {continue}

        #Write-Debug ($pos -join ",")
        $eneregymap.energyMapData[$x][$y] = 0

        $stepflashes++;

       
        for ($xoff = -1; $xoff -le 1; $xoff++) {
            $currentX = $x+$xoff
            if($currentX -ge $eneregymap.collumCount -or $currentX -lt 0) {continue}
            for ($yoff = -1; $yoff -le 1; $yoff++) {
                $currentY = $y+$yoff
                if($currentY -ge $eneregymap.rowCount -or $currentY -lt 0) {continue}
                if($eneregymap.energyMapData[$currentX][$currentY] -eq 0) {continue}

                $eneregymap.energyMapData[$currentX][$currentY]++
                if($eneregymap.energyMapData[$currentX][$currentY] -gt 9) {
                    $FlashyOctopus +=, @($currentX,$currentY)
                }
            }
        }
        #Write-Output (($FlashyOctopus | ForEach-Object { $_ -join ","}) -join " | ")
    }
    $flashes += $stepflashes
    if($Animate){Clear-Host}
    Write-Host "step $($simulationStep+1) : "
    $eneregymap.energyMapData | ForEach-Object { 
        $_ | ForEach-Object {
            if($_ -eq 0){
                Write-Host $_ -Foreground Red -NoNewLine
            } else {
                Write-Host $_ -Foreground Green -NoNewLine
            }
        }
        Write-Host 
    }
    Start-Sleep -Milliseconds $sleepMS

    if($stepflashes -ge ($eneregymap.collumCount * $eneregymap.rowCount))
    {
        Write-Host "all flashed at step $($simulationStep+1)"
        break
    }
}

Write-Host $flashes
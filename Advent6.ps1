[CmdletBinding(PositionalBinding = $False)]
param(
    [string]$testFile
)

$inputs = Get-Content -Path $testFile

$fishlives = @()
$newfishlives = @()

$inputs | ForEach-Object{
    $fishlives += ([string]$_).Split(",") | ForEach-Object { [int]::Parse($_)}
}

$fishcount = $fishlives.Count
$daysOfSimulation = 256

function Offsprings($timeTillNextOffspring){
    $newfishcount = 0;
    $offspringCount = [int]([Math]::Floor(((($daysOfSimulation-1)-($timeTillNextOffspring))/7)))+1
    $newfishcount += $offspringCount
    for($offspring = 0; $offspring -lt $offspringCount; $offspring++)
    {
        $nextTimeTillNextOfspring = ($timeTillNextOffspring+8 + ($offspring*7)+1)
        if($nextTimeTillNextOfspring -gt $daysOfSimulation){
            continue
        }

        $newfishcount += (Offsprings $nextTimeTillNextOfspring)
    }
    return $newfishcount
}
$precomp = @{}
1..5 | ForEach-Object {
    $precomp += @{ "$_" = (Offsprings $_)}
}
Write-Output $precomp

$fishlives | ForEach-Object {
    Write-Output $fishcount
    $fishcount += $precomp["$_"]
}

#for($day = 0; $day -lt $daysOfSimulation; $day++)
#{
    #$fishcount += $fishlives.Count;

#    if($fishlives.Count -le 0){
#        break
#    }

#    Write-Output "Day $day Predicted amount of fishes:"
#    Write-Output $fishcount
    #Write-Output ($fishlives -join ",")

#    $fishlives | ForEach-Object {
#        $timeTillNextOffspring = $_
#        if($timeTillNextOffspring -gt $daysOfSimulation){
#            return
#        }
#        $offspringCount = [int]([Math]::Floor(((($daysOfSimulation-1)-($timeTillNextOffspring))/7)))+1
        #Write-Output "timeTillNextOffspring:$timeTillNextOffspring offspringCount: $offspringCount"
#        $fishcount += $offspringCount
#        for($offspring = 0; $offspring -lt $offspringCount; $offspring++)
#        {
#            $nextTimeTillNextOfspring = ($timeTillNextOffspring+8 + ($offspring*7)+1)
#            if($nextTimeTillNextOfspring -gt $daysOfSimulation){
#                return
#            }
#            $newfishlives += ,$nextTimeTillNextOfspring
#        }
#    }
#    $fishlives = $newfishlives
#    $newfishlives = @()

#    $fishlives = $fishlives | ForEach-Object {
#        if($_ -le 0)
#        {
#            $newfishlives += ,8
#            return 6
#        }
#        return $_-1
#    }
#    $fishlives += $newfishlives
#    $newfishlives = @()

#}

Write-Output "Part 1 amount of fishes:"
Write-Output $fishcount
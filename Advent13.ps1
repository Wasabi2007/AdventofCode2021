[CmdletBinding(PositionalBinding = $False)]
param(
    [string]$testFile
)
$ErrorActionPreference = "Stop"
$inputLines = Get-Content -Path $testFile

$dots = @()
$foldInstructions = @()
$max = @(0,0)


$inputLines | ForEach-Object {$pointsRead = $false}{
    $pointsRead = $pointsRead -or $_ -eq ""
    #Write-Debug $_
    if (-not $pointsRead) {
        $dot = ($_.Split(",") | ForEach-Object{ [int]::Parse($_)})
        $dots += ,$dot
        $max[1] = [Math]::Max($max[1],$dot[1])
        $max[0] = [Math]::Max($max[0],$dot[0])
    }else {
        if($_ -cmatch '^fold along ([xy])=(\d+)$'){
            $foldInstructions += ,@{
                axis = $Matches.1
                coord = [int]::Parse($Matches.2)
            }
        }
    }
}

function printDots ($dots, [int[]]$borders) {
    $matrix = 0..$borders[1] | ForEach-Object { ,(0..$borders[0] | ForEach-Object {,"."}) }
    $dots | ForEach-Object{$count = 0}{
        Write-Host "$count : $($_[0]),$($_[1])"
        $matrix[$_[1]][$_[0]] = "#"
        $count++
    }
    return $matrix | ForEach-Object{ ,($_ -join "") }
}
Write-Output ($max -join "|")
#Write-Output (printDots $dots $max)
#Write-Output ($dots | ForEach-Object { $_ -join ","})
Write-Output $dots.Length
#Write-Output $foldInstructions

for ($instructionCount = 0; $instructionCount -lt 10 -and $foldInstructions.Length -gt 0; $instructionCount++) {
    $instruction, $foldInstructions = $foldInstructions
    $axis = if($instruction.axis -eq "x") {0} else {1}
    $dots = $dots | ForEach-Object { 
        $dot = $_
        if($axis -eq 1)
        {
            if($dot[$axis] -ge $instruction.coord)
            {
                $dot[$axis] = ($max[$axis]-$instruction.coord)-($dot[$axis]-$instruction.coord)
            }
        } else {
            if($dot[$axis] -le ($instruction.coord-1))
            {
                $dot[$axis] = ($max[$axis]-($instruction.coord))+($instruction.coord-$dot[$axis])
            }
            $dot[$axis] -= (($max[$axis]-($instruction.coord))+1)
        }        
        return ,$dot
    }

    $max[$axis] -= ($instruction.coord+1)    

    $dots = $dots | Select-Object -Unique
    Write-Output "after instruction $instructionCount, dots left: $(($dots).Length)"
    Write-Output ($max -join "|")
    Write-Output ($dots | ForEach-Object {$count = 0}{ "$count : $($_ -join ",")";$count++})
    Write-Output (printDots $dots $max)
}

Write-Output (printDots $dots $max)


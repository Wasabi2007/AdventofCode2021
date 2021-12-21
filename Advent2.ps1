[CmdletBinding(PositionalBinding = $False)]
param(
    [string]$testFile
)

$instructions = Get-Content -Path $testFile

$forwardPosition = 0
$depthPosition = 0

$instructions | ForEach-Object {
    $instructionPair = ([string]$_).Split(" ")
    switch ($instructionPair[0]) {
        "forward" { $forwardPosition += [int]$instructionPair[1] }
        "down" { $depthPosition += [int]$instructionPair[1] }
        "up" { $depthPosition -= [int]$instructionPair[1] }
        Default { throw }
    }
}

$combined = $forwardPosition*$depthPosition
Write-Output "Part 1 forwardPosition: $forwardPosition depthPosition: $depthPosition = $combined"


$forwardPosition = 0
$depthPosition = 0
$aim = 0

$instructions | ForEach-Object {
    $instructionPair = ([string]$_).Split(" ")
    switch ($instructionPair[0]) {
        "forward" { 
            $forwardPosition += [int]$instructionPair[1]
            $depthPosition += $aim*[int]$instructionPair[1]
         }
        "down" { 
            $aim += [int]$instructionPair[1] 
        }
        "up" { 
            $aim -= [int]$instructionPair[1] 
        }
        Default { throw }
    }
}

$combined = $forwardPosition*$depthPosition
Write-Output "Part 2 forwardPosition: $forwardPosition depthPosition: $depthPosition = $combined"
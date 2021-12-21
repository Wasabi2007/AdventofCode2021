[CmdletBinding(PositionalBinding = $False)]
param(
    [string]$testFile
)

$inputs = Get-Content -Path $testFile | ForEach-Object { ([string]$_).Split(",") } | ForEach-Object { [int]::Parse($_) }

$messure = $inputs | Measure-Object -Sum -Maximum -Minimum


function fuelCost([int[]] $positions, [int] $targetPosition)
{
    return ($positions | ForEach-Object { [Math]::Abs($_ - $targetPosition) } | Measure-Object -Sum).Sum
}

function fuelCost2([int[]] $positions, [int] $targetPosition)
{
    return ($positions | ForEach-Object { ([Math]::Abs($_ - $targetPosition) * [Math]::Abs($_ - $targetPosition) + [Math]::Abs($_ - $targetPosition)) / 2} | Measure-Object -Sum).Sum
}

$lowerbound = $messure.Minimum
$upperbound = $messure.Maximum

while ($lowerbound -ne $upperbound) {
    $middle = [int]((($upperbound-$lowerbound)/2 + $lowerbound))
    Write-Output "$lowerbound $middle $upperbound"

    $fuelcostl = fuelCost2 $inputs ($middle-1)
    $fuelcostm = fuelCost2 $inputs $middle
    $fuelcostu = fuelCost2 $inputs ($middle+1)

    Write-Output "$fuelcostl $fuelcostm $fuelcostu"


    if($fuelcostl -ge $fuelcostm -and $middle -ne $lowerbound) {
        $lowerbound = $middle
    } elseif ($fuelcostu -ge $fuelcostm -and $middle -ne $upperbound) {
        $upperbound = $middle
    } elseif ($fuelcostl -lt $fuelcostm) {
        $upperbound = $lowerbound
    } elseif ($fuelcostm -lt $fuelcostu) {
        $lowerbound = $upperbound
    }
}

$fuelcostn1 = fuelCost2 $inputs ($lowerbound-1)
$fuelcost0 = fuelCost2 $inputs $lowerbound
$fuelcost2 = fuelCost2 $inputs ($lowerbound+1)

Write-Output $fuelcostn1
Write-Output $fuelcost0
Write-Output $fuelcost2


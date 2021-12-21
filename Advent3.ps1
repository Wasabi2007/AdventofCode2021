[CmdletBinding(PositionalBinding = $False)]
param(
    [string]$testFile
)

$readings = Get-Content -Path $testFile
$Zeros = @( )
$Ones = @( )

$readings | ForEach-Object {
    $reading = [string]$_;
    while($Zeros.Length -lt $reading.Length){
        $Zeros += @(0)
    }
    while($Ones.Length -lt $reading.Length){
        $Ones += @(0)
    }
    for($i=0; $i -lt $reading.Length; $i++){
        if($reading[$i] -eq "0") {
            $Zeros[$i]++
        } else {
            $Ones[$i]++
        }
    }
}

Write-Output ($Zeros -join ",") 
Write-Output ($Ones -join ",") 

$gamma = "";
$epsilon = "";

for($i=0; $i -lt $Zeros.Length; $i++){
    if($Zeros[$i] -gt $Ones[$i]) {
        $gamma+="0"
        $epsilon+="1"
    } else {
        $gamma+="1"
        $epsilon+="0"
    }
}

$gammaDeci = [System.Convert]::ToInt32($gamma,2)
$epsilonDeci = [System.Convert]::ToInt32($epsilon,2)

$finalpower = $gammaDeci * $epsilonDeci
Write-Output "part 1 gammaDeci: $gammaDeci epsilonDeci: $epsilonDeci = $finalpower"

function FindNumber {
    param (
        [string[]]$workingSet,
        [switch] $keepMostCommon
    )
    for($i=0; $workingSet.Length -gt 1; $i++)
    {
        $Zeros = 0
        $Ones = 0
        $workingSet | ForEach-Object {
            $reading = [string]$_;
            if($reading[$i] -eq "0") {
                $Zeros++
            } else {
                $Ones++
            }
        }
        $mostCommon = if($Zeros -gt $Ones){"0"}else{"1"}
        $leastCommon = if($Zeros -le $Ones){"0"}else{"1"}
        $checkCriteria = if($keepMostCommon){$mostCommon}else{$leastCommon}

        $workingSet = $workingSet | Where-Object { $_[$i] -eq $checkCriteria }

        
    }
    return $workingSet[0]
}

$oxygen = [System.Convert]::ToInt32((FindNumber -workingSet $readings -keepMostCommon),2)
$CO2 = [System.Convert]::ToInt32((FindNumber -workingSet $readings),2)
$finalrating = $oxygen * $CO2

Write-Output "part 2 oxygen: $oxygen CO2: $CO2 = $finalrating"
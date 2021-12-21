[CmdletBinding(PositionalBinding = $False)]
param(
    [string]$testFile
)

$heightmap = @{    
    heightMapData = Get-Content -Path $testFile | ForEach-Object { 
        $row = $_.ToCharArray() | ForEach-Object { [int]::Parse($_)}
        return ,[int[]]$row
    }
}
$heightmap +=  @{ 
    collumCount = $heightmap.heightMapData.Length
    rowCount = $heightmap.heightMapData[0].Length
}

Write-Output $heightmap
Write-Output $heightmap.heightMapData | ForEach-Object { $_ -join ","}

function FindLowesNeighbor($map,[int]$x, [int]$y) {
    #Write-Debug "$map $x $y"
    $lowestPoint = $map.heightMapData[$x][$y]
    
    if($x-1 -ge 0)
    {
        $lowestPoint = [Math]::Min($lowestPoint,$map.heightMapData[$x-1][$y])
    }
    if($x+1 -lt $map.collumCount)
    {
        $lowestPoint = [Math]::Min($lowestPoint,$map.heightMapData[$x+1][$y])
    }
    if($y-1 -ge 0)
    {
        $lowestPoint = [Math]::Min($lowestPoint,$map.heightMapData[$x][$y-1])
    }
    if($y+1 -lt $map.rowCount)
    {
        $lowestPoint = [Math]::Min($lowestPoint,$map.heightMapData[$x][$y+1])
    }
    return $lowestPoint
}


function HasLowerNeighbor($map,[int]$x, [int]$y) {
    #Write-Debug "$map $x $y"
    $lowestPoint = $map.heightMapData[$x][$y]
    if($lowestPoint -ge 9)
    {
        return $true
    }
    
    if($x-1 -ge 0 -and $map.heightMapData[$x-1][$y] -lt $lowestPoint)
    {
        return $true
    }
    if($x+1 -lt $map.collumCount -and $map.heightMapData[$x+1][$y] -lt $lowestPoint)
    {
        return $true
    }
    if($y-1 -ge 0 -and $map.heightMapData[$x][$y-1] -lt $lowestPoint)
    {
        return $true
    }
    if($y+1 -lt $map.rowCount -and $map.heightMapData[$x][$y+1] -lt $lowestPoint)
    {
        return $true
    }
    return $false
}

$lowestPoints = @()
$lowestPointCoords = @()

for ($x = 0; $x -lt $heightmap.collumCount; $x++) {
    for ($y = 0; $y -lt $heightmap.rowCount; $y++) {
        $samplePoint = $heightmap.heightMapData[$x][$y]
        #Write-Output "$samplePoint $x $y"
        $islowestPoint = HasLowerNeighbor $heightmap $x $y
        #Write-Output "$samplePoint $lowestPoint ($x $y)"
        if(-not $islowestPoint) {
            $lowestPoints += ,$samplePoint
            $lowestPointCoords += ,@{
                x=$x
                y=$y}
        }
    }
}

Write-Output $lowestPoints
#Write-Output $lowestPointCoords

$riskPoints = $lowestPoints | ForEach-Object { 1 + $_ }
Write-Output ($riskPoints | Measure-Object -Sum)


function BasinScore($map,[int]$x, [int]$y)
{    
    [int[][]]$openList = @()
    $openList = ,@(
        $x
        $y)

    $closedList = @()
    
    $basinSize = 0
    while($openList.Length -gt 0)
    {
        $pos, $openList = $openList
        $x = $pos[0]
        $y = $pos[1]

        if($openList.Length -eq 2 -and $openList[0].Length -eq 1)
        {
            $openList = @(,@($openList[0][0],$openList[1][0]))
        }
        #Write-Debug ($openList -join " | ")

        if(($closedList -contains "$x,$y"))
        {
            continue
        }

        $basinSize++
        $closedList += "$x,$y"
        #Write-Debug ($closedList -join " | ")
        #Write-Debug "$x,$y"

        [int[][]]$newOpen = @()

        if($x-1 -ge 0){
            if($map.heightMapData[$x-1][$y] -lt 9){
                #Write-Debug "left"
                $newOpen += ,[int[]]@(
                    ($x-1)
                    $y)
            }
        }
        if($x+1 -lt $map.collumCount){
            if($map.heightMapData[$x+1][$y] -lt 9){
                #Write-Debug "rigth"
                $newOpen += ,[int[]]@(
                    ($x+1)
                    $y)
            }
        }
        
        if($y-1 -ge 0){
            if($map.heightMapData[$x][$y-1] -lt 9){
            #Write-Debug "up"
            $newOpen += ,[int[]]@(
                $x
                ($y-1))
            }
        }
        if($y+1 -lt $map.rowCount){
            if($map.heightMapData[$x][$y+1] -lt 9){
                #Write-Debug "down"
                $newOpen += ,[int[]]@(
                    $x
                    ($y+1))
            }
        }
        #Write-Debug ($newOpen -join " | ")
        #Write-Debug $newOpen.ToString()
        #Write-Debug (($newOpen | ForEach-Object { $_ -join "," }) -join " | ")
        $newOpen | Where-Object { 
            $nposx = $_[0]
            $nposy = $_[1]
            return -not ($closedList -contains "$nposx,$nposy")} | ForEach-Object { $openList += ,$_ }
    }
    #Write-Debug ($closedList  -join " | ")

    return $basinSize
}

$basinsRiscScores =  $lowestPointCoords | ForEach-Object{ BasinScore $heightmap $_.x $_.y } | Sort-Object -Descending
Write-Output ($basinsRiscScores -join ",")

Write-Output ($basinsRiscScores[0] * $basinsRiscScores[1] * $basinsRiscScores[2])
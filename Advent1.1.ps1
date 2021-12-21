$lines = Get-Content -Path "Advent1.1.in"

$lastDepth = $null
$depthIncreases = 0

$lines | ForEach-Object { 
    if($lastDepth -eq $null){ $lastDepth= [int]$_}

    if($lastDepth -lt [int]$_ ){
        Write-Output "Depth Increases: $lastDepth -> $_"
        $depthIncreases++
    }
    else {
        Write-Output "Depth Decreases: $lastDepth -> $_"
    }      
    $lastDepth= [int]$_
}

Write-Output "Depth Increasesed $depthIncreases times"

$lastDepthWindow = $null
$depthDepthWindowIncreases = 0


for($i = 0; $i -lt $lines.Count-2; $i++ ) { 
    $currentDepth = [int]$lines[$i]+[int]$lines[$i+1]+[int]$lines[$i+2]
    if($null -eq $lastDepthWindow){ $lastDepthWindow= $currentDepth}

    if($lastDepthWindow -lt $currentDepth ){
        Write-Output "Depth Increases: $lastDepthWindow -> $currentDepth"
        $depthDepthWindowIncreases++
    }
    else {
        Write-Output "Depth Decreases: $lastDepthWindow -> $currentDepth"
    }      
    $lastDepthWindow= $currentDepth
}

Write-Output "Depth Window Increasesed $depthDepthWindowIncreases times"
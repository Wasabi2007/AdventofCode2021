[CmdletBinding(PositionalBinding = $False)]
param(
    [string]$testFile
)

$codeLines = Get-Content -Path $testFile
$graph = @{}

$codeLines | ForEach-Object {
    $pathElement = ([string]$_).Split("-")
    if(-not $graph.ContainsKey($pathElement[0])){
        $graph.Add($pathElement[0],@())
    }
    if(-not $graph.ContainsKey($pathElement[1])){
        $graph.Add($pathElement[1],@())
    }
    $graph[$pathElement[0]] += $pathElement[1]
    $graph[$pathElement[1]] += $pathElement[0]
}

Write-Output $graph

function Step($graph, $path, $smallcavevisitsAllowed) {
    $currentNode = $path[0]
    $foundPaths = @()

    if($currentNode -eq "end"){
        #Write-Debug "path: $($path -join ",")"
        $foundPaths += ,$path
    }else {
        $options = $graph[$currentNode] | Where-Object { ($smallcavevisitsAllowed -gt 1 -or $path -cnotcontains $_ -or ($_ -cmatch '^[A-Z]+$')) -and -not($_ -cmatch '^start$')} 

        #Write-Debug "path: $($path -join ",")"
        #Write-Debug "options: $($options -join ",")"
        #Write-Debug "smallcavevisitsAllowed: $smallcavevisitsAllowed"

        $options | ForEach-Object {
            $nextPath = @($_)+$path
            $newSmallcavevisitsAllowed = if($path -ccontains $_ -and $_ -cmatch '^[a-z]+$') {1} else {$smallcavevisitsAllowed}
            $paths = Step $graph $nextPath $newSmallcavevisitsAllowed
            #Write-Debug "paths: $(($paths | ForEach-Object { $_ -join "," }) -join " | ")"
            $paths | Where-Object { $null -ne $_ } | ForEach-Object { $foundPaths += ,$_ }
        }
                
    }
    return ,$foundPaths
}

$paths = Step $graph @("start") 2
$paths | ForEach-Object { Write-Output ($_ -join ",")}
Write-Output "paths found: $($paths.Length)"
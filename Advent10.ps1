[CmdletBinding(PositionalBinding = $False)]
param(
    [string]$testFile
)

$codeLines = Get-Content -Path $testFile

$closingmap = @{
    "[" = "]"
    "(" = ")"
    "{" = "}"
    "<" = ">"
}

$scoremap = @{
    "" = 0
    ")" = 3
    "]" = 57
    "}" = 1197
    ">" = 25137
}

$completescoremap = @{
    "" = 0
    ")" = 1
    "]" = 2
    "}" = 3
    ">" = 4
}

function findFirstOffendingCharInLine([string]$line)
{
    $chars = $line.ToCharArray()
    $expectedCharStack = @()
    $offendingChar = ""

    $chars | ForEach-Object {
        if($offendingChar)
        {
            return
        }

        $char = [string]$_
        switch -Regex ($char) {
            "[{\[<\(]" { 
                $expectedCharStack = @($closingmap[$char]) + $expectedCharStack ; 
                break 
            }
            "[}\]>\)]" { 
                $expectedChar, $expectedCharStack = $expectedCharStack
                if($char -ne $expectedChar)
                {
                    #Write-Debug ([string]$expectedChar)
                    $offendingChar = $char
                }
                break 
            }
            Default {}
        }
        #Write-Debug $char        
    }
   # Write-Debug (($expectedCharStack | ForEach-Object { $_ -join "," }) -join " | ")
    return @{ 
        wrongchar = $offendingChar
        missingCharStack = $expectedCharStack
    }
}

$offendingChars = $codeLines | ForEach-Object { findFirstOffendingCharInLine $_ }

Write-Output (($offendingChars | Where-Object { $_.wrongchar -ne "" } | ForEach-Object {$_.wrongchar}) -join " ")
Write-Output ($offendingChars | Where-Object { $_.wrongchar -ne "" } | ForEach-Object { $scoremap[[string]$_.wrongchar] } | Measure-Object -Sum )

Write-Output (($offendingChars | Where-Object { $_.wrongchar -eq "" } | ForEach-Object { $_.missingCharStack -join "" }) -join " | ")

$autocompletescores =($offendingChars | Where-Object { $_.wrongchar -eq "" } | ForEach-Object { 
    $totalscore = 0
    $_.missingCharStack | Where-Object { $completescoremap[[string]$_] -and $completescoremap[[string]$_] -ne 0 } | ForEach-Object { 
        $totalscore *= 5
        $totalscore += $completescoremap[[string]$_] 
        #Write-Debug "$_ $totalscore"
    }
    return $totalscore
} | Sort-Object )


Write-Output $autocompletescores
$middleScore = $autocompletescores[[int]($autocompletescores.Length/2)]
Write-Output "Middlescore = $middleScore"
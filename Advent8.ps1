[CmdletBinding(PositionalBinding = $False)]
param(
    [string]$testFile
)

$inputs = Get-Content -Path $testFile | ForEach-Object { 
    $data = ([string]$_).Split("|") 
    return @{ 
        SignalPattern = $data[0].Trim().Split(" ")
        DigitOut = $data[1].Trim().Split(" ")
    }
}


function AContainsB([char[]] $A, [char[]] $B)
{
    foreach ($item in $B) {
        if(-not ($A -contains $item))
        {
            return $false
        }
    }
    return $true
}


function GenerateDecoder($SignalPattern)
{
    $decoderMap = @{}
    $encoderMap = @{}
    $UnprocessedSignalPatterns235 = @()
    $UnprocessedSignalPatterns069 = @()
    $SignalPattern | ForEach-Object {
        $Signal = $_
        $SignalChars = $Signal.ToCharArray() | Sort-Object
        $Signal = $SignalChars -join ""
        #Write-Debug "$_ $Signal" 
        #Write-Debug ($Signal.Length)
        switch ($Signal.Length) {
            2 { $decoderMap.Add($Signal,1) ; $encoderMap.Add(1,$SignalChars) ;break}
            3 { $decoderMap.Add($Signal,7) ; $encoderMap.Add(7,$SignalChars) ;break}
            4 { $decoderMap.Add($Signal,4) ; $encoderMap.Add(4,$SignalChars) ;break}
            5 { $UnprocessedSignalPatterns235 += $Signal; break} #2,3,5
            6 { $UnprocessedSignalPatterns069 += $Signal; break} #0,6,9
            7 { $decoderMap.Add($Signal,8) ; $encoderMap.Add(8,$SignalChars) ;break}
            Default {}
        }
    }
    $UnprocessedSignalPatterns069 | ForEach-Object {
        $Signal = $_
        $SignalChars = $Signal.ToCharArray() | Sort-Object
        $Signal = $SignalChars -join ""

        if(AContainsB $SignalChars $encoderMap[4])
        {
            $decoderMap.Add($Signal,9)
            $encoderMap.Add(9,$SignalChars)
        } elseif(AContainsB $SignalChars $encoderMap[7])
        {
            $decoderMap.Add($Signal,0)
            $encoderMap.Add(0,$SignalChars)
        } else {
            $decoderMap.Add($Signal,6)
            $encoderMap.Add(6,$SignalChars)
        }
    }

    #Write-Debug ($UnprocessedSignalPatterns235 -join ",")
    $UnprocessedSignalPatterns235 | ForEach-Object {
        $Signal = $_
        $SignalChars = $Signal.ToCharArray() | Sort-Object
        $Signal = $SignalChars -join ""

        if(AContainsB $encoderMap[6] $Signal)
        {
            $decoderMap.Add($Signal,5)
            $encoderMap.Add(5,$SignalChars)
        } elseif(AContainsB $encoderMap[9] $Signal)
        {
            $decoderMap.Add($Signal,3)
            $encoderMap.Add(3,$SignalChars)
        } else {
            $decoderMap.Add($Signal,2)
            $encoderMap.Add(2,$SignalChars)
        }
    }

    return $decoderMap
}

function Decode($Decoder, $DisplayOutPut)
{
    return $DisplayOutPut | ForEach-Object { ($_.ToCharArray() | Sort-Object)-join "" }  | Where-Object { $Decoder.ContainsKey($_) } | ForEach-Object { $Decoder[$_] } 
}

$inputs | ForEach-Object{ 
    Write-Output (GenerateDecoder $_.SignalPattern) 
    Write-Output ""
}

$decodedOut = $inputs | ForEach-Object{ (Decode (GenerateDecoder $_.SignalPattern) $_.DigitOut) -join "" }
$sum = $decodedOut | ForEach-Object {[int]::Parse($_)} | Measure-Object -Sum 

Write-Output $inputs
Write-Output ($decodedOut -join ",")
Write-Output $sum
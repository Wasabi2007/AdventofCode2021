[CmdletBinding(PositionalBinding = $False)]
param(
    [string]$testFile
)

$inputs = Get-Content -Path $testFile

$bingoNumbers = @()

[int[][][]]$bingoFields = @()

[int[][]]$bingoField = @()

$readMode = "bingoNumbers"

$inputs | ForEach-Object{
    $inputline = ([string]$_).Trim();
    if($inputline.Length -eq 0)
    {
        $readMode = "field"
        if($bingoField)
        {
            $bingoFields += ,$bingoField.Clone()
        }
        $bingoField = @()
        return
    }

    switch ($readMode) {
        "bingoNumbers" {  
            $bingoNumbers += $inputline.Split(",") | ForEach-Object { [int]::Parse($_) }
        }
        "field" {
            $sanitizedInput = $inputline -replace "\s+",","
            $bingoField += ,(($sanitizedInput).Split(",") | ForEach-Object { [int]::Parse($_) })
        }
        Default {}
    }
}

if($bingoField)
{
    $bingoFields += ,$bingoField.Clone()
}

Write-Output ($bingoNumbers -join ",")
Write-Output ""

$resultSet = @()
$boardIndex = 0
$bingoFields | ForEach-Object {
    ($_ | ForEach-Object{ $_ -join ","}) | ForEach-Object { Write-Output $_ }
    $field = $_
    $marked = New-Object 'bool[,]' $field.Length,$field[0].Length
    $round = 0
    $hasWon = $false
    $bingoNumbers | ForEach-Object{
        if($hasWon){return}

        $currentNumber = $_
        
        $rowHitCount = New-Object 'int[]' $field.Length
        $collumHitCount = New-Object 'int[]' $field.Length

        $unmarkedNumbersSum = 0

        for($rowIndex = 0; $rowIndex -lt $field.Length; $rowIndex++){
            $row = $field[$rowIndex]
            for($collumIndex = 0; $collumIndex -lt $row.Length; $collumIndex++){
                if($row[$collumIndex] -eq $currentNumber){
                    $marked[$rowIndex,$collumIndex] = $true
                }
                if($marked[$rowIndex,$collumIndex])
                {
                    $rowHitCount[$rowIndex]++;
                    $collumHitCount[$collumIndex]++;
                }
                else {
                    $unmarkedNumbersSum+=$row[$collumIndex];
                }
            }
        }
        $round++
        $hasWon = $rowHitCount.Contains($field.Length) -or $collumHitCount.Contains($field.Length)
        if($hasWon){
            $resultSet += @{
                Round = $round
                WinningNumber = $currentNumber
                UnmarkedNumbersSum = $unmarkedNumbersSum
                BoardIndex = $boardIndex
            }            
        }
    }
    $boardIndex++;
    Write-Output ""
}
$resultSet | ForEach-Object { 
    Write-Output $_
    Write-Output ""
}

$finalResult = $null;
$resultSet | ForEach-Object { 
    if(-not $finalResult -or ($_.round -lt $finalResult.Round)) {
        $finalResult = $_
    }
}

Write-Output "Part 1 winning board"
Write-Output $finalResult
Write-Output ($finalResult.UnmarkedNumbersSum * $finalResult.WinningNumber)

$finalResult = $null;
$resultSet | ForEach-Object { 
    if(-not $finalResult -or ($_.round -gt $finalResult.Round)) {
        $finalResult = $_
    }
}

Write-Output "Part 2 last winning board"
Write-Output $finalResult
Write-Output ($finalResult.UnmarkedNumbersSum * $finalResult.WinningNumber)
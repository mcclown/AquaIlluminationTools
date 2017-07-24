param(
    [Parameter(Mandatory=$true)]
    [String]$inputAIPFile
    )

function Get-Checksum()
{
    param([String]$checkStr = $null)

    $x= 0

    for($i = 0; $i -lt $checkStr.Length; $i++)
    {
        $charCode = [int][char]$checkStr[$i]
        $x = (($x -shl 5) - $x ) + $charCode

        $x = ($x -band 4294967295)

        #Not pretty, the original algorithm assumes 32-bit ints, so this is a workaround, to handle that
        $x = ($x -shl 32) -shr 32
    } 

    return [Math]::Abs($x) 
}

[xml]$xml = Get-Content -Path $inputAIPFile
$colorsStr = [string]$xml.ramp.colors.OuterXml

Get-Checksum $colorsStr

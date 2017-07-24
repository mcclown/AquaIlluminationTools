param(
    [Parameter(Mandatory=$true, Position=1)]
    [String]$inFile,
    [Parameter(Position=2)]
    [String]$outFile = $null,
    [switch]$calculateChecksum,
    [switch]$updateChecksum
    )

function Format-XML
{ 
    param([xml]$xml, $indentChar="`t", $indent=1) 
    
    $StringWriter = New-Object System.IO.StringWriter 
    $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter 
    $xmlWriter.Formatting = “indented” 
    $xmlWriter.Indentation = $indent 
    $xmlWriter.IndentChar = $indentChar
    $xml.WriteContentTo($XmlWriter) 
    $XmlWriter.Flush() 
    $StringWriter.Flush() 
    
    return $StringWriter.ToString() 
}

function Get-Checksum
{
    param([xml]$xml)

    $checkstr = [string]$xml.ramp.colors.OuterXml
    
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

function Modify-Checksum
{
    param([xml]$xml)

    $checksum = Get-Checksum($xml)
    $xml.ramp.header.checksum = ""+$checksum
    return $xml
}

<#
    AIP File Processing
#>

[xml]$xml = Get-Content -Path (Resolve-Path $inFile)

if( $calculateChecksum )
{
    Write-Output (Get-Checksum($xml))
}

if( $updateChecksum )
{
    $outXML = Modify-Checksum($xml)
    Format-XML($outXML) | Out-File -FilePath $outFile
}

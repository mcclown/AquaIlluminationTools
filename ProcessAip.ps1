param(
    [Parameter(Mandatory=$true)]
    [String]$inputAIPFile
    )

function Create-ScriptEngine()
{
  param([string]$language = $null, [string]$code = $null);
  if ( $language )
  {
    $sc = New-Object -ComObject ScriptControl;
    $sc.Language = $language;
    if ( $code )
    {
      $sc.AddCode($code);
    }
    $sc.CodeObject;
  }
}

$jsCode = 
@"
function getChecksum(l) {
        var k = 0;
        if (l.length == 0) {
            return k
        }
        for (var j = 0; j < l.length; j++) {
            var h = l.charCodeAt(j);
            k = ((k << 5) - k) + h;
            k = k & 4294967295
        }
        if (k < 0) {
            k = ~k
        }
        return k
    };
"@

$js = Create-ScriptEngine "JScript" $jsCode

[xml]$xml = Get-Content -Path $inputAIPFile
$colorsStr = [string]$xml.ramp.colors.OuterXml

$js.getChecksum($colorsStr)
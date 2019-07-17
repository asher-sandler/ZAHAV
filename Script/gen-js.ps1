Param(
[Parameter(Mandatory=$TRUE,Position=1)]
[string]$FormName
)

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
 
. "..\..\Script\Utils.ps1"
. "$dp0\JS1.ps1"

write-host $FormName

$form = Open-Form($FormName)

$formo = Get-Formjs($form)
<#
write-host Params:
foreach ($param in $formo.Params)
{
write-host $param
}


write-host FormGroup:
foreach($lbl in $formo.FormGroup)
{
	 write-host ($lbl[0]+","+$lbl[1]) 
}

write-host Name:

write-host $formo.Name
write-host $formo.FormName

#>

# write-host $formo.Name
# write-host $formo.FormName


$scriptName=get-JSName $formo.Name $formo.FormName
$js = create-jsGen($formo)

$test = create-jsGen($formo)

$outdir = "webroot\js\"

if (!(Test-Path -Path $outdir))
{
	New-Item -ItemType Directory  -Force -Path $outdir
}
		

$fileName = $($outdir+$scriptName)
# write-host $test
# write-host $scriptName
$js | out-file  -filepath $fileName -encoding UTF8 -Force
# $test | out-file  -filepath $("..\Gen\webroot\js\test.js") -encoding UTF8 -Force

$fl = get-item $fileName



write-host $("js script was generated: ") 
write-host $fl.FullName -ForeGround GREEN

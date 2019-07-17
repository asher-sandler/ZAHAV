Param(
[Parameter(Mandatory=$TRUE)]
[string]$Action,


[Parameter(Mandatory=$TRUE)]
[string]$FormName
)

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
 
. "..\..\Script\Utils.ps1"
. "$dp0\tabbedform.ps1"

$form = Open-TabbedForm($FormName)

if ($form.Trim().Length -gt 0)
{

	$formo = get-TabbedFormObj($form)
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

	# write-host Name:

	# write-host $formo.Name
	# write-host $formo.FormName

	#>

	# write-host $formo.Name
	# write-host $formo.FormName


	<#
	write-host ***************************
	foreach($tab in $formo.tabs)
	{

		write-host $('------------>'+ $tab.Name)
		#$tab | gm
		foreach($field in $tab.Fields)
		{
			write-host $field.Label
			write-host $field.Name
			write-host $field.IsReq
			
		}
	}

	#>
	$html = create-tabbedHTML-From-Template $Action $formo 

	$tabbedDir = "tabbed\"+$FormName.Split(".")[0]+"\"

	if (!(Test-Path -Path $tabbedDir))
	{
		New-Item -ItemType Directory  -Force -Path $tabbedDir
	}

	$fileName = $($tabbedDir+$( $Action.toLower() +".html"))
	# write-host $test
	# write-host $scriptName
	$html | out-file  -filepath $fileName -encoding UTF8 -Force
	# $test | out-file  -filepath $("..\Gen\webroot\js\test.js") -encoding UTF8 -Force

	$fl = get-item $fileName



	write-host $("html script was generated: ") 
	write-host $fl.FullName -ForeGround Green
}

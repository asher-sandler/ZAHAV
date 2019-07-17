<#

.SYNOPSIS

SYNOPSIS
THIS SCRIPT GENARATE This script generate SQL, Model, View, Controller for MVC project
FOR SPECIFIC DICTIONARY.

.DESCRIPTION


DESCRIPTION
Dictionary is a text file in Dictionary catalog


.PARAMETER 

DictionaryName IS A NAME OF DICTIONARY FILE

.NOTES

NOTES

.EXAMPLE

.\main.ps1 pbk.dict


.LINK

http://mysite.site

#>

Param(
[Parameter(Mandatory=$FALSE,Position=1)]
[string]$DictionaryName = ""
)

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
  
. "$dp0\Utils.ps1"

$crlf = [char][int]13+[char][int]10
if ([String]::IsNullOrEmpty($DictionaryName)){
	
	write-host
	write-host "This script generate " -nonewline
	write-host "SQL, Model, View, Controller and Form Template"  -foreground yellow 
	write-host "for MVC project for specific dictionary."
	write-host  

	write-host "Dictionary is a text file in Dictionary catalog"
	write-host "Usage : .\main.ps1 - DictionaryName <dictname>" -foreground yellow
	write-host "i.e .\main.ps1 - DictionaryName pbk.dict" -foreground yellow
	

}
else
{
	
	
	
	
	
	$global:wpath = "..\";
	
				 
	write-host $("Reading dictionary              : ") -nonewline 
	write-host $DictionaryName -foreground yellow
	write-host 

	$dict = get-dictionary($DictionaryName )
	#$dict | fl
	#read-host
	
	if (dbccCheck($dict))
	{
	
	
	$dbp = dbPassportNew($dict)
	
	
	dbDictSave $dict
		
		
	dbPassportSaveObj  $dbp ""
		
	if (CheckConstraint($dbp))
	{
	

		#read-host
		
		$sql = get-sql $dict 
		write-host 			 
		write-host "Writing SQL                     :" -nonewline
		write-host $("..\gen\"+$dict.Name+".sql") -foreground yellow
		write-host 
		
		$sql | out-file  -filepath $("..\gen\"+$dict.Name+".sql") -encoding UTF8
		
		
		$noret=  get-formsFromPassport $dict.Name
		
		$noret=  get-gridFromPassport  $dict.Name
		
		$dbp = dbPassportReadObj $dict.Name
		$gendir = "..\gen\"+$dict.Name+"\"
		
		$renderPS = ""
		
		$renderDir = $gendir+"render\"
			
		if (!(Test-Path -Path $renderDir))
		{
			New-Item -ItemType Directory  -Force -Path $renderDir
		}
		
		
		
		foreach($table in $dbp.Tables)
		{


			
			# MODEL 



			$modelname = $renderDir+$table.TableName+"-model.ps1"
			$modelTmpl = Open-Template("model")
			$model = Render-Template($modelTmpl)
			$renderPS+=	'.\gen-render.ps1 -class "model" -moduleFileName '+'"'+$modelname +'" -Object "PassportTable" -Dictionary "' +$dbp.Name+'"'+ $crlf	
			$model | out-file  -filepath $modelname -encoding UTF8	
			write-host "Render model.ps1        :" -nonewline
			write-host $modelname -foreground yellow

			
			
			$pdoname = $renderDir+$table.TableName+"-pdo.ps1"
			$pdoTmpl = Open-Template("pdoClass")
			$pdo = Render-Template($pdoTmpl)
			$renderPS+=	'.\gen-render.ps1 -class "pdo" -moduleFileName '+'"'+$pdoname +'" -Object "PassportTable" -Dictionary "' +$dbp.Name+'"'+ $crlf	
			$pdo | out-file  -filepath $pdoname -encoding UTF8	
			write-host "Render pdo.ps1        :" -nonewline
			write-host $pdoname -foreground yellow
			
			
			$controllername = $renderDir+$table.TableName+"-controller.ps1"
			$controllerTmpl = Open-Template("controller")
			$controller = Render-Template($controllerTmpl)
			$renderPS+=	'.\gen-render.ps1 -class "controller" -moduleFileName '+'"'+$controllername +'" -Object "PassportTable" -Dictionary "' +$dbp.Name+'"'+ $crlf	
			$controller | out-file  -filepath $controllername -encoding UTF8	
			write-host "Render controller.ps1        :" -nonewline
			write-host $controllername -foreground yellow
			
			
			
			$indexname = $renderDir+$table.TableName+"-index.ps1"
			#$indexname
			$indexTmpl = Open-Template("index")
			$index = Render-Template($indexTmpl)
			$renderPS+=	'.\gen-render.ps1 -class "index" -moduleFileName '+'"'+$indexname +'" -Object "GRID" -Dictionary "' +$dbp.Name+'"'+ $crlf	
			$index | out-file  -filepath $indexname -encoding UTF8	
			write-host "Render index.html        :" -nonewline
			write-host $indexname -foreground yellow		


			$updatename = $renderDir+$table.TableName+"-update.ps1"
			#$updatename
			$updateTmpl = Open-Template("update")
			$update = Render-Template($updateTmpl)
			$renderPS+=	'.\gen-render.ps1 -class "index" -moduleFileName '+'"'+$updatename +'" -Object "GRID" -Dictionary "' +$dbp.Name+'"'+ $crlf	
			$update | out-file  -filepath $updatename -encoding UTF8	
			write-host "Render update.html        :" -nonewline
			write-host $updatename -foreground yellow		



			$confirmdelname = $renderDir+$table.TableName+"-confirmdel.ps1"
			#$confirmdelname
			$confirmdelTmpl = Open-Template("confirmdel")
			$confirmdel = Render-Template($confirmdelTmpl)
			$renderPS+=	'.\gen-render.ps1 -class "index" -moduleFileName '+'"'+$confirmdelname +'" -Object "GRID" -Dictionary "' +$dbp.Name+'"'+ $crlf	
			$confirmdel | out-file  -filepath $confirmdelname -encoding UTF8	
			write-host "Render confirmdel.html        :" -nonewline
			write-host $confirmdelname -foreground yellow		
		

			$deletename = $renderDir+$table.TableName+"-delete.ps1"
			#$deletename
			$deleteTmpl = Open-Template("delete")
			$delete = Render-Template($deleteTmpl)
			$renderPS+=	'.\gen-render.ps1 -class "html" -moduleFileName '+'"'+$deletename +'" -Object "PassportTable" -Dictionary "' +$dbp.Name+'"'+ $crlf	
			$delete | out-file  -filepath $deletename -encoding UTF8	
			write-host "Render delete.html        :" -nonewline
			write-host $deletename -foreground yellow		
		
				
					
			

			$frmctx = Open-Form $dict.Name $table.TableName
			if (![String]::IsNullOrEmpty($frmctx))
			{
				
				$frmObj = get-TabbedFormObj $frmctx  $dict.Name
				
				$psADDname = $renderDir+$table.TableName+"-add.ps1"
				$addTmpl = Open-Template("tabbedform")
				$add = Render-Template($addTmpl)
				$renderPS+=	'.\gen-render.ps1 -class "form" -moduleFileName '+'"'+$psADDname +'" -Object "'+$table.TableName+'" -Dictionary "' +$dbp.Name+'"'+ $crlf	
				$add | out-file  -filepath $psADDname -encoding UTF8	
				write-host "Render add.html        :" -nonewline
				write-host $psADDname -foreground yellow		

				
				

				$psSHOWname = $renderDir+$table.TableName+"-show.ps1"
				$SHOWTmpl = Open-Template("tabbedform")
				$show = Render-Template($SHOWTmpl)
				$renderPS+=	'.\gen-render.ps1 -class "form" -moduleFileName '+'"'+$psSHOWname +'" -Object "'+$table.TableName+'" -Dictionary "' +$dbp.Name+'"'+ $crlf	
				$show | out-file  -filepath $psSHOWname -encoding UTF8	
				write-host "Render show.html        :" -nonewline
				write-host $psSHOWname -foreground yellow		
					

				$pseditname = $renderDir+$table.TableName+"-edit.ps1"
				$editTmpl = Open-Template("tabbedform")
				$edit = Render-Template($editTmpl)
				$renderPS+=	'.\gen-render.ps1 -class "form" -moduleFileName '+'"'+$pseditname +'" -Object "'+$table.TableName+'" -Dictionary "' +$dbp.Name+'"'+ $crlf	
				$edit | out-file  -filepath $pseditname -encoding UTF8	
				write-host "Render edit.html        :" -nonewline
				write-host $pseditname -foreground yellow		
				

				# for shapiro (simcha) framework	
				$pseditname = $renderDir+$table.TableName+"-edit-shpr.ps1"
				$editTmpl = Open-Template("tabbedform-shpr")
				$edit = Render-Template($editTmpl)
				$renderPS+=	'.\gen-render.ps1 -class "shapr" -moduleFileName '+'"'+$pseditname +'" -Object "'+$table.TableName+'" -Dictionary "' +$dbp.Name+'"'+ $crlf	
				$edit | out-file  -filepath $pseditname -encoding UTF8	
				write-host "Render edit-shpr.html        :" -nonewline
				write-host $pseditname -foreground yellow		
									
				
			}

			
		}
		
		$psmenuname = $renderDir+"menu-menu.ps1"
		$menuTmpl = Open-Template("menu")
		$menu = Render-Template($menuTmpl)
		$renderPS+=	'.\gen-render.ps1 -class "menu" -moduleFileName '+'"'+$psmenuname +'" -Object "PassportTable" -Dictionary "' +$dbp.Name+'"'+ $crlf	
		$menu  | out-file  -filepath $psmenuname -encoding UTF8	
		write-host "Render menu.html        :" -nonewline
		write-host $psmenuname -foreground yellow		
		
		
		$psCMDFileName  = $dp0+"\" + $dict.Name+"-N.ps1"
		$renderPS | out-file  -filepath $psCMDFileName  -encoding UTF8
		write-host $("Now run PS File: "+$psCMDFileName ) -foreground yellow



		#$tfrmctx= Open-TabbedForm "anketa-A001.wnf"	
		#$frm=get-TabbedFormObj $tfrmctx $dict.Name
		# read-host
		
		
		
		#$dict |ConvertTo-Json -Depth 100 | out-file $("..\Gen\PARENT-CHILD\dbPassport\dict.json")
		
		
		# foreach($table in $dict.Tables)
		# {
			
			# <#
			# foreach($fff in $table.FieldOrder)
			# {
				# write-host $fff
			# }
			# read-host
			# #>
			
			# $gendir = "..\gen\"+$dict.Name+"\"
			# write-host $gendir
			# write-host "In dictionary processing table  :" -nonewline
			# write-host $table.NAME -foreground yellow
			
			# $contr = get-controller($table)
			# $model =get-model($table)
			# $view  = get-view($table)
			# $datasaved = get-datasaved($table)
			# $dataSavedHTMLName = "datasaved.html"
			# $askForDel = get-AskForDelete($table)
			# $askForDelHTMLName = "ask_for_delete.html"
			# $deleteHTML = get-deleteHTML($table)
			# $deleteHTMLFileName = "delete.html"
			# $modelname = $table.Name.tolower()+".php"
			# $viewname  = "index.html"
			# $dirview = $gendir+"views\"+$table.Name.tolower()+"\"
			# # write-host $dirview
			# if (!(Test-Path -Path $dirview))
			# {
				# New-Item -ItemType Directory  -Force -Path $dirview
			# }
			# $controllename = $table.Name.tolower()+".controller.php"
			# $form = get-form $dict.Name $table $dirview $viewname 
			# $formname = $gendir+'forms\'+$table.Name+"-"+$table.FormName+".wnf"
			# # write-host $formname
			# $formBakDir = $gendir+"forms\bak\"
			# if (!(Test-Path -Path $formBakDir))
			# {
				# New-Item -ItemType Directory  -Force -Path $formBakDir
			# }
			# if (Test-Path -Path ($formname))
			# {
				 # $dateMask = $(Get-Date).Year.ToString()+"-"+$(Get-Date).Month.ToString("00")+"-"+$(Get-Date).day.ToString("00")+"-"+$(Get-Date).Hour.ToString("00")+$(Get-Date).Minute.ToString("00")
				 # #write-host $formBakDir
				 # #write-host
				 # $dest= $formBakDir+ $table.Name+"-"+$table.FormName+"-"+$dateMask+".wnf"
				 # copy-Item -Path $formname -Destination $dest
				 
			# }
			
			# write-host "Writing FORM                    :" -nonewline
			# write-host $formname -foreground yellow
		
			
			# $form  | out-file  -filepath $formname -encoding Unicode -Force	
					   
			# write-host "Writing MODEL                   :" -nonewline
			# write-host $($gendir+"models\"+$modelname) -foreground yellow
		
			# if (!(Test-Path -Path $($gendir+"models\")))
			# {
				# New-Item -ItemType Directory  -Force -Path $($gendir+"models\")
			# }
			
			
			# if (!(Test-Path -Path $($gendir+"controllers\")))
			# {
				# New-Item -ItemType Directory  -Force -Path $($gendir+"controllers\")
			# }
			
			# $model | out-file  -filepath $($gendir+"models\"+$modelname) -encoding UTF8	
					  
			# write-host "Writing CONTROLLER              :" -nonewline
			# write-host $($gendir+"controllers\"+$controllename) -foreground yellow

			
			
			# $contr | out-file  -filepath $($gendir+"controllers\"+$controllename) -encoding UTF8	
					  
			# write-host "Writing VIEW                    :" -nonewline
			# write-host $($dirview+$viewname) -foreground yellow
			# $view  | out-file  -filepath $($dirview+$viewname) -encoding UTF8	


			# write-host "Writing ask_for_delete.html     :" -nonewline
			# write-host $($dirview+$askForDelHTMLName) -foreground yellow
			# $askForDel | out-file  -filepath $($dirview+$askForDelHTMLName) -encoding UTF8	

			# write-host "Writing delete.html             :" -nonewline
			# write-host $($dirview+$deleteHTMLFileName) -foreground yellow
			# $deleteHTML | out-file  -filepath $($dirview+$deleteHTMLFileName) -encoding UTF8	

			# write-host "Writing DataSaved               :" -nonewline
			# write-host $($dirview+$dataSavedHTMLName) -foreground yellow
			# $datasaved	| out-file  -filepath $($dirview+$dataSavedHTMLName) -encoding UTF8	
		# }

		
		# write-host "Now run " -nonewline
		# write-host ".\PS-gen.ps1 -TemplateName " -nonewline -ForeGround Yellow
		# write-host "to generate powershell script"
		# write-host "for generate js for specific form."
		# write-host "Template is in ..\Template directory"
		# write-host
		# write-host $('Or if you have got this script run ') -nonewline
		# write-host '".\Gen-Js.ps1 -FormName <FormName>"' -nonewline -ForeGround Yellow
		# write-host ("to generate js script for this form" ) 
		
		
		# $psCMDFileName  = $dp0+"\" + $dict.Name+".ps1"
		# write-host
		# write-host $("Now run PS File: "+$psCMDFileName ) -foreground yellow

		
		# $pscmdstr  = "# "+$crlf
		# $pscmdstr += "# .\main.ps1 -DictionaryName " + $dict.Name+".dict"+$crlf+$crlf
		# $pscmdstr += ".\PS-gen.ps1 -DictName " +$dict.Name +" -TemplateName JS1"+$crlf
		# $pscmdstr += ".\PS-gen.ps1 -DictName " +$dict.Name +" -TemplateName tabbedform"+$crlf
		# $pscmdstr += $crlf+"cd ..\Gen\" + $dict.Name +"\"+$crlf+$crlf+$crlf
		# foreach($table in $dict.Tables){
			# $formname = $table.Name+"-"+$table.FormName+".wnf"
			# $pscmdstr += ".\gen-js.ps1 -FormName " + $formname+$crlf
		# }
		# $psCRET = $crlf+"# CRET - create, read, edit form Tabbed"
		# $pscmdstr += $crlf+$crlf
		# $psCRET  += $crlf+$crlf
		
		

		# $psCRET  += "# only if we have tabbed forms in directory ui\tabbedforms"+$crlf+$crlf
		# foreach($table in $dict.Tables){
			# $formname = $table.Name+"-"+$table.FormName+".wnf"
			
			# $psCRET  +=  ".\gen-tabbed.ps1 -Action ADD -FormName " + $formname+$crlf
			# $psCRET  +=  ".\gen-tabbed.ps1 -Action SHOW -FormName " + $formname+$crlf
			# $psCRET  +=  ".\gen-tabbed.ps1 -Action EDIT -FormName " + $formname+$crlf+$crlf
			
			# #$pscmdstr += ".\gen-tabbed.ps1 -Action ADD -FormName " + $formname+$crlf
			# #$pscmdstr += ".\gen-tabbed.ps1 -Action EDIT -FormName " + $formname+$crlf
			# #$pscmdstr += ".\gen-tabbed.ps1 -Action SHOW -FormName " + $formname+$crlf+$crlf
		# }
		
		# $pscmdstr += $crlf+$psCRET +"cd ..\..\script"+$crlf

		# $psCRETFileName  = $dp0+"\..\Gen\"+$dict.Name+"\cret.ps1"
		# write-host $psCRETFileName
		
		# $pscmdstr | out-file  -filepath $psCMDFileName  -encoding UTF8
		# $psCRET | out-file  -filepath $psCRETFileName  -encoding UTF8
		}
	else
		{
			write-host "Correct errors!" -foreground yellow
			
		}
	}
	else
	{
		write-host "Correct errors!" -foreground yellow
	}
	
}
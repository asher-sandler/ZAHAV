
Param(

[Parameter(Mandatory=$TRUE)]
[string]$class,

[Parameter(Mandatory=$TRUE)]
[string]$moduleFileName,

[Parameter(Mandatory=$TRUE)]
[string]$Object,


[Parameter(Mandatory=$TRUE)]
[string]$Dictionary

)

$module = $moduleFileName.Split("\")[$moduleFileName.Split("\").count-1]



$tableName = $module.Split("-")[0]
$htmlname  = $module.Split("-")[1].Split(".")[0]


#$tableName

$0 = $myInvocation.MyCommand.Definition
$dp0 = [System.IO.Path]::GetDirectoryName($0)
 
$gendir = "..\gen\"+$Dictionary+"\" 

. ".\Utils.ps1"
. "$moduleFileName"

if ($Object.toLower() -eq "passporttable")
{
	
    $obj = dbPassportReadObj($Dictionary)
	#write-host $obj.Name
	#write-host $obj.Tables[0].DisplayName
	
	
	$renderstr = ""
	if ($class -eq "menu")
	{
		$renderstr = render-module $obj
	
	}
	else
	{
		foreach($table in $obj.Tables)
		{
			if ($table.TableName -eq $tableName)
			{
				$renderstr = render-module $table
				
				break
			}
		}
	}
	if ($class -eq "html")
	{
		$renderDir = $($gendir+"views\"+$tableName+"\")	
		$renderFileName = $($renderDir+$htmlname +".html")	
	}
	elseif ($class -eq "controller")
	{
		$renderDir = $($gendir+$class+"s\")
			

		$renderFileName = $($renderDir+$tableName +".controller.php")		
	}
	elseif ($class -eq "pdo")
	{
		$renderDir = $($gendir+$class+"\")
			

		$renderFileName = $($renderDir+$tableName +".php")		
	}	
	elseif ($class -eq "menu")
	{
		$renderDir =  $($gendir+"config\")
		$renderFileName = $($renderDir+"menu.php")
	}
	else
	{
		$renderDir = $($gendir+$class+"s\")
			

		$renderFileName = $($renderDir+$tableName +".php")
	}
	
	if (!(Test-Path -Path $renderDir))
	{
		New-Item -ItemType Directory  -Force -Path $renderDir
	}
	
	SaveUTF8 $renderstr $renderFileName
	
	
	write-host $("Written "+$class.ToUpper() + ":") -nonewline
	write-host $renderFileName -foreground yellow

	
}
else
{
	if ($class -eq "form")	
	{
	    
		$frmctx = Open-Form $Dictionary $Object.toLower()
		if (![String]::IsNullOrEmpty($frmctx))
		{
			
			
			$renderDir = $($gendir+"views\"+$Object.toLower()+"\")	
			$renderFileName = $($renderDir+$htmlname +".html")				
			
			#write-host $renderDir
			#write-host $renderFileName
			#write-host $frmObj.FormName
			
			$action = $htmlname


			$renderstr = create-tab $action $Dictionary $object
			if (!(Test-Path -Path $renderDir))
			{
				New-Item -ItemType Directory  -Force -Path $renderDir
			}
			
			SaveUTF8 $renderstr $renderFileName
			
			
			write-host $("Written "+$action + ":") -nonewline
			write-host $renderFileName -foreground yellow
					
			
		
		}
	}
	elseif ($class.toLower() -eq "index")
	{
		$renderDir = $($gendir+"views\"+$tableName+"\")	
		$renderFileName = $($renderDir+$htmlname +".html")	
		
		# write-host $Dictionary
		# write-host $tableName
		$renderstr = render-module $Dictionary $tableName

		if (!(Test-Path -Path $renderDir))
		{
			New-Item -ItemType Directory  -Force -Path $renderDir
		}
	
		SaveUTF8 $renderstr $renderFileName
	
	
	write-host $("Written "+$class.ToUpper() + ":") -nonewline
	write-host $renderFileName -foreground yellow

		
		# write-host $renderDir
		# write-host $renderFileName
		# read-host
	
	}
	elseif ($class -eq "shapr")	
	{
	    
		$frmctx = Open-Form $Dictionary $Object.toLower()
		if (![String]::IsNullOrEmpty($frmctx))
		{
			
			#write-host $htmlname
			#read-host
			$renderDir = $($gendir+"shapr\"+$Object.toLower()+"\")	
			$renderFileName = $($renderDir+$htmlname +".php")				
			
			#write-host $renderDir
			#write-host $renderFileName
			#write-host $frmObj.FormName
			
			$action = $htmlname


			$renderstr = create-tab $action $Dictionary $object
			if (!(Test-Path -Path $renderDir))
			{
				New-Item -ItemType Directory  -Force -Path $renderDir
			}
			
			SaveUTF8 $renderstr $renderFileName
			
			
			write-host $("Written "+$action + ":") -nonewline
			write-host $renderFileName -foreground yellow
					
			
		
		}
	}
	
}

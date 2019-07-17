function dbPassportTableNew($table)
{
	

	$dbpTable = "" | Select TableName,DisplayName, View,ViewName, Fields,Constraints,FormName,FormType;
	$dbpTable.TableName=$table.Name;
	$dbpTable.DisplayName = $table.DisplayName;
	$dbpTable.Fields = @();
	$dbpTable.Constraints = @();
	$dbpTable.FormName =  "";
	$dbpTable.Formtype = "";
	
	return $dbpTable;
	
}
function dbPassportFieldNew($field,$isConstr )
{
    $dbpfield = "" | select Name,Type,Lenght,DisplayName,isConstraint,Constraint
	
	$dbpfield.Name = $field.Name;
	$dbpfield.Type = $field.Type;
	$dbpfield.Lenght = $field.Lenght;
	$dbpfield.isConstraint = $isConstr;
	$dbpfield.DisplayName = $field.DisplayName;
	$dbpfield.Constraint = dbPassportConstraintFieldNew
	
	
	
	return $dbpfield;
}
function dbPassportConstraintNew($fkName)
{
    $fk="" | Select Table
	$fk.Table = $fkName
	return $fk
}
function dbPassportConstraintFieldNew()
{
	$Constraint ="" | Select ParentTable,ParentField,View,ViewField,ViewName,SProcName
	
	$Constraint.ParentTable= ""
	$Constraint.ParentField=""
	$Constraint.View =""
	$Constraint.ViewField=""
	$Constraint.ViewName=""
	$Constraint.SProcName=""
	
	return $Constraint
	
}
function dbPassportNew($dict)
{
	# $dict = "" | select Name, Tables  
	# $table = "" | select Name,Fields,DisplayName,FormName,FKeys,FieldOrder
	# $field = "" | select Name,Type,Lenght,DisplayName,Key
	# $foreignkey = "" | Select Table
	
	
	$dbPassport = "" | select Name, Tables  ;
	$dbPassport.Name = $dict.Name;
	$dbPassport.Tables = @();
	

	
	foreach($table in $dict.Tables)
	{
		$dpTable = dbPassportTableNew($table);
		
		
		foreach($field in $table.Fields)
		{
		    $dbpField = dbPassportFieldNew $field $false;
			$dpTable.Fields +=	$dbpField;
		}
		
		foreach($fk in $table.FKeys)
		{
		    #write-host "FK:"
	    	#	write-host $fk.Table
			#read-host
		    #if (![string]::IsNullOrEmpty($table.foreignkey.Table)){
			$dbpfield = "" | select Name,Type,Lenght,DisplayName,isConstraint,Constraint
	
			$dbpField.Name = $fk.Table+"_id"
			$dbpfield.isConstraint = $true
			$dbpfield.Constraint = dbPassportConstraintFieldNew
			
			$dbpField.Constraint.ParentTable= $fk.Table
			$dbpField.Constraint.ParentField="id"
			
			
			# $dbpField.Constraint.View =
			
			$dbpField.Constraint.ViewField=get-viewFieldName $fk.Table
			$dbpField.Constraint.ViewName=$table.Name+ "_"+ $fk.Table+"_index"
			
			#$dbpField.$Constraint.SProcName=
			
			$dpTable.Fields +=	$dbpField;
			
			#}
		}
		
		
		$dbPassport.Tables += $dpTable;
	    
	}
	
	
	
	return $dbPassport;


}
function dbPassportSaveObj($dbPassport,$name="")
{
    
	$objxmlFileName =  "..\gen\"+$dbPassport.Name+"\dbPassport\"
	

	if (!(Test-Path -Path $objxmlFileName))
	{
		New-Item -ItemType Directory  -Force -Path $objxmlFileName
	}
    if ($name -eq ""){
		$objxmlFileName+="dbPassport"
	}
	else
	{
		$objxmlFileName+=$name
	}
			

	$dbPassport | Export-CliXML $($objxmlFileName+".xml")

	$dbPassport |ConvertTo-Json -Depth 100 | out-file $($objxmlFileName+".json")
}



function dbPassportReadObj($name)
{
	$objxmlFileName ="..\gen\"+$Name+"\dbPassport\dbPassport.json"

	
	if (!(Test-Path -Path $objxmlFileName))
	{
		return $false
	}
	
	$content = Get-Content -raw $objxmlFileName
	$oDbp=$content | ConvertFrom-Json

	return $oDbp
    
}
function dbPassportSelectSet($dicName,$dbptableName,$select)
{
	  $i=0;	
	  
	 
	  
	  $oDbp = dbPassportReadObj $dicName 
	  
	 
      foreach($table in $oDbp.Tables)
	  {
		if ($table.TableName -eq $dbptableName)
		{
			$oDbp.Tables[$i].View = $select ;
		
		}
		$i++
	  
	  }
	  
	  dbPassportSaveObj $oDbp ""


}
function DbPassportProcNameSet($dicName,$dbptableName,$dbParentTablName, $dbParentFieldName)
{
	$Tablidx=0;	
	  
	#write-host we are here
	#read-host
	  
	$oDbp = dbPassportReadObj $dicName 
	
	foreach($table in $oDbp.Tables)
	{
		if ($table.TableName -eq $dbptableName)
		{
		    $fieldidx = 0
		    foreach($field in $table.Fields)
			{
				if ($field.isConstraint)
				{
					# if ($field.Constraint)
				}
				$fieldidx = 0
			}
			
			$oDbp.Tables[$Tablidx].ViewName = $view ;
		
		}
		$Tablidx++	
	}
	dbPassportSaveObj $oDbp ""
	return ""

}
function dbPassportViewSet($dicName,$dbptableName,$view)
{
	  $i=0;	
	  
	 
	  
	  $oDbp = dbPassportReadObj $dicName 
	  
	 
      foreach($table in $oDbp.Tables)
	  {
		if ($table.TableName -eq $dbptableName)
		{
			$oDbp.Tables[$i].ViewName = $view ;
		
		}
		$i++
	  
	  }
	  
	  dbPassportSaveObj $oDbp ""


}

function process-dict($dict,$dictName)
{
$dbDictionary = "" | select Name, Tables
$dbDictionary.Tables=@()
# write-host $dictName
$dbDictionary.Name = $dictName.ToUpper()
$tables=@()
$tableexists = $false
$table = "" | select Name,Fields,DisplayName,FormName,FKeys,FieldOrder
$table.DisplayName = ""
$table.FormName = ""
$table.Fields=@()
$table.FKeys = @()
$table.FieldOrder = @()
$field = "" | select Name,Type,Lenght,DisplayName,Key
$foreignkey = "" | Select Table


foreach($line in $dict)
{
    $l = $line.trim()
	if ($l.length -gt 0)
	{
		 $arr=$l.split(":")
		 
		 if ($arr.count -gt 0)
		 {
				
				$fisrtw=$arr[0].trim().tolower()
				
				if ($fisrtw -eq 't')
				{
				    if (!$tableexists)
					{
					    $tableexists = $true
						
					}
					else
					{
						$tables +=$table
						$table = "" | select Name,Fields,DisplayName,FormName,FKeys,FieldOrder
						$table.DisplayName = ""
						$table.FormName = ""
						$table.Fields=@()
						$table.FKeys = @()
						$table.FieldOrder = @()
						

					}
					if ($arr.count -ge 2){
						$table.Name = $arr[1]
					}
					
					if ($arr.count -ge 3){
						$table.DisplayName = $arr[2]
					}
					
					if ($arr.count -ge 4){
						$table.FormName = $arr[3]
					}
						
						
				}
				if ($fisrtw -eq 's')
				{
					
				}
				if ($fisrtw -eq 'f')
				{
				    
					$field = "" | select Name,Type,DisplayName,Key
					$cnt = $arr.count
					$field.Name = $arr[1]
					$field.Type = $arr[2].ToUpper()
					$field.DisplayName=$arr[3].Substring(0,1).ToUpper()+$arr[3].Substring(1).ToLower()
					$field.Key=0
					if($cnt -gt 4)
					{
					     $field.Key=1
					}
					$table.Fields+=$field
					$table.FieldOrder+=$field.DisplayName+":"+$field.Name
					
				}
				if ($fisrtw -eq 'fk')
				{
				    
					
					$foreignkey = "" | Select Table , FieldName, RefFieldName
					$foreignkey.Table = $arr[1]
					$foreignkey.RefFieldName = 'name'
					$cnt = $arr.count
					if ($cnt -eq 4)
					{
						#write-host "FK RefName"
						#write-host $arr[3]
						#read-host
						$foreignkey.FieldName = $arr[2]
						$foreignkey.RefFieldName = $arr[3]
					}
					elseif ($cnt -eq 3)
					{
						
						$foreignkey.FieldName = $arr[2]
					}
					elseif ($cnt -eq 2) 
					{
						$foreignkey.FieldName = $foreignkey.Table
					}
					
					#write-host $foreignkey.Table
					#read-host
					
					$table.FKeys+=$foreignkey
					$table.FieldOrder+="FK:"+$foreignkey.Table+":name"
					
					
					#write-host $table.FKeys.Count
					#write-host $table.FKeys
					
					#write-host beg
					#foreach($fk in $table.FKeys)
					#{
					
						
					#	write-host $fk.Table
						
					#}
					#write-host end
					#read-host
					
				}				
				if ($fisrtw -eq 'end')
				{
					if ($tableexists)
					{
						$tables +=$table
						#write-host $tables
						#read-host
						$table = "" | select Name,Fields,DisplayName,FormName,FKeys,FieldOrder
						$table.DisplayName = ""
						$table.FormName = ""
						$table.Fields=@()
						$table.FKeys = @()
						$table.FieldOrder = @()
						
					    $tableexists = $false
					}
				
				}
		 }
	 }

}
if ($tableexists)
{
	$tables +=$table
}
		
$dbDictionary.Tables=$tables


return $dbDictionary

}

function get-dictionary($dictName)
{
	$dictfile = $global:wpath +"Dictionary\"+ $dictName
	$file = get-item $dictfile
   $diction = get-content $dictfile
   $fname = $file.BaseName
   # write-host $fname
   $dbDict = process-dict $diction $fname
   return ($dbDict) 
}
function get-sql($dict){

	$dbName = $dict.Name
	$mark = [char][int]96
	$crlf = [char][int]13+[char][int]10
	$sql =  "CREATE DATABASE  IF NOT EXISTS "+$mark+$dbName+$mark+";"+$crlf
	$sql += "USE "+$mark+$dbName+$mark+";"+$crlf+$crlf
	
	$views = @()
	$imgCnt = 1;
	
	foreach($table in $dict.Tables)
	{
		$tableName = $table.Name
		$sql += "DROP TABLE IF EXISTS "+$mark+$tableName+$mark+";"+$crlf
		$sql += "CREATE TABLE "+$mark+$tableName+$mark+" ("+$crlf
		$sqlSelect = "id,"
		$ViewFieldNames = "id,"
		
		$sqlTableViewIndex = "DROP VIEW IF EXISTS "+$tableName+"_index;"+$crlf
		$sqlTableViewIndex += "CREATE VIEW "+$tableName+"_index AS"+$crlf
		$sqlTableViewIndex += "SELECT id,"
		$fieldidx=1
		foreach($field in $table.Fields){
			$sql += "   "+$mark+$field.Name+$mark+" "
			$sqlSelect += $field.Name 
			$ViewFieldNames += $field.DisplayName
			$sqlTableViewIndex += $field.Name 
			$type = $field.Type.Substring(0,1)
			$FieldLen=$field.Type.Remove(0,1).trim()
			
			if ($FieldLen.length -eq 0 )
			{
				$FieldLen='default'
			}
			
			if ($type -eq "$")
			{
				$sql += "varchar("
				if ($FieldLen -eq 'default')
				{
					$sql += "50"
				}
				else
				{
					$sql += $FieldLen
				}
				
				$sql += ") NOT NULL COMMENT '"+$field.DisplayName+"',"+$crlf
			}
			if ($field.Type.ToLower() -eq "image")
			{
				#$sql += "varchar(256) NOT NULL COMMENT '"+$field.DisplayName+"',"+$crlf
				$sql += "MEDIUMTEXT NOT NULL COMMENT '"+$field.DisplayName+"',"+$crlf
				#$sql += "   "+$mark+"__img"+$imgCnt.ToString()+$mark+" MEDIUMTEXT NOT NULL ,"+$crlf
				$imgCnt++
				
			}
			if ($fieldidx -lt $table.Fields.count)
			{
				$sqlSelect +=","
				$ViewFieldNames +=","
				$sqlTableViewIndex +=","
			}
			$fieldidx++
		}
		$isView = $false
		
		$viewTable = "" | Select TableParent, FieldParent, TableChild, FieldChild
		$viewTable.TableParent = ""
		$viewTable.TableChild  = ""
		$viewTable.FieldParent = ""
		$viewTable.FieldChild  = ""
		
		
		#write-host  $table.FKeys.count
		
		$sqlview = ""
		$sqlproc = ""
		$parentSX = ""
		$fkidx =1;
		$selectFromView = ""
		foreach($fk in $table.FKeys)
		{
			
		    if ($fkidx -eq 1)
			{
				$ViewFieldNames +=","
				$sqlTableViewIndex +=","+$crlf
			}
		    # $referenceFieldName = $fk.Table+"_id"
		    $referenceFieldName = $fk.FieldName+"_id"
			# $sqlSelect += $referenceFieldName+","
		    $sql += "   "+$mark+$referenceFieldName+$mark+" int(10) UNSIGNED NOT NULL," +$crlf
			$sql += "   FOREIGN KEY("+$referenceFieldName+") REFERENCES "+$fk.Table+"(id),"+$crlf

			#write-host 215
			#write-host $table.Name
		    #write-host $fk.Table
			#write-host $sql
			#read-host
			$isView = $true
			$viewTable.TableParent = get-tableParent $dict $fk.Table
			$viewTable.TableChild  = $table
			#$viewTable.TableChild  = $fk.FieldName
			$viewTable.FieldChild  = $fk.FieldName
			$viewTable.FieldParent = $fk.RefFieldName
			
			$views += $viewTable
			
			
			$ViewFieldNames +=	$viewTable.TableParent.DisplayName		
			#$parentSX += "(SELECT name FROM "+$mark+$viewTable.TableParent.Name+$mark
			$parentSX += "(SELECT "+$fk.RefFieldName+" FROM "+$mark+$viewTable.TableParent.Name+$mark
			$parentSX += " WHERE "
			$parentSX += $viewTable.TableParent.Name+".id="
			#$parentSX += $viewTable.TableChild.Name +"."+$viewTable.TableParent.Name+"_id"
			$parentSX += $viewTable.TableChild.Name +"."+$fk.FieldName+"_id"
			$parentSX += ") as "+$fk.FieldName+"_name"
			
			
			# $parentSX += get-viewFieldName $viewTable.TableParent.Name
			#$parentSX += get-viewFieldName $viewTable.TableParent.Name
			
			# $parentSX += ","+$viewTable.TableParent.Name+"_id"
			$parentSX += ","+$fk.FieldName+"_id"
			$selectFromView += get-viewFieldName $viewTable.TableParent.Name
			if ($fkidx -lt $table.FKeys.Count)
			{
			    
				$parentSX += ","
				$selectFromView +=","
				$ViewFieldNames +=","
			}
			$parentSX += $crlf
			

		
			$sqlview += get-SQLview $dict $viewTable 
		    $sqlproc += get-SQLproc $dict $viewTable.TableParent $viewTable.TableChild $fk
			$fkidx++
		}
		
		
		
		$sqlTableViewIndex += $parentSX+" FROM "+$tableName + ";"+$crlf
		$sql += "   "+$mark+"id"+$mark+" int(10) UNSIGNED NOT NULL AUTO_INCREMENT,"+$crlf
		$sql += "     PRIMARY KEY ("+$mark+"id"+$mark+")"+$crlf
		$sql += ") ENGINE=MyISAM DEFAULT CHARSET=utf8;"+$crlf+$crlf
		
        		
		
		$keyscount =0
		foreach($field in $table.Fields){
			if ($field.Key -eq 1)
			{
				$keyscount++
			}
		}
		if ($keyscount -gt 0){
			$i=0
			$sql += "ALTER TABLE "+$mark+$tableName+$mark+$crlf
			foreach($field in $table.Fields){
				if ($field.Key -eq 1)
				{
					$i++
					$sql += "  ADD KEY "+$mark+$field.Name+$mark+" ("+$mark+$field.Name+$mark+")"
					
					if ($i -ne $keyscount)
					{
						$sql += ","
					}
					else
					{
						$sql += ";"
					}
					$sql +=$crlf 
					
				}
			}
			
		}
		$sql +=$crlf +$sqlTableViewIndex +$crlf +$sqlview +$crlf + $sqlproc + $crlf
		
		if ($selectFromView.Length -gt 0)
		{
			$sqlSelect+= ","+$selectFromView
		}
		
		dbPassportViewFieldNamesSet  $dict.Name $tableName $ViewFieldNames
		dbPassportSelectSet  $dict.Name $tableName $sqlSelect
		dbPassportViewSet $dict.Name $tableName $tableName

	
	}
	return $sql
}
function get-tableParent ($dict, $TableName)
{
    $tabl = ""
   	foreach($table in $dict.Tables) 
	{
		if ($table.Name -eq $TableName)
		{
			$tabl = $table
		}
	}
	
	return $tabl;
}
function get-SQLproc ($dict, $TableParent, $TableChild, $fk) # ( $dict)
{
	$mark = [char][int]96
	$crlf = [char][int]13+[char][int]10

	$sqlstr =  "/*"+$crlf+"* Generated by: get-SQLproc"+$crlf
	$sqlstr += "* " + $($(get-date).getdatetimeformats()[21])+$crlf
	$sqlstr += "*/"+$crlf

	
	
	#write-host $TableParent.Name
	#write-host $TableChild.Name
	#read-host
	#foreach($table in $dict.Tables)
	#{
		#foreach($fo in $table.FieldOrder)
		#{
			#$arr =  $fo.split(":")
			#if ($arr[0].toupper().trim() -eq "FK"){
				#$nameProc = get-sqlProcName $TableParent.Name "name"
				$nameProc = get-sqlProcName $fk.FieldName "name"
				
				$sqlstr += "DROP PROCEDURE if exists "+$mark+$nameProc+$mark+";"+$crlf+$crlf
				$sqlstr += 'DELIMITER $$'+$crlf
				$sqlstr += 'CREATE PROCEDURE '+$mark+$nameProc+$mark+$crlf
				$sqlstr += '(IN '+$mark+'idParam'+$mark+" INT(10))"+$crlf
				$sqlstr += 'begin'+$crlf
				# $sqlstr += 'select name from '+$TableParent.Name+" where "+$TableParent.Name+'.id=idParam;'+$crlf
				$sqlstr += 'select '+$fk.RefFieldName+' from '+$TableParent.Name+" where "+$TableParent.Name+'.id=idParam;'+$crlf
				$sqlstr += 'end'+$crlf+'$$'+'DELIMITER ;'+$crlf
				
				#$noret= DbPassportProcNameSet $dict.Name $TableParent $TableChild  $nameProc 
				
				$sqlstr += "/*"+$crlf+"* Generated by: get-SQLproc()"+$crlf
				$sqlstr += "* END:" + $crlf
				$sqlstr += "*/"+$crlf+$crlf+$crlf
					
				
			#}
		#}
	#}
	#write-host  $sqlstr
	#read-host
	return $sqlstr	

}
function get-sqlProcName($p1,$p2)
{
   $pName = 'get'
   $pName +=(Get-Culture).TextInfo.ToTitleCase($p1)
   $pName +=(Get-Culture).TextInfo.ToTitleCase($p2)
   
   return $pName
}

function get-SQLview($dict, $v)
{
	
	$mark = [char][int]96
	$crlf = [char][int]13+[char][int]10
	$sqlstr =  "/*"+$crlf+"* Generated by: get-SQLview"+$crlf
	$sqlstr += "* " + $($(get-date).getdatetimeformats()[21])+$crlf
	$sqlstr += "*/"+$crlf
	
		
		
		
		#foreach($v in $views)
		#{
			
		    #$nameView = $v.TableChild.Name+ "_"+ $v.TableParent.Name ;
		    $nameView = $v.FieldChild+$v.TableChild.Name+ "_"+ $v.TableParent.Name ;
			
			
			$selectParent = "SELECT "# Tchild.id AS "+$v.TableChild.Name+"_id, "
			<#
			$i = 1
			foreach($f in $v.TableParent.Fields)
			{
				#$selectParent += "Tchild."+$f.Name+" AS "+$v.TableChild.Name+"_"+$f.Name+" " 
				$selectParent += "Tchild."+$f.Name+" AS "+$v.FieldChild+"_"+$f.Name+" " 
				if ($i -lt $v.TableParent.Fields.count)
				{
					$selectParent += ", "
				}
				$i++
				
			}
			#>
			
			
			#$selectChild = "Tparent.id AS "+$v.TableParent.Name+"_id, "
			$selectChild = "Tparent.id AS "+$v.FieldChild+"_id, "
			
			
			$i = 1
			#foreach($f in $v.TableChild.Fields)
			foreach($f in $v.TableParent.Fields)
			{   
				# write-host $v.TableParent.Name
				if ($f.Name.tolower().trim() -eq 'name'){
				$selectChild += "Tparent."+$f.Name+" AS "+$v.TableParent.Name+"_"+$f.Name+" " 
				
				#if ($i -lt $v.TableChild.Fields.count)
				#{
			    #		$selectChild += ", "
				#}
				#$i++
				}
				
			}
			
			
			
			$sqlstr += "DROP VIEW IF EXISTS "+$nameView+";"+$crlf+$crlf
			
			$sqlstr += "CREATE VIEW "+$nameView+" AS "+$crlf
			$sqlstr += $selectParent + $crlf
			$sqlstr += $selectChild+$crlf
			$sqlstr += "FROM "+$mark+$v.TableChild.Name+$mark+" Tchild "+$crlf
			$sqlstr += "INNER JOIN "+$mark+$v.TableParent.Name+$mark+" Tparent "+$crlf
			#$sqlstr += "ON "+$v.TableParent.Name+"_id=Tparent.id;"+$crlf+$crlf
			$sqlstr += "ON "+$v.FieldChild+"_id=Tparent.id;"+$crlf+$crlf
			
			#write-host $sqlstr
			
			
			$dbpsql = "id,"
			$childS1 = "SELECT id,"
			$i = 1
			foreach($f in $v.TableChild.Fields)
			{
				$childS1 += $f.Name 
				$dbpsql += 	$f.Name
				if ($i -lt $v.TableChild.Fields.count)
				{
			    		$childS1 += ", "
						$dbpsql +=","
				}
				$i++
							
			}
			
			#$parentS1 = ",(SELECT name FROM "+$mark+$v.TableParent.Name+$mark
			$parentS1 = ",(SELECT "+$v.FieldParent+" FROM "+$mark+$v.TableParent.Name+$mark
			$parentS1 += " WHERE "
			$parentS1 += $v.TableParent.Name+".id="
			#$parentS1 += $v.TableChild.Name +"."+$v.TableParent.Name+"_id"
			$parentS1 += $v.TableChild.Name +"."+$v.FieldChild+"_id"
			$parentS1 += ") as "
			$parentS1 += get-viewFieldName $v.TableParent.Name
			
			
			#$dbpsql += ","+$v.TableParent.Name+"_name"
			$dbpsql += ","+$v.TableParent.Name+"_name"
			
			
			$sqlstr += "/*-------   ---    ------*/"+$crlf
			
			$childS1 += $parentS1+ " FROM "+$mark+$v.TableChild.Name+$mark+";"
			$sqlstr += "DROP VIEW IF EXISTS "+$nameView+"_index;"+$crlf+$crlf
			
			
			
			#dbPassportSelectSet  $dict.Name $v.TableChild.Name $dbpsql
			
			dbPassportViewSet $dict.Name $v.TableChild.Name $($nameView+"_index")
			
			$sqlstr += "CREATE VIEW "+$nameView+"_index AS "+$crlf+$childS1+$crlf+$crlf
			
			$sqlstr += "/*"+$crlf+"* Generated by: get-SQLview"+$crlf
			$sqlstr += "* END:" + $crlf
			$sqlstr += "*/"+$crlf+$crlf+$crlf
		#}
	
	
	return $sqlstr
}
function get-viewFieldName($tableName)
{
	return $($tableName+"_name")
}
# function get-controller($table)
# {
	# $crlf = [char][int]13+[char][int]10
	# $contrname = $table.Name.Substring(0,1).ToUpper()+$table.Name.Substring(1).ToLower()
    # $contr = "<?php"+$crlf+$crlf+"class "+$contrname+"Controller extends Controller"+$crlf+"{"+$crlf
	# $contr += '    public function __construct($data=array())'+$crlf+"    {"+$crlf
	# $contr += "       parent::__construct($data);"+$crlf
	# $contr += '       $this->model = new '+$contrname+'();'+$crlf+"    }"+$crlf+$crlf

	# # field for check in form , if form filled
	# # i.e. Surname-R001
	# $fieldForCheck = $table.Fields[0].Name+"-"+$table.FormName

	
	# $contr += '       public function index(){'+$crlf+$crlf
 
	
	# $contr += '            if (isset($_POST["hidden-form-id-'+$table.FormName+'"])) {'+$crlf+$crlf
    # $contr += '  	     	        $id = $_POST["hidden-form-id-'+$table.FormName+'"];'+$crlf+$crlf
	# #### update family !!!
	# $contr += '          	        if (isset($_POST["'+$fieldForCheck+'"])) {'+$crlf
    # $contr += '        	             if ($id == -1) {'+$crlf
    # $contr += '       	                 	$this->model->add($_POST);'+$crlf
    # $contr += '          	        	     $id = $this->model->lastID();'+$crlf
    # $contr += '                      } else {'+$crlf
    # $contr += '                 		     $this->model->update($_POST, $id);'+$crlf
    # $contr += '                      }'+$crlf+$crlf

    # $contr += '                     Router::redirect("/" . Config::get('+"'site_root') . "+'"'+$table.Name.tolower()+'/datasaved/" . $id . "/1A");'+$crlf
    # $contr += '              	} '+$crlf

	# $contr += '			   }'+$crlf
    # $contr += '            $this->data['+"'"+$table.Name.tolower()+"'"+'] = $this->model->getList();'+$crlf
	
	
	# $contr += "		}"+$crlf+$crlf	


    # # end index
	
	# # ------------------------------------------
    # # datasaved()
	
	
	# $contr += "    public function datasaved()"+$crlf	
	# $contr += "    {"+$crlf	
	# $contr += '        $parameters = $this->getParams();'+$crlf	
	# $contr += '        if (!is_null($parameters)) {'+$crlf	
	# $contr += '            if (count($parameters) >= 1) {'+$crlf
	# $contr += '                $id = $parameters[0];'+$crlf
	# $contr += '                $this->data['+"'"+$table.Name+"'"+'] = $this->model->getById($id);'+$crlf
 	# $contr += "               Session::setFlash('Информация успешно сохранена!');"+$crlf


 	# $contr += "            }"+$crlf
 	# $contr += "        }"+$crlf
 	# $contr += "    }"+$crlf	


    # # end datasaved
	# # ------------------------------------------
	
	# # ------------------------------------------
    # # delete()
	
	
 	# $contr += "    public function delete()"+$crlf
    # $contr += "	{"+$crlf
    # $contr += '    if ($_POST) {'+$crlf
    
	
	# $contr += '        if (isset($_POST["'
	# $hiddenFormID=get-hidden-formID $table 
	# $contr += $hiddenFormID
	# $contr +='"]))'+$crlf
	
	
    # $contr +="        {"+$crlf
	
    # $contr +='            $id=$_POST["'
	# $contr += $hiddenFormID
	# $contr += '"];'+$crlf
	

    
    # $contr += '            $this->model->deleteById($id);'+$crlf

    # $contr += "            Session::setFlash('Удалено!');"+$crlf

    # $contr += "        }"+$crlf	
    # $contr += "    }"+$crlf	+$crlf	
 	# $contr += "	}"+$crlf	


    # # end delete
	# # ------------------------------------------
	
	
	# # ------------------------------------------
    # # ask_for_delete()
	
	
 	# $contr += "    public function ask_for_delete()"+$crlf
 	# $contr += "    {"+$crlf

 	# $contr += '        if ($_POST) {'+$crlf
	# $contr += '            if (isset($_POST["'+$hiddenFormID+'"]))'+$crlf
	# $contr += '            {'+$crlf
	
	# $contr +='         	    $id=$_POST["'
	# $contr += $hiddenFormID
	# $contr += '"];'+$crlf



	# $contr += '                $this->data['+"'"+$table.Name+"'"+'] = $this->model->getById($id);'+$crlf
	# $contr += "                Session::setFlash('Уверены, что хотите удалить?');"+$crlf

	# $contr += "            }"+$crlf
	# $contr += "        }"+$crlf
	# $contr += "    }"+$crlf	


	
	# # ------------------------------------------
    # # end ask_for_delete()
	
		
	# $contr += "}"+$crlf	


	# return $contr
	
# }
# function get-model($table)
# {
	# $crlf = [char][int]13+[char][int]10
	# $modelname = $table.Name.Substring(0,1).ToUpper()+$table.Name.Substring(1).ToLower()
    # $model = "<?php"+$crlf+$crlf+"class "+$modelname+" extends model"+$crlf+"{"+$crlf
	# $model += '    public function getList($value = null)'+$crlf+"    {"+$crlf
	# $model += '       $sql = "select * from '+$table.Name+'";'+$crlf
	# $model += '       return $this->db->query($sql);'+$crlf+"    }"+$crlf+$crlf



	# # ------------------------------------------
    # # update()

	# $model += '    public function update($data, $id = null)'+$crlf
	# $model += '    {'+$crlf


	# $i=1
	# $model += '      if('+$crlf	

		
	# foreach($field in $table.Fields)
	# {
	    # $FormFieldName = get-FormFieldName $field.Name $table.FormName
		# $model += '			!isset($data['
		# $model += "'"+$FormFieldName+"'])"
		# if ($i -lt $table.Fields.Count)
		# {
			# $model += "	||"
		# }
		# $model +=$crlf	
		# $i++
	
	# }
	

	# $model += '        )'+$crlf		

	# $model += '		{'+$crlf	
	# $model += '            return false;'+$crlf	
	# $model += '		}'+$crlf+$crlf		
	# $model += '        $id =(int)$id;'+$crlf


	
	# foreach($field in $table.Fields)
	# {
	    # $FormFieldName = get-FormFieldName $field.Name $table.FormName	
		# $varName = '$'+$field.Name.tolower()
		
		# $model += ' 	    '+ $varName + ' = $this->db->escape($data['+"'"
		# $model += $FormFieldName
		# $model += "']);"+$crlf		

	# }

	# $model +=$crlf


	# $model +='        $sql = "UPDATE '+$table.Name +' SET'+$crlf


	# $i=1
	# foreach($field in $table.Fields)
	# {
	    # $FormFieldName = get-FormFieldName $field.Name $table.FormName	
		# $varName = '$'+$field.Name.tolower()
		
		# $model += '                    '+ $field.Name + "='{" + $varName +"}'"
		# if ($i -lt $table.Fields.Count)
		# {
			# $model += ","
		# }
		# $i++		
		
		# $model +=$crlf

	# }

	# $model +="       		        where id = '{" +'$id' +"}';"
	# $model +='";'+$crlf+$crlf
	
	# $model +='        return $this->db->query($sql);'+$crlf+$crlf	
	
	# $model += '    }'+$crlf

	# # ------------------------------------------
    # # end update
	
	# # ------------------------------------------
    # # getById
	
	# $model += '    public function getById($value=null)'+$crlf
	# $model += '    {'+$crlf
	# $model += '        $sql = "select * from ' + $table.Name+' ";'+$crlf
	# $model += '        if (isset($value)) {'+$crlf
 	# $model += '           if (is_numeric($value)) {'+$crlf
 	# $model += '                $sql .= "WHERE id = '+"'"+'" . $value . "'+"'"+' ";'+$crlf
 	# $model += '            }'+$crlf
 	# $model += '        }'+$crlf
 	# $model += '        $sql.= "  limit 1;";'+$crlf

 	# $model += '        return $this->db->query($sql);'+$crlf
 	# $model += '    }'+$crlf
	
	


	# # ------------------------------------------
    # # add()

	

	# $model += '    public function add($data)'+$crlf
	# $model += '    {'+$crlf


	# $i=1
	# $model += '      if('+$crlf	

		
	# foreach($field in $table.Fields)
	# {
	    # $FormFieldName = get-FormFieldName $field.Name $table.FormName
		# $model += '			!isset($data['
		# $model += "'"+$FormFieldName+"'])"
		# if ($i -lt $table.Fields.Count)
		# {
			# $model += "	||"
		# }
		# $model +=$crlf	
		# $i++
	
	# }
	

	# $model += '        )'+$crlf		

	# $model += '		{'+$crlf	
	# $model += '            return false;'+$crlf	
	# $model += '		}'+$crlf+$crlf		
	# #$model += '        $id =(int)$id;'+$crlf


	
	# foreach($field in $table.Fields)
	# {
	    # $FormFieldName = get-FormFieldName $field.Name $table.FormName	
		# $varName = '$'+$field.Name.tolower()
		
		# $model += ' 	    '+ $varName + ' = $this->db->escape($data['+"'"
		# $model += $FormFieldName
		# $model += "']);"+$crlf		

	# }

	# $model +=$crlf


	# $model +='        $sql = "INSERT INTO '+$table.Name +' SET'+$crlf


	# $i=1
	# foreach($field in $table.Fields)
	# {
	    # $FormFieldName = get-FormFieldName $field.Name $table.FormName	
		# $varName = '$'+$field.Name.tolower()
		
		# $model += '                    '+ $field.Name + "='{" + $varName +"}'"
		# if ($i -lt $table.Fields.Count)
		# {
			# $model += ","
		# }
		# $i++		
		
		# $model +=$crlf

	# }

	# $model +=';";'+$crlf+$crlf
	
	# $model +='        return $this->db->query($sql);'+$crlf+$crlf	
	
	# $model += '    }'+$crlf




	# # ------------------------------------------
    # # end add
	# $model += @'
    # public function lastID()
    # {
        # $sql="SELECT LAST_INSERT_ID();";
        # return $this->db->query($sql)[0]["LAST_INSERT_ID()"];
    # }

# '@	


	# $model += '    public function deleteById($value=null)'+$crlf
	# $model += '    {'+$crlf
	# $model += '        if (isset($value))'+$crlf
 	# $model += '       {'+$crlf

	# $model += '            $sql = "DELETE FROM '+$table.Name+" WHERE id = '" +'" . $value . "'+"'"+'";'+$crlf

	# $model += '            return $this->db->query($sql);'+$crlf
	# $model += '        }'+$crlf
	# $model += '    }'+$crlf
	
	
	# # end class
	# $model += "}"+$crlf	
	# return $model	
# }
# function get-view($table)
# {
	# $crlf = [char][int]13+[char][int]10
	# $viewname = $table.Name.tolower()
	# $jsname = get-jsname $table.Name $table.FormName
	# # write-host $jsname
	# $html  ='<script src="/<?=Config::get('+"'site_root')?>js/" +$jsname+'"></script>'+$crlf
	# $html +='	<div id="'+$viewname+'_index">'+$crlf
	# $html +='	        <table class="table table-bordered table-striped table-hover" id="'+$viewname+'-table">'+$crlf+$crlf
	# $html +='					<tr>'+$crlf
	# $fieldscount=$table.Fields.count+1
	# $percnt = [math]::Round((100/$fieldscount))
	# $last_column_percnt = $percnt+(100-($percnt*$fieldscount))
	
	# foreach($field in $table.Fields)
	# {
    	# $html +='		       		     <th width="'+$percnt.ToString()+'%">'+$field.DisplayName+"</th>"+$crlf	
	# }
	# $addbutton  = '<button class="btn btn-warning btn-lg" type="button" onclick="AddModal('
	# $addbutton += "'<?=Config::get('site_root')?>')"
	# $addbutton += '" data-target="#myModal" data-toggle="modal"><span class="glyphicon glyphicon-plus"></span>New</button>'
    # $html +='		       		     <th width="'+$last_column_percnt.ToString()+'%">' +$addbutton+"</th>"+$crlf	
	
	
	# $html +='					</tr>'+$crlf+$crlf
	# $html +="					<?php foreach("+'$data'+"['"+$viewname+"']"+' as $row) {?>'+$crlf
	# $html +='					<tr>'+$crlf
	# foreach($field in $table.Fields){
		# $html +='						 <td width="'+$percnt.ToString()+'%">'
		# $html +='<?php echo $row['+"'"+$field.Name+"']; ?>"
		# $html +='</td>'	+$crlf
	# }
	# $EditButton ='<button class="btn btn-info btn-lg" type="button" onclick="showModal('
	# $EditButton+="'<?=" + '$row["id"'+"]?>',"
	
	# foreach($field in $table.Fields){
		# $EditButton+="'"+'<?=$row["' + $field.Name +'"'+"]?>',"
	
	# }
	
	# $EditButton+="'<?=Config::get('site_root')?>')"
	# $EditButton+='" data-target="#myModal" data-toggle="modal">'
	# $EditButton+='<span class="glyphicon glyphicon-file"></span>Open</button>'
	# # write-host $EditButton 
	
	
	                        # #<button class="btn btn-info btn-lg" type="button"
                            # #    onclick="showModal('<?=$row["id"]?>','<?=$row["FAMILY"]?>','<?=$row["PHONE"]?>','<?=$row["ADDRESS"]?>','<?=$row["HOUSE"]?>','<?=$row["FLAT"]?>','<?=Config::get('site_root')?>')" data-target="#myModal" data-toggle="modal">
							# # <span
                            # #    class="glyphicon glyphicon-file"></span>Open
                        # #</button>

	# $html +='		       		     <td width="'+$last_column_percnt.ToString()+'%">'+$EditButton+"</td>"+$crlf	
	
	# $html +='					</tr>'+$crlf
	# $html +="					<?php } ?>"+$crlf+$crlf
	
	# $html +='	        </table>'+$crlf
	# $html +='	</div>'+$crlf
	
	
	# $html += @'

	# <div id="myModal" class="modal fade" role="dialog" >
	# <!--div id="myModal" class="modal fade notice-success" role="dialog" -->
		# <div class="modal-dialog">
			# <div class="modal-content">
				# <div class="modal-header">
					# <button type="button" class="close" data-dismiss="modal">&times;</button>
					# <h2 class="modal-title"></h2>
				# </div>
				# <!--div class="modal-body grad" -->
				# <div class="modal-body" >

				# </div>
				# <div class="modal-title">
				# </div>
				# <div class="modal-footer">

					
					# <button type="button" class="btb btn-default" data-dismiss="modal">Close</button>

				# </div>
			# </div>
		# </div>
	# </div>


# '@
	# return $html
# }


# function get-datasaved($table)
# {
	# $crlf = [char][int]13+[char][int]10
	# $viewname = $table.Name.tolower()
	# $jsname = get-jsname $table.Name $table.FormName
	# # write-host $jsname
	# $html +='<div>'+$crlf

	# $html +='   <form action="/<?=Config::get('
	# $html +="'site_root')?>" + $table.Name
	# $html +='" method="post">'+$crlf

	# $html +=@'
        # <div class="row-md-8">
            # <button class="btn btn-success" type="submit">Ok</button>

        # </div>
        # <br/>


    # </form>
	
# '@
	
	# $html +='	<div id="'+$viewname+'_index">'+$crlf
	# $html +='	        <table class="table table-bordered table-striped table-hover" id="'+$viewname+'-table">'+$crlf+$crlf
	# $html +='					<tr>'+$crlf
	# $fieldscount=$table.Fields.count
	# $percnt = [math]::Round((100/$fieldscount))
	# $last_column_percnt = $percnt+(100-($percnt*$fieldscount))
	
	# foreach($field in $table.Fields)
	# {
    	# $html +='		       		     <th width="'+$percnt.ToString()+'%">'+$field.DisplayName+"</th>"+$crlf	
	# }


	
	# $html +='					</tr>'+$crlf+$crlf
	# $html +="					<?php foreach("+'$data'+"['"+$viewname+"']"+' as $row) {?>'+$crlf
	# $html +='					<tr>'+$crlf
	# foreach($field in $table.Fields){
		# $html +='						 <td width="'+$percnt.ToString()+'%">'
		# $html +='<?php echo $row['+"'"+$field.Name+"']; ?>"
		# $html +='</td>'	+$crlf
	# }
	
	# $html +='					</tr>'+$crlf
	# $html +="					<?php } ?>"+$crlf+$crlf
	
	# $html +='	        </table>'+$crlf
	# $html +='	</div>'+$crlf	
	# $html +='</div>'+$crlf
	
	

	# return $html
# }

# function get-deleteHTML($table)
# {
	# $crlf = [char][int]13+[char][int]10
	# $html +='   <form action="/<?=Config::get('
	# $html +="'site_root')?>" + $table.Name
	# $html +='" method="post">'+$crlf
	
	# $html +=@'
        # <div class="row-md-8">
            # <button class="btn btn-success" type="submit">Ok</button>

        # </div>
        # <br/>


    # </form>
# '@
	
	# return $html
# }


<# function get-AskForDelete($table)
{
	$crlf = [char][int]13+[char][int]10
	$viewname = $table.Name.tolower()
	$jsname = get-jsname $table.Name $table.FormName
	# write-host $jsname
	$html +='<div>'+$crlf
	$html +='   <div class="row-md-8">'+$crlf


	$html +='   <form action="/<?=Config::get('
	$html +="'site_root')?>" + $table.Name
	$html +='/delete" method="post">'+$crlf

	$hiddenFormID=get-hidden-formID($table)
	
	$html +='           <input type="hidden" id="'
	$html +=$hiddenFormID
	$html +='" name="'
	$html +=$hiddenFormID
	$html +='" value="<?php echo $data['+"'"+$table.Name+"'"+'][0]["id"]; ?>">'+$crlf
	$html +='            <button  type="submit" class="btn btn-danger"><span class="glyphicon glyphicon-trash"></span>Удалить</button>'+$crlf
	
	$html +="        </form>"+$crlf
 
 
 	$html +='   <form action="/<?=Config::get('
	$html +="'site_root')?>" + $table.Name
	$html +='" method="post">'+$crlf
	
    $html +='        <button  type="submit" class="btn btn-info"><span class="glyphicon glyphicon-backward"></span>Отмена</button>'+$crlf
    $html +='    </form>'+$crlf
    $html +='</div>'+$crlf
    $html +='<br/>'+$crlf




	
	$html +='	<div id="'+$viewname+'_index">'+$crlf
	$html +='	        <table class="table table-bordered table-striped table-hover" id="'+$viewname+'-table">'+$crlf+$crlf
	$html +='					<tr>'+$crlf
	$fieldscount=$table.Fields.count
	$percnt = [math]::Round((100/$fieldscount))
	$last_column_percnt = $percnt+(100-($percnt*$fieldscount))
	
	foreach($field in $table.Fields)
	{
    	$html +='		       		     <th width="'+$percnt.ToString()+'%">'+$field.DisplayName+"</th>"+$crlf	
	}


	
	$html +='					</tr>'+$crlf+$crlf
	$html +="					<?php foreach("+'$data'+"['"+$viewname+"']"+' as $row) {?>'+$crlf
	$html +='					<tr>'+$crlf
	foreach($field in $table.Fields){
		$html +='						 <td width="'+$percnt.ToString()+'%">'
		$html +='<?php echo $row['+"'"+$field.Name+"']; ?>"
		$html +='</td>'	+$crlf
	}
	
	$html +='					</tr>'+$crlf
	$html +="					<?php } ?>"+$crlf+$crlf
	
	$html +='	        </table>'+$crlf
	$html +='	</div>'+$crlf	
	$html +='</div>'+$crlf
	
	

	return $html
} #>
function get-gridFromPassport($name)
{
	$crlf = [char][int]13+[char][int]10
	$tab  = [char][int]9
	$gendir = "..\gen\"+$name+"\grid\"
	$dpPassp = dbPassportReadObj($name)
	              #12345678901234567890
	$formHeader = ";Database Name     : "+$dpPassp.Name+$crlf+$crlf
	$formHeader += ";replace protect:yes, if you edited GRID manually"+$crlf
	$formHeader += ";or replace protect:no, if you want to replace this file by script"+$crlf

	$formHeader += "protect:no"+$crlf+$crlf+$crlf
	
	foreach($table in $dpPassp.Tables)
	{
	    
		
		$formBody  = "t:"+$table.TableName+":"+$table.FormName+":"+$table.DisplayName+$crlf
					 #12345678901234567890
		$formBody += ";Form Type         :"+$table.FormType+$crlf+$crlf+$crlf
		
		$formBody += "View:"+$table.ViewIndex+$crlf+$crlf+$crlf
		
		$navs = @()
		
		
		foreach($f in $table.FormFields)
		{
			$nav = "" | Select Name, DisplayName
			$nav.Name = $f.Name
			$nav.DisplayName = $f.DisplayName
			$formBody += $crlf+"BeginField"+$crlf+$crlf
			$formBody += $tab+";Following lines you can change."+$crlf
			$formBody += $tab+"DisplayName:"+$f.DisplayName+$crlf
			$formBody += $tab+";Required Yes or No"+$crlf
			$req = ":No"
			if ($f.Required)
			{
				$req = ":Yes"
			}

			$formBody += $tab+"Required"+$req+$crlf+$crlf
			$formBody += $tab+";DO NOT CHANGE THE FOLLOWING LINES"+$crlf
			$FormType = ":Simple"
			if ($f.isConstraint)
			{
					$FormType = ":Constraint"
					$nav.Name = $f.Constraint.ViewField
			}
			$formBody += $tab+"Type"+$FormType+$crlf
			
			
			$json = $($f| ConvertTo-Json -Compress).toString()

			$sCrypted   = Convert-Base $json 'TO'
			$sDecrypted = Convert-Base $sCrypted  'FROM'
		
			
			$formBody +=$tab+";json:"+$sDecrypted+$crlf
			$formBody +=$tab+"Base64:"+$sCrypted+$crlf+$crlf
			$formBody +="EndField"+$crlf
			
			
			
			
			$navs+=$nav
			
			
		}
		$fieldCount = 1
		
		$navbody = $crlf+"; comment or uncomment fields if you want change grid"+$crlf+"GRID"+$crlf # "tab:"+$table.DisplayName+$crlf
		$navcount = 0
		$comment = ""
		foreach($nav in $navs)
		{
			$fieldCount++
			if ($fieldCount -gt 9)
			{
				$comment = ";"
			}
			elseif ($fieldCount -gt 8)
			{
				$comment = $crlf+";"

			}
			
			#if ($fieldCount -eq 1)
			#{
			#	$navbody += $crlf+$crlf+$crlf+$crlf+"tab:"+$table.DisplayName+$navcount.ToString()+$crlf
			#}
			$navbody +=$comment+$nav.DisplayName+":"+$nav.Name+$crlf
			
		}
		$navbody =$crlf+$crlf+$crlf+$navbody+"ENDGRID"
		$formDirName = "..\gen\"+$name+"\grid\" # +$table.FormType+"\"
		
		if (!(Test-Path -Path $formDirName))
		{
			New-Item -ItemType Directory  -Force -Path $formDirName
		}
		$form = $formHeader +   $navbody + $crlf+$crlf+$crlf+$crlf+$formBody
		
		
		$formname = $formDirName + $table.TableName + ".grid"
		
		$isGridProtect = Check-formStatus $formname
		if (!$isGridProtect)
		{
			
			#write-host $formname
			$form  | out-file  -filepath $formname -encoding Unicode -Force	
		}
		
		
		$frmctx = Open-grid $name $table.TableName
		if (![String]::IsNullOrEmpty($frmctx))
		{
			
			$retnull = get-GridObj $frmctx  $name
		}
		
	}
	
	
	# dbPassportSaveObj  $dpPassp ""
}
function get-formsFromPassport($name)
{
	$crlf = [char][int]13+[char][int]10
	$tab  = [char][int]9
	$gendir = "..\gen\"+$name+"\forms\"
	$dpPassp = dbPassportReadObj($name)
	              #12345678901234567890
	$formHeader = ";Database Name     : "+$dpPassp.Name+$crlf+$crlf
	$formHeader += ";replace protect:yes, if you edited form manually"+$crlf
	$formHeader += ";or replace protect:no, if you want to replace this file by script"+$crlf

	$formHeader += "protect:no"+$crlf+$crlf+$crlf
	
	foreach($table in $dpPassp.Tables)
	{
	    
		
		$formBody  = "t:"+$table.TableName+":"+$table.FormName+":"+$table.DisplayName+$crlf
					 #12345678901234567890
		$formBody += ";Form Type         :"+$table.FormType+$crlf+$crlf+$crlf
		
		$formBody += "View:"+$table.ViewIndex+$crlf+$crlf+$crlf
		
		$navs = @()
		
		
		foreach($f in $table.FormFields)
		{
			
			$nav = "" | Select Name, DisplayName
			$nav.Name = $f.Name
			$nav.DisplayName = $f.DisplayName
			$formBody += $crlf+"BeginField"+$crlf+$crlf
			$formBody += $tab+";Following lines you can change."+$crlf
			$formBody += $tab+"DisplayName:"+$f.DisplayName+$crlf
			$formBody += $tab+";Required Yes or No"+$crlf
			$req = ":No"
			if ($f.Required)
			{
				$req = ":Yes"
			}

			$formBody += $tab+"Required"+$req+$crlf+$crlf
			$formBody += $tab+";DO NOT CHANGE THE FOLLOWING LINES"+$crlf
			$FormType = ":Simple"
			if ($f.isConstraint)
			{
					$FormType = ":Constraint"
					$nav.Name = $f.Constraint.ViewField
			}
			$formBody += $tab+"Type"+$FormType+$crlf
			
			
			$json = $($f| ConvertTo-Json -Compress).toString()

			$sCrypted   = Convert-Base $json 'TO'
			$sDecrypted = Convert-Base $sCrypted  'FROM'
		
			
			$formBody +=$tab+";json:"+$sDecrypted+$crlf
			$formBody +=$tab+"Base64:"+$sCrypted+$crlf+$crlf
			$formBody +="EndField"+$crlf
			
			
			
			
			$navs+=$nav
			
			
		}
		$fieldCount = 1
		
		$navbody = "tab:"+$table.DisplayName+$crlf
		$navcount = 0
		foreach($nav in $navs)
		{
			$fieldCount++
			if ($fieldCount -gt 6)
			{
				$fieldCount = 1
				$navcount++
			}
			
			if ($fieldCount -eq 1)
			{
				$navbody += $crlf+$crlf+$crlf+$crlf+"tab:"+$table.DisplayName+$navcount.ToString()+$crlf
			}
			$navbody +=$tab+$nav.DisplayName+":"+$nav.Name+$crlf
			
		}
		$navbody +=$crlf+$crlf+$crlf
		$formDirName = "..\gen\"+$name+"\forms\tabbed\" # +$table.FormType+"\"
		
		if (!(Test-Path -Path $formDirName))
		{
			New-Item -ItemType Directory  -Force -Path $formDirName
		}
		$form = $formHeader + $formBody +  $navbody 
		
		
		# $formname = $formDirName + $table.TableName + "-"+$table.FormName+".wnf"
		$formname = $formDirName + $table.TableName + ".wnf"
		
		$isFormProtect = Check-FormStatus $formname
		if (!$isFormProtect)
		{
			
			#write-host $formname
			$form  | out-file  -filepath $formname -encoding Unicode -Force	
		}
		$frmctx = Open-Form $name $table.TableName
		if (![String]::IsNullOrEmpty($frmctx))
		{
			#write-host $frmctx
			#read-host
			$retnull = get-TabbedFormObj $frmctx  $name
		}
		# $retnull = FormSaveObj $form $name
	}
	
	
	dbPassportSaveObj  $dpPassp ""
}
function Check-FormStatus($formname)
{

$status = $false
If (Test-Path $formname)
{
	$frmctx = get-content $formname

	foreach($line in $frmctx)
	{
		$l = $line.trim().tolower();
		if (![string]::IsNullOrEmpty($l))
		{
			if ($l.Contains(":")){
				$w = $l.Split(":")
				if ($w[0] -eq "protect")
				{
					if ($w[1] -eq 'yes')
					{
						$status = $true
					}
					elseif ($w[1] -eq 'no')
					{
						$status = $false
					}
				}
			}
		}
	}
}
return $status
}
function get-form($dbname,$table,$dirview,$viewname)
{
	$crlf = [char][int]13+[char][int]10
	$wnf ="t:"+$table.Name+":"+$table.FormName+$crlf+$crlf
	$jsname = get-jsname  $table.Name $table.FormName 
	$wnf +="; database - "+$dbname+$crlf
	$wnf +="; table    - "+$table.Name+$crlf
	$wnf +=", form     - "+$table.FormName+$crlf
	$wnf +="; html     - "+$dirview+$viewname+ $crlf
	$wnf +="; js       - /webroot/js/"+$table.Name+$table.FormName+".js"+$crlf+$crlf
	
	$wnf +="; To generate js - run powershell script  [.\gen-js.ps1 -FormName "+$table.Name+"-"+$table.FormName+".wnf]"+$crlf+$crlf
	
	$wnf +=";           НЕ ПОЛЬЗУЙТЕСЬ  в  примечаниях  знаком   двоеточие"+$crlf+$crlf
	$wnf +="; следует   менять   только порядок   при   выводе  формы  или убирать поле"+$crlf
	$wnf +="; не нужно убирать или изменять params, без этого js не будет сгенерирован."+$crlf+$crlf+$crlf+$crlf+$crlf+$crlf
	
	$wnf +="params:id,"
	
	foreach($field in $table.Fields)
	{
		$wnf +=$field.Name+","
	}
	$wnf +="siteroot"+$crlf+$crlf
	
	foreach($field in $table.Fields)
	{
		$wnf +=$field.DisplayName+":"+$field.Name+$crlf+$crlf+$crlf
	}

	#foreach($fo in $table.FieldOrder)
	#{
	#		$wnf += $fo+$crlf
	#}
	
	
	
	return $wnf
}
function Open-Form($DictName, $TableName)
{
     $formDirName = "..\gen\"+$DictName+"\forms\tabbed\" # +$table.FormType+"\"
     $formname = $formDirName + $TableName + ".wnf"
		
	 
	
	 #write-host $formname
	 $frm = ""
     if (!$(Test-Path $formname))
	 {
		write-host $("Form file "+$formname+" not exists") -foreground yellow
		
	 }
	 else
	 {
         $frm = Get-content $formname
	 }
	 return $frm
}
function Open-Grid($DictName, $TableName)
{
     $formDirName = "..\gen\"+$DictName+"\grid\" # +$table.FormType+"\"
     $formname = $formDirName + $TableName + ".grid"
		
	 
	
	 #write-host $formname
	 $frm = ""
     if (!$(Test-Path $formname))
	 {
		write-host $("Grid file "+$formname+" not exists") -foreground yellow
		
	 }
	 else
	 {
         $frm = Get-content $formname
	 }
	 return $frm
}

function get-GridObj($formctx , $dictName)
{
	$gridObj = "" | Select Name, Dictionary, FormName,Description, View,  Fields
	$gridObj.Name=""
	$gridObj.Dictionary = $dictName
	$gridObj.FormName=""
	$gridObj.Description=""
	$gridObj.View=""
	$gridObj.Fields = @()
	# collect fields
	
	$gridFields = @()
	$isGrid = $false
	foreach($line in $formctx)
	{
		$l = $line.trim()
		if (![string]::IsNullOrEmpty($l) )
		{
			if ($l.Substring(0,1) -ne ";")
			{
				if ($l.ToUpper() -eq "GRID")
				{
					$isGrid = $true
				}
				if ($l.ToUpper() -eq "ENDGRID")
				{
					$isGrid = $false
				}
				if ($isGrid)
				{
					if ($l.Contains(":"))
					{
						$arr=$l.split(":")
						$f = "" | Select Name,DisplayName
						$f.Name = $arr[1]
						$f.DisplayName = $arr[0]
						$gridFields +=$f
					}
				}
			}			
		}
	}
	
	
	# collect information about field
	$fieldReals = @()
	
	$isField = $false
	foreach($line in $formctx)
	{
	     $l = $line.trim()	
		 
		 
		 if ($l -eq "BeginField")
		 {
			$isField = $true
			
			$fReal = "" | Select Name, DisplayName, Required, json
			$fReal.Name =""
			$fReal.DisplayName = ""
			$fReal.Required = $false
			$fReal.json  = ""
		 }
		 if ($l -eq "EndField")
		 {
		    forEach($gf in $gridFields){
				if (($gf.Name -eq $fReal.Name) -and ($gf.DisplayName -eq $fReal.DisplayName))
				{

					$fieldReals +=$fReal
					break
				}
			}
			$isField = $false
		 }
		if ($isField)
		{
			#write-host $l
			#read-host
			
			if (![string]::IsNullOrEmpty($l) )
			{
				if ($l.Substring(0,1) -ne ";")
				{
					if ($l.Contains(":"))
					{
						$w = $l.Split(":")
						if ($w.Count -gt 1)
						{
							#write-host $l
							#read-host
							if ($w[0].ToLower() -eq "displayname")
							{
								$fReal.DisplayName = $w[1]
							}
							elseif ($w[0].ToLower() -eq "required")
							{
								# $fReal.Required 
								if ($w[1].ToLower() -eq 'yes')
								{
									$fReal.Required = $true
								}
							}
							elseif ($w[0].ToLower() -eq "base64")
							{
								$sCrypted = $w[1]
								$fReal.json = Convert-Base $sCrypted  'FROM'
								
								$jsob = $fReal.json | ConvertFrom-Json
								$fReal.Name = $jsob.Name
								if ($jsob.isConstraint)
								{
									$fReal.Name = $jsob.Constraint.ViewField
								}	
							}
							
						}
					}	
				}
			}
		}	
	}
			
		 
	$fieldROrder = @()
	
	forEach($gf in $gridFields){
	
		foreach($fr in $fieldReals)
		{
			if (($gf.Name -eq $fr.Name) -and ($gf.DisplayName -eq $fr.DisplayName)){
				$fieldROrder +=	$fr
				break
			}
		}
	}
	
	$fieldReals = $fieldROrder
	


	
	foreach($line in $formctx)
	{
	    $l = $line.trim()
		if ($l -eq "BeginField")
		{
			$isField = $true
			

		}
		if ($l -eq "EndField")
		{
			$isField = $false
	
		}
		if (!$isField)
		{
			if (($l.length -gt 0) -and ($l.Substring(0,1) -ne ";"))
			{
				$arr=$l.split(":")
				if ($arr.count -gt 0)
				{
					<#
					foreach($a in $arr)
					{
						write-host $a
					}
					read-host
					#>
					$fisrtw=$arr[0].trim().tolower()
					if ($fisrtw -eq 't')
					{
						$gridObj.Name=$arr[1]
						$gridObj.FormName=$arr[2]
						$gridObj.Description=$arr[3]
						
						
					}elseif($fisrtw -eq 'view')
					{
						#$gridObj.View=$arr[1].Split(",")
						$gridObj.View = $arr[1]
					}
					elseif($fisrtw -eq 'tab')
					{
						if ($currentTab.Fields.Count -gt 0)
						{
							$gridObj.tabs += $currentTab
						}
						$currentTab="" | Select Name,Fields
						$currentTab.Name = $arr[1]
						$currentTab.Fields=@()

					}
					 else
					 {
						foreach($fReal in $fieldReals)
						{
							if ($fReal.Name -eq $arr[1])
							{

								$field = "" | select Label,Name,Value,isConstraint, IsReq,json 
								$field.Name = $arr[1]
								$field.Label = $fReal.DisplayName
								$field.IsReq=$fReal.Required
								$field.Value = $field.Name
								
								$jsob = $fReal.json | ConvertFrom-Json
								
								$field.isConstraint = $jsob.isConstraint
								
								if ($field.isConstraint)
								{
									
									$field.Value = $jsob.Name
									
								}
								
								$field.json=$fReal.json
								$gridObj.Fields += $field
								#write-host $arr[1]
								# read-host
	
								break
							}
						}
						
						
					}
				}
				
					
				
			}
		}
	}	

	$retnull = GridSaveObj $gridObj $gridObj.Dictionary | out-null
	
	
	# $go = gridGetObj $gridObj.Dictionary $gridObj.Name
	
    return $gridObj
}
function get-TabbedFormObj($formctx , $dictName)
{
	$tabbedForm = "" | Select Name,Dictionary, FormName,Description, View,  tabs
	
	$tabbedForm.Name=""
	$tabbedForm.Dictionary = $dictName
	$tabbedForm.FormName=""
	$tabbedForm.Description=""
	$tabbedForm.View=""
	
	
	
	$tabbedForm.tabs=@()
	
	
	# collect information about field
	$fieldReals = @()
	
	$isField = $false
	foreach($line in $formctx)
	{
	     $l = $line.trim()	
		 
		 
		 if ($l -eq "BeginField")
		 {
			$isField = $true
			
			$fReal = "" | Select Name, DisplayName, Required, json
			$fReal.Name =""
			$fReal.DisplayName = ""
			$fReal.Required = $false
			$fReal.json  = ""
		 }
		 if ($l -eq "EndField")
		 {
			$isField = $false
			$fieldReals +=$fReal
			
		 }
		if ($isField)
		{
			#write-host $l
			#read-host
			
			if (![string]::IsNullOrEmpty($l) )
			{
				if ($l.Substring(0,1) -ne ";")
				{
					if ($l.Contains(":"))
					{
						$w = $l.Split(":")
						if ($w.Count -gt 1)
						{
							#write-host $l
							#read-host
							if ($w[0].ToLower() -eq "displayname")
							{
								$fReal.DisplayName = $w[1]
							}
							elseif ($w[0].ToLower() -eq "required")
							{
								$fReal.Required 
								if ($w[1].ToLower() -eq 'yes')
								{
									$fReal.Required = $true
								}
							}
							elseif ($w[0].ToLower() -eq "base64")
							{
								$sCrypted = $w[1]
								$fReal.json = Convert-Base $sCrypted  'FROM'
								
								$jsob = $fReal.json | ConvertFrom-Json
								$fReal.Name = $jsob.Name
								if ($jsob.isConstraint)
								{
									$fReal.Name = $jsob.Constraint.ViewField
								}	
							}
							
						}
					}	
				}
			}
		}	
	}
			
		 
	
	

	
	

	$currentTab="" | Select Name,Fields
	$currentTab.Name = ""
	$currentTab.Fields=@()
	$isField = $false
	foreach($line in $formctx)
	{
	    $l = $line.trim()
		if ($l -eq "BeginField")
		{
			$isField = $true
			

		}
		if ($l -eq "EndField")
		{
			$isField = $false
	
		}
		if (!$isField)
		{
			if (($l.length -gt 0) -and ($l.Substring(0,1) -ne ";"))
			{
				$arr=$l.split(":")
				if ($arr.count -gt 0)
				{
					<#
					foreach($a in $arr)
					{
						write-host $a
					}
					read-host
					#>
					$fisrtw=$arr[0].trim().tolower()
					if ($fisrtw -eq 't')
					{
						$tabbedForm.Name=$arr[1]
						$tabbedForm.FormName=$arr[2]
						$tabbedForm.Description=$arr[3]
						
						
					}elseif($fisrtw -eq 'view')
					{
						#$tabbedForm.View=$arr[1].Split(",")
						$tabbedForm.View = $arr[1]
					}
					elseif($fisrtw -eq 'tab')
					{
						if ($currentTab.Fields.Count -gt 0)
						{
							$tabbedForm.tabs += $currentTab
						}
						$currentTab="" | Select Name,Fields
						$currentTab.Name = $arr[1]
						$currentTab.Fields=@()

					}
					else
					{
						foreach($fReal in $fieldReals)
						{
							if ($fReal.Name -eq $arr[1])
							{

								$field = "" | select Label,Name,Value,isConstraint, IsReq,json 
								$field.Name = $arr[1]
								$field.Label = $fReal.DisplayName
								$field.IsReq=$fReal.Required
								$field.Value = $field.Name
								
								$jsob = $fReal.json | ConvertFrom-Json
								
								$field.isConstraint = $jsob.isConstraint
								
								if ($field.isConstraint)
								{
									
									$field.Value = $jsob.Name
									
								}
								
								$field.json=$fReal.json
								$currentTab.Fields += $field
								#write-host $arr[1]
								# read-host
	
								break
							}
						}
						
						
					}
				}
				
					
				
			}
		}
	}
	
	
	
	$tabbedForm.tabs += $currentTab
	$tabbedForm.Description = $tabbedForm.tabs[0].Name
	
	$retnull = FormSaveObj $tabbedForm $tabbedForm.Dictionary | out-null
	
	#$r = $tabbedForm |ConvertTo-Json -Depth 100
	#write-host $r

	return $tabbedForm	
	
	
	
}

function get-TabbedFormHtml($formo)
{
      

}


Function Get-Formjs($formctx)
{
     $formo = "" | Select Name, FormName, Params, ParamString, FormGroup
	 $formo.Name=""
	 $formo.FormName=""
	 $formo.ParamString=""
	 $formo.Params=@()

	 $formo.FormGroup=@()
	 
	 
	 
	 foreach($line in $formctx)
	 {
	     $l = $line.trim()
		if ($l.length -gt 0)
		{
			$arr=$l.split(":")
			if ($arr.count -gt 0)
			{
				$fisrtw=$arr[0].trim().tolower()
				if ($fisrtw -eq 't')
				{
					$formo.Name=$arr[1]
					$formo.FormName=$arr[2]
					
					
				}elseif($fisrtw -eq 'params')
				{
					$formo.Params=$arr[1].Split(",")
					$formo.ParamString = $arr[1]
				}
				elseif($formo.Params.Contains($arr[1]))
				{
					
					$arrtemp = $arr[0],$arr[1]
					$formo.FormGroup += , $arrtemp
				}
			}
			
				
			
		}
	}

	return $formo 
	 
}
function create-js($formo)
{
	$crlf = [char][int]13+[char][int]10
	
	$hiddenFormID=get-hidden-formID($formo)
	$scr  = "function showModal("+$formo.ParamString+") {"+$crlf +$crlf
	$scr += "    html =  '<form class="+'"'+'form-horizontal"   role="form" action="/'+"'+siteroot+'"
	$scr += $formo.Name
	$scr += '/ask_for_delete" method="post">'+">';"+$crlf +$crlf
	
    # html =  '<form class="form-horizontal"   role="form" action="/'+siteroot+'pbk/ask_for_delete" method="post">';


    foreach($fgr in $formo.FormGroup){

		$formid =$fgr[1]+"-"+$formo.FormName
		# block text
		$scr += @"
	html+=	'<div class="form-group">'+
			'<label  class="col-sm-2 control-label" for="
"@
		#end block
		
		


		$scr+=$formid+'">'+$fgr[0]+":</label>'+"+$crlf


		# block text
		$scr+=@"
			'<div class="col-sm-10">'+
			'<label type="text" class="form-control" id="
"@		
		#end block

		$scr+=$formid+'"  name="'+$formid+'"'+"   >'+"+$fgr[1]+"+'<label/>'+"+$crlf
		$scr+="            '</div>'+"+$crlf
		$scr+="            '</div>';"+$crlf+$crlf+$crlf
		

	}
	
	$scr+=@"
	
    html+= '<input type="hidden"  id="
"@
	$scr+=$hiddenFormID+'" name="'	+ $hiddenFormID+'" value="'+"'+id+'"+'"/>'+"';"+$crlf+$crlf
   
    $scr+=@"
	editModtxt ='onclick="editModal('+

"@
   $i=0
   foreach($param in $formo.Params)
   {
		$i++
		if ($i -lt $formo.Params.Count)
		{
			$scr+='							"'+"'"+'"+'+$param+'+"'+"',"+'"+'+$crlf
   
		}
   
   }
   $scr+='							"'+"'"+'"+siteroot+"'+"')"+'";'+$crlf
   
   
   $scr+=@'

   html+=    '</div><div class="form-group">'+
        '<div class="col-sm-offset-2 col-sm-10">'+
        '<button  class="btn btn-info" '+
         editModtxt+
        ' ><span class="glyphicon glyphicon-pencil"'+
        '"></span>Редактировать</button>'+
        '<button type="submit" class="btn btn-danger"><span class="glyphicon glyphicon-trash"></span>Удалить</button>'+
        '</div><div>'+
        '</form>';
		
		
	$("#myModal .modal-header").html("<b>Просмотр: </b>")
    $("#myModal .modal-title").html("")
    $("#myModal .modal-body").html(html)
    $("myModal").modal();	
}   
'@
   return $scr
	
	
}
function get-hidden-formID($Form)
{
return "hidden-form-id-"+$Form.FormName
}

function get-JSName ($Name, $FormName)
{
	return $($Name+$FormName+".js")
}
function Open-Template($templateName)
{
    $templFileName  = "..\Template\" + $templateName + ".tmpl"
    $tmpl = ""
    if ($(Test-Path $templFileName))
    {
        $tmpl = Get-Content $templFileName -encoding UTF8
    }
    return $tmpl
}

function Render-Template($tmpl)
{
	$source = ""
	$crlf = [char][int]13+[char][int]10  
    $linenumb = 1	
	$isDebug = $true
	foreach ($line in $tmpl)
	{
        $lw = $line.Trim()
		if ($lw.Contains("@"))
		{
		   # it is a  comments nothing to do
		}
		elseif($lw.Contains("<<") -and $lw.Contains(">>") -and (!$lw.Contains("%")))
		{
		    #if (!$lw.Contains("%"))
			#{
				# source code ps script

				$ls = $line.Replace("<<","").Replace(">>","")
				$source+=$ls+$crlf
				
			#}
		}
		elseif(!($lw.Contains("<<") -and $lw.Contains(">>"))){
				if ($lw.Length -eq 0)
				{
					$source += '# '+ $linenumb+$crlf
				}
				else
				{
		
					$source += '		$script +='+"@'"+$crlf
					$source += $line+$crlf
					$source += "'@"+$crlf
					$source+='		$script +=$crlf;'+$crlf
					

				}
		}
		elseif ($lw.Length -gt 0)
		{
		    $currentline = "'"
			
			
			$delimtxt = ""
			
			$singledelim_beg = "'+"+'"'+"'"+'"'+"+'"
			$singledelim_end = "'+"+'"'+"'"+'"'+"+'"

			$isBegin = $false
			$ch = $line.Split()[0]
			# first char
			$s = $line.Replace("'",$singledelim_beg)
            $s = "'"+$s+"'"
			
			$source+='		$script +='+$s+'+$crlf'+$crlf
			
		
			
			#$currentline+=$delim
	
			
			#write-host $linenumb
			#write-host $currentline
			#read-host
			
		
			
		}
		
		
		$linenumb++
	}
   $source = $source.Replace("<<%%","'+")
   $source = $source.Replace("%%>>","+'")
   #$source = $source.Replace("<<%","")
   #$source = $source.Replace("%>>","")
   
   return $source
}

function get-FormFieldName ($field,$FormName)
{


   return $field+"-"+$FormName

}
function dbPassportTableNew($table)
{
	

	$dbpTable = "" | Select TableName,DisplayName, ViewIndex,ViewSelect, TableView, ViewFieldNames, ViewName,  Fields,FormName,FormType,FormFields;
	$dbpTable.TableName=$table.Name;
	$dbpTable.DisplayName = $table.DisplayName;
	$dbpTable.TableView = "id,"
	$dbpTable.Fields = @();
	$dbpTable.ViewSelect = "id,"
	# $dbpTable.Constraints = @();
	$dbpTable.FormName =  "";
	$dbpTable.ViewFieldNames = "";
	$dbpTable.Formtype = "simple";
	$dbpTable.FormFields = @()
	
	return $dbpTable;
	
}
function dbPassportFieldNew($field,$isConstr )
{
    $dbpfield = "" | select Name,Type,Lenght,DisplayName,isConstraint,Constraint
	
	$dbpfield.Name = $field.Name;
	$dbpfield.Type = $field.Type;
	if ($field.Type.toupper() -eq 'IMAGE')
	{
		$dbpfield.Lenght = 256
	}
	else
	{
		$dbpfield.Lenght = 50;
	}
	
	$dbpfield.isConstraint = $isConstr;
	$dbpfield.DisplayName = $field.DisplayName;
	$dbpfield.Constraint = dbPassportConstraintFieldNew
	
	
	
	return $dbpfield;
}
function dbPassportFormFieldNew($field,$isConstr )
{
   $dbpfield = "" | select Name,Type,Lenght,DisplayName,Required, isConstraint,Constraint
	
	$dbpfield.Name = $field.Name;
	$dbpfield.Type = $field.Type;

	$dbpfield.Lenght = 50;

	if (![string]::isNullOrEmpty($field.Type)){
		if ($dbpfield.Type.toupper() -eq 'IMAGE')
		{
			$dbpfield.Lenght = 256
		}
	}
	else
	{
		$dbpfield.Type = '$'
	}

	$dbpfield.isConstraint = $isConstr;
	$dbpfield.Required = $false
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
		$dpTable.FormName = $table.FormName
		if ($table.Fields.count -gt 6)
		{
			$dpTable.Formtype = "tabbed";
		}
		$dpTable.TableView = "id,"
		
		$fcnt = 1
		
		foreach($field in $table.Fields)
		{
		    $dbpField = dbPassportFieldNew $field $false;
			
			$dbpFormField = dbPassportFormFieldNew $field $false;
			$dpTable.Fields +=	$dbpField;
			$dpTable.FormFields += $dbpFormField
			$dpTable.TableView +=$field.Name
			$dpTable.ViewSelect +=$field.Name
			if ($fcnt -lt $table.Fields.Count)
			{
				$dpTable.TableView+=","
				$dpTable.ViewSelect +=","
			}
			$fcnt++
		}
		$fkc = 1 
		foreach($fk in $table.FKeys)
		{
			

			if ($fkc -eq 1)
			{
				$dpTable.TableView+=","
				$dpTable.ViewSelect +=","
			}
			#write-host $dpTable.Formtype
			#read-host
			if ($dpTable.Formtype -eq "simple")
			{
				$dpTable.Formtype = "onetab"
			}
		    #write-host "FK:"
	    	#	write-host $fk.Table
			#read-host
		    #if (![string]::IsNullOrEmpty($table.foreignkey.Table)){
			$dbpfield = "" | select Name,Type,Lenght,DisplayName,isConstraint,Constraint
			#$dbpField.Name = $fk.Table+"_id"
			$dbpField.Name = $fk.FieldName+"_id"
			# write-host 123456
			$dbpFormField = dbPassportFormFieldNew $dbpField.Name $false;
			

			$dpTable.TableView+=$dbpField.Name
			
			$dbpField.DisplayName = Get-TableDisplayName $dict $fk.Table
			$dbpfield.isConstraint = $true
			$dbpfield.Constraint = dbPassportConstraintFieldNew
			
			
			
			$dbpField.Constraint.ParentTable= $fk.Table
			$dbpField.Constraint.ParentField="id"
			
			
			# $dbpField.Constraint | gm
			
			$dbpField.Constraint.View =  get-ConstraintView $dict $fk.Table # "name" 
			
			$dbpField.Constraint.ViewField=get-viewFieldName $fk.FieldName
			# FieldName
			
			$dbpField.Constraint.ViewName=$fk.FieldName+$table.Name+ "_"+ $fk.Table+"_index"
			$dpTable.ViewSelect+=$dbpField.Name+","+$dbpField.Constraint.ViewField
			$proname = get-sqlProcName $fk.Table "name"
			#write-host $proname
			#read-host
			
			$dbpField.Constraint.SProcName=  $proname
			
			
			
			$dpTable.Fields +=	$dbpField;
			
			
			
			$dbpFormField.Name = $dbpfield.Name;


			$dbpFormField.Type = '$' # $dbpfield.Type;
	
			$dbpFormField.Lenght = 50 # $dbpfield.Lenght;
			$dbpFormField.isConstraint = $dbpfield.isConstraint;
			$dbpFormField.Required = $true
			$dbpFormField.DisplayName = $dbpField.DisplayName;
			$dbpFormField.Constraint = $dbpField.Constraint
			
				
			
			$dpTable.FormFields += $dbpFormField
			if ($fkc -lt $table.FKeys.Count)
			{
				$dpTable.TableView+=","
				$dpTable.ViewSelect+=","
			}
			$fkc++
			
			#}
		}
		# if ($dpTable.TableName -eq 'anketa')
			 # {
			 # write-host $dbpField.Name
				
			 # if ($dbpField.Name -eq 'Photo'){
			 # write-host FK:wasspouce Found!
			 # write-host $dpTable.Fields;
			
			 # read-host
			 # write-host ===============================
			 # write-host $dpTable.FormFields;
			 # read-host
			 # }
			 # }
		
		$dbPassport.Tables += $dpTable;
	    
	}
	
	#write-host 123
	
	$noret=dbPassportSaveObj  $dbPassport ""
	
	# write-host dbPassportSaveObj 
	# read-host 
	return $dbPassport;


}
function get-ConstraintView($dict, $tablName)
{
$ret  = "Name"
#$ret  = ""
foreach($table in $dict.Tables)
{
	if ($table.Name -eq $tablName)
	{
		foreach ($f in $table.Fields)
		{
			if ($f.Key -eq 1)
			{
				$ret=$f.Name
				return $ret;
				break;
			}
		}
	}
}

return $ret
}
function FormSaveObj($oForm,$dictName)
{
    #write-host $dictName
	$ojsonFileName =  "..\gen\"+$dictName+"\forms\json\"
	if (!(Test-Path -Path $ojsonFileName))
	{
		New-Item -ItemType Directory  -Force -Path $ojsonFileName | out-null
	}
	$ojsonFileName += $oform.Name
	#write-host $ojsonFileName
	#$ojsonFileName.InvocationInfo.PositionMessage
	$oForm |ConvertTo-Json -Depth 100 | out-file $($ojsonFileName+".json")| out-null

}
function GridSaveObj($oForm,$dictName)
{
    #write-host $dictName
	$ojsonFileName =  "..\gen\"+$dictName+"\grid\json\"
	if (!(Test-Path -Path $ojsonFileName))
	{
		New-Item -ItemType Directory  -Force -Path $ojsonFileName | out-null
	}
	$ojsonFileName += $oform.Name
	#write-host $ojsonFileName
	#$ojsonFileName.InvocationInfo.PositionMessage
	$oForm |ConvertTo-Json -Depth 100 | out-file $($ojsonFileName+".json")| out-null

}

function FormGetObj($dictName, $table)
{

$ojsonFileName =  "..\gen\"+$dictName+"\forms\json\"+$table+".json"
$ctx=get-content $ojsonFileName
$jsob = $ctx | ConvertFrom-Json
return $jsob
}
function gridGetObj($dictName, $table)
{
$ojsonFileName =  "..\gen\"+$dictName+"\grid\json\"+$table+".json"
$ctx=get-content $ojsonFileName
$jsob = $ctx | ConvertFrom-Json
return $jsob
}
function dbPassportSaveObj($dbPassport,$name="")
{
    
	$objxmlFileName =  "..\gen\"+$dbPassport.Name+"\dbPassport\"
	
	
	
	#write-host $objxmlFileName
	#write-host $name
	#get-pscallstack | select-object -property *
	#read-host

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
			

	# $dbPassport | Export-CliXML $($objxmlFileName+".xml")

	$dbPassport |ConvertTo-Json -Depth 100 | out-file $($objxmlFileName+".json")
}
function Get-TableDisplayName($d, $tName)
{
	$ret = ""
	foreach($table in $d.Tables)
	{
		 if ($table.Name -eq $tName)
		 {
			$ret=$table.DisplayName
			break;
		 }

	}
return $ret
}
function dbDictSave($dbDict)
{

	$objxmlFileName =  "..\gen\"+$dbDict.Name+"\dbPassport\"
	if (!(Test-Path -Path $objxmlFileName))
	{
		New-Item -ItemType Directory  -Force -Path $objxmlFileName
	}
	$objxmlFileName+=$dbDict.Name
	$dbDict |ConvertTo-Json -Depth 100 | out-file $($objxmlFileName+".json")
	
	
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


function dbPassportViewFieldNamesSet($dicName,$dbptableName,$ViewFieldNames)
{
	  $i=0;	
	  
	 
	  
	  $oDbp = dbPassportReadObj $dicName 
	  
	 
      foreach($table in $oDbp.Tables)
	  {
		if ($table.TableName -eq $dbptableName)
		{
			$oDbp.Tables[$i].ViewFieldNames = $ViewFieldNames ;
		
		}
		$i++
	  
	  }
	  #write-host 456
	  #read-host
	  dbPassportSaveObj $oDbp ""


}
function dbPassportSelectSet($dicName,$dbptableName,$select)
{
	  $i=0;	
	  
	 
	  
	  $oDbp = dbPassportReadObj $dicName 
	  
	 
      foreach($table in $oDbp.Tables)
	  {
		if ($table.TableName -eq $dbptableName)
		{
			$oDbp.Tables[$i].ViewIndex = $select ;
		
		}
		$i++
	  
	  }
	  #write-host 456
	  #read-host
	  dbPassportSaveObj $oDbp ""


}
function DbPassportProcNameSet($dicName,$dbptableparent,$dbptablechild,$nameProc)
{
	
	
	$fieldC = $dbptablechild.Name+"_id"
	
	$fieldP = $dbptableparent.Name+"_id"
	$Tablidx=0;	
	  
	#write-host we are here
	#read-host
	
	#write-host $("fieldP: "+ $fieldP)
	#write-host $("fieldC: "+ $fieldC)
	
	#lkfjwsol;k;slafk
	
	
	#write-host We are here 
	#read-host
	
	  
	$oDbp = dbPassportReadObj $dicName 
	
	
	#write-host $fieldP
	#write-host $nameProc
	#read-host
	
	foreach($table in $oDbp.Tables)
	{
		if ($table.TableName -eq $dbptablechild.Name)
		{
		    #write-host line 1633 table eq
			# write-host $dbptablechild.Name
			#read-host
		    $fieldidx = 0
		    foreach($field in $table.Fields)
			{
			    #write-host line 1639
				#write-host $field.Name
				#read-host
				
			    if ($field.Name -eq $fieldP){
					#write-host line 1656 field eq
					#write-host $fieldP
					#read-host
					if ($field.isConstraint)
					{
					
					#write-host 09876
					#read-host
						
						# $oDbp.Tables[$Tablidx].Fields[$fieldidx].Constraint.SProcName = $nameProc ;
						
					}
				}
				$fieldidx++
			}
			
		
		}
		$Tablidx++	
	}
	#write-host 789
	#read-host
	#dbPassportSaveObj $oDbp ""
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
			$oDbp.Tables[$i].ViewName = $view+"_index" ;
		
		}
		$i++
	  
	  }
	  
	  #write-host ABC
	  #read-host
	  dbPassportSaveObj $oDbp ""


}
function SaveUTF8($ctx,$fileName)
{
   $ctx | out-file  -filepath $fileName -encoding UTF8	
   $fi = get-item $fileName
   #$fi.Fullname
   #read-host
   $filectx = Get-Content $fi.Fullname
   $Utf8NoBom = New-Object System.Text.UTF8Encoding $false
   [System.IO.File]::WriteAllLines($fi.Fullname,$filectx,$Utf8NoBom)
   
   return $null

}
function xor {
    param($string, $method)
	$enc = [System.Text.Encoding]::UTF8
    $xorkey = $enc.GetBytes("secretkey")

    if ($method -eq "decrypt"){
        $string = $enc.GetString([System.Convert]::FromBase64String($string))
    }

    $byteString = $enc.GetBytes($string)
    $xordData = $(for ($i = 0; $i -lt $byteString.length; ) {
        for ($j = 0; $j -lt $xorkey.length; $j++) {
            $byteString[$i] -bxor $xorkey[$j]
            $i++
            if ($i -ge $byteString.Length) {
                $j = $xorkey.length
            }
        }
    })

    if ($method -eq "encrypt") {
        $xordData = [System.Convert]::ToBase64String($xordData)
    } else {
        $xordData = $enc.GetString($xordData)
    }
    
	
    return $xordData
}
function Convert-Base([string]$inp,[string]$method)
{
$sg = ""


if ($method.ToLower() -eq 'to'){
	
	$bytes = [System.Text.Encoding]::Unicode.GetBytes($inp)
	$sCrypted  = [System.Convert]::ToBase64String($bytes)
	$sg = $sCrypted
	
}
elseif ($method.ToLower() -eq 'from'){

	$sDecrypted = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($inp))
	$sg = $sDecrypted
}


return $sg
}
function dbccCheck($dict)
{
	$checked = $true
    $tables = @()
	$tablesDuplicate = @()
	
	
	foreach($table in $dict.Tables)
	{
		$tables +=  $table.Name
	}
	
	$countTble = 0
	forEach($t in $tables)
	{
		$countTble = 0
		foreach($table in $dict.Tables)
		{

			if ($t -eq $table.Name)
			{
				$countTble++
			}
		}
		
		IF ($countTble -gt 1)
		{
			$tablesDuplicate +=$t
			
			
		}
	}
	
	$tablesDuplicate = $tablesDuplicate | select -uniq
	if ($tablesDuplicate.Count -gt 0)
	{
		write-host "Duplicate table names detected:"
		$checked = $false
		foreach($t  in $tablesDuplicate)
		{
			write-host $t
		}
	}
	
	return $checked
}
function CheckConstraint($odbP)
{
	$checked = $true
	$parentTables = @()
	$badparent = @() 
	
	foreach($table in $odbP.Tables)
	{
		foreach($f in $table.Fields)
		{
			if ($f.isConstraint)
			{
				$parentTables +=$f.Constraint.ParentTable
			}
		}
	}
	
	$parentTables = $parentTables | select -uniq
	
	foreach($pt in $parentTables)
	{
		$pfound = $false
		foreach($table in $odbP.Tables){
			if ($table.TableName.tolower() -eq $pt.tolower())
			{
				$pfound = $true
				break
			}
		}
		if (!$pfound) # not parent
		{
			$badparent+=$pt
		}
	}
	if ($badparent.Count -gt 0)
	{
		write-host "Foreign Key exists But Parent Table not Found"
		foreach($t in $badparent)
		{
			write-host $t
		}
		$checked = $false
	
	}
	return $checked
}
function isTypeImageInForm($form)
{

$isImage = $false

	foreach($tab in $form.tabs)
	{
		foreach($field in $tab.Fields)
		{
			$json = $field.json |ConvertFrom-Json
			if ($json.Type.ToUpper() -eq 'IMAGE')
			{
				$isImage = $true
				return $isImage
			}
		}
	}
return $isImage
}	

####################################
function isTypeImageInPTable($Ptable)
{

$isImage = $false

	
		foreach($field in $Ptable.Fields)
		{
			# if ([String]::IsNullOrEmpty($field.Type))
			# {
			# write-host $("Ptable Name "+$Ptable.Name)
			# write-host $("Ptable TableName "+$Ptable.TableName)
			# read-host
			# }
			if (!$field.isConstraint){
				if ($field.Type.ToUpper() -eq 'IMAGE')
				{
					$isImage = $true
					return $isImage
				}
			}
		}
	
return $isImage
}	

####################################

function ImageFields($form)
{

$fields =@()

	foreach($tab in $form.tabs)
	{
		foreach($field in $tab.Fields)
		{
			$json = $field.json |ConvertFrom-Json
			if ($json.Type.ToUpper() -eq 'IMAGE')
			{
				$fields += $json.Name
				
			}
		}
	}
	return $fields
}	






"# Powershell-and-PHP-Site-AutoCreation" 
HI!
Any PHP programmer who was written more than one database application quickly comes to the realization that certain aspect of the programm are common to almost all system. No matter how enthusiastic the programmer, some aspect of coding can become tedious and time-consuming.

Project designed to free PHP MVC programmer from the tedious It let's a programmer concentrate on the creative aspect of application development, like screen design and data model. Once the design is complete you choose a template that tells what type of programn to generate and then sit back and watch as it generates hundred of lines of code in seconds.

Project contains data dictionary, programm templates, template language, and generator engine.

To create a project you first create data dictionary. Then you generate SQL script according this data dictionary, screen forms according on tables in data dictionary, grid forms.

You can change order, names of fields in forms in grid, delete some fields.

Project generates php mvc code including model, controller, HTML view, however you can change type of output files as you wish.
Generation engine will run in Windows environment.

1-2-3-...    SITE READY


Asher Sandler
Asher Sandler
As Ole Hadash, I'm looking for a job at position…
OleHadash
Bauman Moscow State Technical University
Просмотреть профиль
LinkedIn

1. Data Dictionary
Data dictionary is a text file with a name of Database and SQL script. For example our file name is GOODS.dict (.dict is a extension of text file). So name of genereted SQL will be GOODS.sql.

; goods.dict 
; data dictionary for DB goods	
	
t:country:Country:CTR001
f:Name:$:Country Name

end:
;================================

t:manufactur:Manufacture:MFR001
f:Name:$:Manuf. Name
fk:country

end:


;================================
t:goods:Goods:GDS001

f:name:$:Good Name
f:photo:Image:Good Photo  
fk:manufactur
f:price:$5:Price
f:onstock:$5:Count on Stock
  

end:

		
Inside a data dictionary text the are descriptions of DB tables. In our example three db tables - country, manufactur, goods.

Table country.  Description : Country, unique internal name for form fields : CTR001

Field "Name" , Label: Country

Table manufactur.  Description : Manufacture, unique internal name for form fields : MFR001

Field "Name" , Label: Manuf. Name, Type Text

Foreing Key country, Label: Manuf. Name

Table goods.  Description : Goods, unique internal name for form fields : GDS001

Field "name" , Label: Good Name, Type Text

Field "photo" , Label: Good Photo , Type Image

Foreing Key manufactur

Field "price" , Label: Good Name, Type Text

Field "onstock" , Label: Count on Stock , Type Text

Running PowerShell generation engine....

PS C:\ui\Script> .\main.ps1 -DictionaryName goods.dict
Reading dictionary              : goods.dict


Writing SQL                     :..\gen\GOODS.sql

Render model.ps1        :..\gen\GOODS\render\country-model.ps1
Render pdo.ps1        :..\gen\GOODS\render\country-pdo.ps1
Render controller.ps1        :..\gen\GOODS\render\country-controller.ps1
Render index.html        :..\gen\GOODS\render\country-index.ps1
Render update.html        :..\gen\GOODS\render\country-update.ps1
Render confirmdel.html        :..\gen\GOODS\render\country-confirmdel.ps1
Render delete.html        :..\gen\GOODS\render\country-delete.ps1
Render add.html        :..\gen\GOODS\render\country-add.ps1
Render show.html        :..\gen\GOODS\render\country-show.ps1
Render edit.html        :..\gen\GOODS\render\country-edit.ps1
Render edit-shpr.html        :..\gen\GOODS\render\country-edit-shpr.ps1
Render model.ps1        :..\gen\GOODS\render\manufactur-model.ps1
Render pdo.ps1        :..\gen\GOODS\render\manufactur-pdo.ps1
Render controller.ps1        :..\gen\GOODS\render\manufactur-controller.ps1
Render index.html        :..\gen\GOODS\render\manufactur-index.ps1
Render update.html        :..\gen\GOODS\render\manufactur-update.ps1
Render confirmdel.html        :..\gen\GOODS\render\manufactur-confirmdel.ps1
Render delete.html        :..\gen\GOODS\render\manufactur-delete.ps1
Render add.html        :..\gen\GOODS\render\manufactur-add.ps1
Render show.html        :..\gen\GOODS\render\manufactur-show.ps1
Render edit.html        :..\gen\GOODS\render\manufactur-edit.ps1
Render edit-shpr.html        :..\gen\GOODS\render\manufactur-edit-shpr.ps1
Render model.ps1        :..\gen\GOODS\render\goods-model.ps1
Render pdo.ps1        :..\gen\GOODS\render\goods-pdo.ps1
Render controller.ps1        :..\gen\GOODS\render\goods-controller.ps1
Render index.html        :..\gen\GOODS\render\goods-index.ps1
Render update.html        :..\gen\GOODS\render\goods-update.ps1
Render confirmdel.html        :..\gen\GOODS\render\goods-confirmdel.ps1
Render delete.html        :..\gen\GOODS\render\goods-delete.ps1
Render add.html        :..\gen\GOODS\render\goods-add.ps1
Render show.html        :..\gen\GOODS\render\goods-show.ps1
Render edit.html        :..\gen\GOODS\render\goods-edit.ps1
Render edit-shpr.html        :..\gen\GOODS\render\goods-edit-shpr.ps1
Render menu.html        :..\gen\GOODS\render\menu-menu.ps1

		
was generated GOODS.sql:

CREATE DATABASE  IF NOT EXISTS `GOODS`;
USE `GOODS`;

DROP TABLE IF EXISTS `country`;
CREATE TABLE `country` (
   `Name` varchar(50) NOT NULL COMMENT 'Country name',
   `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
     PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS country_index;
CREATE VIEW country_index AS
SELECT id,Name FROM country;



DROP TABLE IF EXISTS `manufactur`;
CREATE TABLE `manufactur` (
   `Name` varchar(50) NOT NULL COMMENT 'Manuf. name',
   `country_id` int(10) UNSIGNED NOT NULL,
   FOREIGN KEY(country_id) REFERENCES country(id),
   `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
     PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS manufactur_index;
CREATE VIEW manufactur_index AS
SELECT id,Name,
(SELECT name FROM `country` WHERE country.id=manufactur.country_id) as country_name,country_id
 FROM manufactur;

/*
* Generated by: get-SQLview
* 06.01.2019 21:15
*/
DROP VIEW IF EXISTS countrymanufactur_country;

CREATE VIEW countrymanufactur_country AS 
SELECT 
Tparent.id AS country_id, Tparent.Name AS country_Name 
FROM `manufactur` Tchild 
INNER JOIN `country` Tparent 
ON country_id=Tparent.id;

/*-------   ---    ------*/
DROP VIEW IF EXISTS countrymanufactur_country_index;

CREATE VIEW countrymanufactur_country_index AS 
SELECT id,Name,(SELECT name FROM `country` WHERE country.id=manufactur.country_id) as country_name FROM `manufactur`;

/*
* Generated by: get-SQLview
* END:
*/



/*
* Generated by: get-SQLproc
* 06.01.2019 21:15
*/
DROP PROCEDURE if exists `getCountryName`;

DELIMITER $$
CREATE PROCEDURE `getCountryName`
(IN `idParam` INT(10))
begin
select name from country where country.id=idParam;
end
$$DELIMITER ;
/*
* Generated by: get-SQLproc()
* END:
*/



DROP TABLE IF EXISTS `goods`;
CREATE TABLE `goods` (
   `name` varchar(50) NOT NULL COMMENT 'Good name',
   `photo` MEDIUMTEXT NOT NULL COMMENT 'Good photo',
   `price` varchar(5) NOT NULL COMMENT 'Price',
   `onstock` varchar(5) NOT NULL COMMENT 'Count on stock',
   `manufactur_id` int(10) UNSIGNED NOT NULL,
   FOREIGN KEY(manufactur_id) REFERENCES manufactur(id),
   `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
     PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;


DROP VIEW IF EXISTS goods_index;
CREATE VIEW goods_index AS
SELECT id,name,photo,price,onstock,
(SELECT name FROM `manufactur` WHERE manufactur.id=goods.manufactur_id) as manufactur_name,manufactur_id
 FROM goods;

/*
* Generated by: get-SQLview
* 06.01.2019 21:15
*/
DROP VIEW IF EXISTS manufacturgoods_manufactur;

CREATE VIEW manufacturgoods_manufactur AS 
SELECT 
Tparent.id AS manufactur_id, Tparent.Name AS manufactur_Name 
FROM `goods` Tchild 
INNER JOIN `manufactur` Tparent 
ON manufactur_id=Tparent.id;

/*-------   ---    ------*/
DROP VIEW IF EXISTS manufacturgoods_manufactur_index;

CREATE VIEW manufacturgoods_manufactur_index AS 
SELECT id,name, photo, price, onstock,(SELECT name FROM `manufactur` WHERE manufactur.id=goods.manufactur_id) as manufactur_name FROM `goods`;

/*
* Generated by: get-SQLview
* END:
*/



/*
* Generated by: get-SQLproc
* 06.01.2019 21:15
*/
DROP PROCEDURE if exists `getManufacturName`;

DELIMITER $$
CREATE PROCEDURE `getManufacturName`
(IN `idParam` INT(10))
begin
select name from manufactur where manufactur.id=idParam;
end
$$DELIMITER ;
/*
* Generated by: get-SQLproc()
* END:
*/
		
and hierarchy of Model-View-Controller files:

├───config
│       menu.php
│
├───controllers
│       country.controller.php
│       goods.controller.php
│       manufactur.controller.php
│
├───models
│       country.php
│       goods.php
│       manufactur.php
│
└───views
    ├───country
    │       add.html
    │       confirmdel.html
    │       delete.html
    │       edit.html
    │       index.html
    │       show.html
    │       update.html
    │
    ├───goods
    │       add.html
    │       confirmdel.html
    │       delete.html
    │       edit.html
    │       index.html
    │       show.html
    │       update.html
    │
    └───manufactur
            add.html
            confirmdel.html
            delete.html
            edit.html
            index.html
            show.html
            update.html
		
Example of Model

<?php
//
// Generated 01.01.2019 22:01
// Template name "model.TMPL"
//
class Country extends model
{
    public function getList($value = null)
    {
       $sql = "select id,Name from country_index";
       return $this->db->query($sql);
    }
	...
	...
	...
	...
		
Example of View

<h1 class="text-center text-capitalize">Country:Edit</h1>
<div class="col-m-1 ">
    <ul class="nav nav-tabs nav-justified " id="myTab" role="tablist" >
			<li class="nav-item nav-link tabbed-1" >
				<a href="#tab-id-1" data-toggle="tab">Country</a>
			</li>
	</ul>
   <form class="needs-validation " novalidate action="/<?=Config::get("site_root")?>country" method="post" enctype="multipart/form-data">
	...		
	...		
	...		
	...		
		
Example of Controller

<?php
//
// Generated 01.01.2019 22:01
// Template name "controller.TMPL"
// 
class CountryController extends Controller
{
    public function __construct($data=array())
    {
       parent::__construct();
       $this->model = new Country();
    }
    public function index(){
		$this->data['country'] = $this->model->getList();
	}
	public function update()
	{
		$tableName = 'country';
	...		
	...		
	...		
	...		
		
Voilà ... Site READY

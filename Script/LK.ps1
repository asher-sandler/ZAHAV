# 
# .\main.ps1 -DictionaryName LK.dict

.\PS-gen.ps1 -DictName LK -TemplateName JS1
.\PS-gen.ps1 -DictName LK -TemplateName tabbedform
cd ..\Gen\LK\
 .\gen-js.ps1 -FormName anketa-LK001.wnf


# only if we have tabbed forms in directory ui\tabbedforms
# .\gen-tabbed.ps1 -FormName anketa-LK001.wnf

cd ..\..\script


Import-Module WebAdministration

# Script to delete all stopped sites, folders and application pools

$Websites = Get-ChildItem IIS:\Sites | Where-Object {$_.state -eq “Stopped”} 
foreach ($Site in $Websites) {
  Write-Host("Working with IIS Site: {0}" -f $Site.name)

  if(Test-Path $Site.physicalPath)
  {
    Write-Host("Deleting {0}" -f $Site.physicalPath)
    Remove-Item $Site.PhysicalPath -Force -Recurse
  }
  else
  {
    Write-Host("Site physical path ({0}) does not exist" -f $Site.physicalPath)
  }
}
$AppNames = ($Websites).name
foreach($appName in $AppNames)
    {
        #Remove Site
        if (Test-Path IIS:\Sites\$appName -PathType Container)
            {
                Write-Host("Deleting IIS Site: {0}" -f $appName)
                Remove-Item IIS:\Sites\$appName -Force -Recurse
            }
        if (Test-Path IIS:\AppPools\$appName -PathType Container)
            {
                Write-Host("Deleting IIS Pool: {0}" -f $appName)
                Remove-Item IIS:\AppPools\$appName -Force -Recurse
            }
    }

   
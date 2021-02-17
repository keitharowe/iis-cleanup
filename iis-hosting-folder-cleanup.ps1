Import-Module WebAdministration

# Script to delete any ophaned folders assuming a "root" directory that all sites would start from.
# any folders found in the "root" that do not have a cooresponding site, application, or virtual directory in IIS will be deleted
# this initial version only outputs the folders to be deleted

$rootPath = "e:\www"
$WebsiteFolders = Get-ChildItem -Path $rootPath -Directory 
$Websites = Get-ChildItem IIS:\Sites
[bool] $found = $false

foreach ($Folder in $WebsiteFolders) {
    $writeFolder = $Folder.FullName
    Write-Host("Working with folder: {0}" -f $writeFolder) 
    if(Test-Path $Folder.FullName)
    {
    [String] $comparePath = ("{0}*" -f $Folder.FullName)
    $SearchWebsites = $Websites | Where-Object { (($_.PhysicalPath -like $comparePath))} 
    
    if ($SearchWebsites.length -eq 0) {
        $found = $false;
        foreach($site in $Websites | Sort-Object Name )
        {
            $SearchVirtDir = Get-WebVirtualDirectory -Site $Site.name | Where-Object { (($_.PhysicalPath -like $comparePath))}   
            if($searchVirtDir.length -gt 0)
            {
                $found = $true;
            }
            
            if($found)
            {
                break;
            }
            $SearchAppDir = Get-WebApplication -Site $Site.name | Where-Object { (($_.PhysicalPath -like $comparePath))}   
            if($SearchAppDir.length -gt 0)
            {
                $found = $true;
            }
            
            if($found)
            {
                break;
            }
        }
        if($found -eq $false)
        {
            Write-Host ">>>>> $writeFolder not found in IIS. Marked for deletion" -ForegroundColor yellow
        }
    }
  }
  else
  {
    Write-Host("Physical path ({0}) does not exist" -f $Folder.FullName) -ForegroundColor red
  }
}

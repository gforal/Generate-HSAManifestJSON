<#
    Author: Graham Foral
    Date:   2/6/2023


    Purpose:    Have you ever wanted to use Install-HSA.ps1 from Lenovo on HP and Dell UWP packs? Sure, we all have! With this script, you can generate HSA Manifests like Lenovo does. Just make sure the directory structure is one level deep. 
                The folder name is the name of the hsa entry.

    Usage:     Place this ps1 in the directory containing the UWP folders, then run in. It will place the manifest inside each directory.

    UWP Packs: Get the Client Management Library from : https://www.hp.com/us-en/solutions/client-management-solutions/download.html. Then you can run this (Eample for Elitebook 845 G8)... 
               
               Get-SoftpaqList -Platform 8895 -Os win11 -OsVer 22h2 -Download -Verbose -Characteristic UWP -Category "Manageability - UWP Pack"

#>


$HSAFolders = Get-ChildItem -Directory

ForEach($HSAFolder in $HSAFolders) {
    $License = Get-ChildItem -Path $HSAFolder -Filter *License*.xml
    $HSA = $HSAFolder.Name
    $Appx = Get-ChildItem -Path $HSAFolder | Where-Object {(( $_.Extension -like "*appx*") -or ( $_.Extension -like "*msix*")) -and ($_.BaseName -notlike "*microsoft*") }
    $Dependencies = Get-ChildItem -Path $HSAFolder | Where-Object {($_.BaseName -like "*microsoft*")}
    

    $JSONHash = @{  license = $License.Name; 
                    hsa = $HSA; 
                    appx = $Appx.Name;
                    dependencies = "" 
                    
                 }

    $JSONHash.dependencies = @()
    
    ForEach($Depend in $Dependencies) {
        $JSONHash.dependencies += $Depend.ToString()
    }   
    
    $FileName = $HSA + "_hsa_manifest.json"
    Write-Output "Generating: " (Join-Path $HSAFolder.FullName -ChildPath $FileName)
    $JSONHash | ConvertTo-Json | Out-File -FilePath (Join-Path $HSAFolder.FullName -ChildPath $FileName)

}
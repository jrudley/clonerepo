param (
[string]$locationToDeploy,
[string]$SitecoreLoginAdminPassword,
[string]$SqlServerLoginAdminAccount,
[string]$SqlServerLoginAdminPassword,
[string]$azureSubscriptionName,
[string]$tenantId,
[string]$applicationId,
[string]$applicationPassword
)


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
New-Item -Path c:\temp -ItemType Directory
invoke-restmethod -uri 'https://www.7-zip.org/a/7z1900-x64.msi' -outfile 'c:\temp\7zip.msi'
invoke-restmethod -uri 'https://github.com/git-for-windows/git/releases/download/v2.22.0.windows.1/Git-2.22.0-64-bit.exe' -OutFile c:\temp\git.exe
invoke-restmethod -uri 'https://download.microsoft.com/download/5/E/4/5E4FCC45-4D26-4CBE-8E2D-79DB86A85F09/EN/x64/DacFramework.msi' -outfile c:\temp\DacFramework2016-x64.msi
invoke-restmethod -uri 'https://download.microsoft.com/download/5/E/4/5E4FCC45-4D26-4CBE-8E2D-79DB86A85F09/EN/x86/DacFramework.msi' -outfile c:\temp\DacFramework2016-x86.msi

Start-Process -FilePath "msiexec" -ArgumentList "/i c:\temp\7zip.msi /quiet /norestart" -Wait

$msbuild = "C:\temp\git.exe"
$arguments = '/silent /suppressmsgboxes /log="c:\temp\gitinstall.log"'
start-process $msbuild $arguments 

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

New-Item c:\projects -ItemType directory
Set-Location c:\projects
git config --system core.longpaths true
git clone https://github.com/jrudley/Sitecore.HabitatHome.Platform.git



Start-Process msiexec.exe -NoNewWindow -Wait -ArgumentList "/i c:\temp\DacFramework2016-x86.msi /quiet /qn /norestart /L*V c:\temp\dac86.log" 
Start-Process msiexec.exe -NoNewWindow -Wait -ArgumentList "/i c:\temp\DacFramework2016-x64.msi /quiet /qn /norestart /L*V c:\temp\dac64.log"



$cakeconfig = get-content C:\projects\Sitecore.HabitatHome.Platform\cake-config.json | convertfrom-json

$cakeconfig.Topology = 'scaled'
$cakeconfig.DeploymentTarget = 'Azure'

$cakeconfig | convertto-json | out-file C:\projects\Sitecore.HabitatHome.Platform\cake-config.json -Force

Copy-Item -Path 'C:\projects\Sitecore.HabitatHome.Platform\Azure\XP\ARM Templates\HabitatHome\xconnect.json' -Destination 'C:\projects\Sitecore.HabitatHome.Platform\Azure\XP\ARM Templates\HabitatHome\habitatHome_xConnect.json' -Force 
Copy-Item -Path 'C:\projects\Sitecore.HabitatHome.Platform\Azure\XP\azureuser-config.json.example' -Destination 'C:\projects\Sitecore.HabitatHome.Platform\Azure\XP\azureuser-config.json'

$azureuser = get-content 'C:\projects\Sitecore.HabitatHome.Platform\Azure\XP\azureuser-config.json' | Convertfrom-Json
$azureuser.serviceprincipal.azureSubscriptionName=$azureSubscriptionName
$azureuser.serviceprincipal.tenantId=$tenantId
$azureuser.serviceprincipal.applicationId=$applicationId
$azureuser.serviceprincipal.applicationPassword=$applicationPassword
$azureuser.settings | % {if($_.id -eq 'AzureDeploymentID'){$_.value="schabitat$(get-random -Maximum 10000)"}}
$azureuser.settings | % {if($_.id -eq 'AzureRegion'){$_.value=$locationToDeploy}}
$azureuser.settings | % {if($_.id -eq 'SitecoreLoginAdminPassword'){$_.value=$SitecoreLoginAdminPassword}}
$azureuser.settings | % {if($_.id -eq 'SqlServerLoginAdminAccount'){$_.value=$SqlServerLoginAdminAccount}}
$azureuser.settings | % {if($_.id -eq 'SqlServerLoginAdminPassword'){$_.value=$SqlServerLoginAdminPassword}}
$azureuser.settings | % {if($_.id -eq 'SitecoreLicenseXMLPath'){$_.value='c:\projects\license.xml'}}

$azureuser | convertto-json | out-file 'C:\projects\Sitecore.HabitatHome.Platform\Azure\XP\azureuser-config.json' -Force

New-Item C:\projects\COPY_SITECORE_LICENSE_FILE_HERE.txt 

Restart-computer -force

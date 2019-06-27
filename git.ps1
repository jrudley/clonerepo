param (
[string]$locationToDeploy,
[string]$SitecoreLoginAdminPassword,
[string]$SqlServerLoginAdminAccount,
[string]$SqlServerLoginAdminPassword
)


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
New-Item -Path c:\temp -ItemType Directory
invoke-restmethod -uri 'https://www.7-zip.org/a/7z1900-x64.msi' -outfile 'c:\temp\7zip.msi'
invoke-restmethod -uri 'https://github.com/git-for-windows/git/releases/download/v2.22.0.windows.1/Git-2.22.0-64-bit.exe' -OutFile c:\temp\git.exe

Start-Process -FilePath "msiexec" -ArgumentList "/i c:\temp\7zip.msi /quiet /norestart" -Wait

$msbuild = "C:\temp\git.exe"
$arguments = '/silent /suppressmsgboxes /NORESTART /log="c:\temp\gitinstall.log"'
start-process $msbuild $arguments -wait

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

New-Item c:\projects -ItemType directory
Set-Location c:\projects
git config --system core.longpaths true
git clone https://github.com/jrudley/Sitecore.HabitatHome.Platform.git



$dac64 = "https://download.microsoft.com/download/5/E/4/5E4FCC45-4D26-4CBE-8E2D-79DB86A85F09/EN/x64/DacFramework.msi"
$dac86 = "https://download.microsoft.com/download/5/E/4/5E4FCC45-4D26-4CBE-8E2D-79DB86A85F09/EN/x86/DacFramework.msi"

            Write-Verbose "Downloading DACFx x64 from $dac64..."
            Invoke-WebRequest -Uri $dac64 -OutFile c:\temp\DacFramework2016-x64.msi -Verbose:$VerbosePreference
            Write-Verbose "Download of DACFx x64 successful."
            Write-Verbose "Installing DACFx x64..."
            Start-Process msiexec.exe -NoNewWindow -Wait -ArgumentList "/i c:\temp\DacFramework2016-x64.msi /quiet /qn /norestart"
            Write-Verbose "Installation of DACFx x64 successful."

            Write-Verbose "Downloading DACFx x86 from $dac86..."
            Invoke-WebRequest -Uri $dac86 -OutFile c:\temp\DacFramework2016-x86.msi -Verbose:$VerbosePreference
            Write-Verbose "Download of DACFx x86 successful."
            Write-Verbose "Installing DACFx x86..."
            Start-Process msiexec.exe -NoNewWindow -Wait -ArgumentList "/i c:\tempDacFramework2016-x86.msi /quiet /qn /norestart"
            Write-Verbose "Installation of DACFx x86 successful."


$cakeconfig = get-content C:\projects\Sitecore.HabitatHome.Platform\cake-config.json | convertfrom-json

$cakeconfig.Topology = 'scaled'
$cakeconfig.DeploymentTarget = 'Azure'

$cakeconfig | convertto-json | out-file C:\projects\Sitecore.HabitatHome.Platform\cake-config.json -Force

Copy-Item -Path 'C:\projects\Sitecore.HabitatHome.Platform\Azure\XP\ARM Templates\HabitatHome\xconnect.json' -Destination 'C:\projects\Sitecore.HabitatHome.Platform\Azure\XP\ARM Templates\HabitatHome\habitatHome_xConnect.json' -Force 
Copy-Item -Path 'C:\projects\Sitecore.HabitatHome.Platform\Azure\XP\azureuser-config.json.example' -Destination 'C:\projects\Sitecore.HabitatHome.Platform\Azure\XP\azureuser-config.json'

$azureuser = get-content 'C:\projects\Sitecore.HabitatHome.Platform\Azure\XP\azureuser-config.json' | Convertfrom-Json

$azureuser.settings | % {if($_.id -eq 'AzureDeploymentID'){$_.value="schabitat$(get-random -Maximum 10000)"}}
$azureuser.settings | % {if($_.id -eq 'AzureRegion'){$_.value=$locationToDeploy}}
$azureuser.settings | % {if($_.id -eq 'SitecoreLoginAdminPassword'){$_.value=$SitecoreLoginAdminPassword}}
$azureuser.settings | % {if($_.id -eq 'SqlServerLoginAdminAccount'){$_.value=$SqlServerLoginAdminAccount}}
$azureuser.settings | % {if($_.id -eq 'SqlServerLoginAdminPassword'){$_.value=$SqlServerLoginAdminPassword}}
$azureuser.settings | % {if($_.id -eq 'SitecoreLicenseXMLPath'){$_.value='c:\\projects\\license.xml'}}

$azureuser | convertto-json | out-file 'C:\projects\Sitecore.HabitatHome.Platform\Azure\XP\azureuser-config.json' -Force

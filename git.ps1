[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
New-Item -Path c:\temp -ItemType Directory
invoke-restmethod -uri 'https://github.com/git-for-windows/git/releases/download/v2.22.0.windows.1/Git-2.22.0-64-bit.exe' -OutFile c:\temp\git.exe

$msbuild = "C:\temp\git.exe"
$arguments = '/silent /suppressmsgboxes /log="c:\temp\gitinstall.log"'
start-process $msbuild $arguments 

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

New-Item c:\projects -ItemType directory
Set-Location c:\projects
git config --system core.longpaths true
git clone https://github.com/Sitecore/Sitecore.HabitatHome.Platform.git



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





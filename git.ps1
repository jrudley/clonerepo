[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
New-Item -Path c:\temp -ItemType Directory
invoke-restmethod -uri 'https://github.com/git-for-windows/git/releases/download/v2.22.0.windows.1/Git-2.22.0-64-bit.exe' -OutFile c:\temp\git.exe

$msbuild = "C:\temp\git.exe"
$arguments = '/silent /suppressmsgboxes /log="c:\temp\gitinstall.log"'
start-process $msbuild $arguments 

New-Item c:\projects -ItemType directory
Set-Location c:\projects
git config --system core.longpaths true
git clone https://github.com/Sitecore/Sitecore.HabitatHome.Platform.git





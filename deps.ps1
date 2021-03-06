# Check to see if we are currently running "as Administrator"
if (!(Verify-Elevated)) {
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   $newProcess.Verb = "runas";
   [System.Diagnostics.Process]::Start($newProcess);

   exit
}


### Update Help for Modules
Write-Host "Updating Help..." -ForegroundColor "Yellow"
Update-Help -Force


### Package Providers
Write-Host "Installing Package Providers..." -ForegroundColor "Yellow"
Get-PackageProvider NuGet -Force | Out-Null
# Chocolatey Provider is not ready yet. Use normal Chocolatey
#Get-PackageProvider Chocolatey -Force
#Set-PackageSource -Name chocolatey -Trusted


### Install PowerShell Modules
Write-Host "Installing PowerShell Modules..." -ForegroundColor "Yellow"
Install-Module Posh-Git -Scope CurrentUser -Force
Install-Module PSWindowsUpdate -Scope CurrentUser -Force


### Chocolatey
Write-Host "Installing Desktop Utilities..." -ForegroundColor "Yellow"
if ((which cinst) -eq $null) {
    iex (new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1')
    Refresh-Environment
    choco feature enable -n=allowGlobalConfirmation
}
choco install chocolatey-core.extension
choco install chocolateygui       --limit-output

# system and cli
choco install curl                --limit-output
choco install nuget.commandline   --limit-output
choco install webpi               --limit-output
choco install git.install         --limit-output -params '"/GitAndUnixToolsOnPath /NoShellIntegration"'
choco install git-lfs             --limit-output
choco install nvm.portable        --limit-output
choco install python              --limit-output
choco install pip                 --limit-output
choco install ruby                --limit-output
choco install golang              --limit-output
choco install jre8                --limit-output
choco install jdk8                --limit-output

#fonts
choco install sourcecodepro       --limit-output

# browsers
choco install GoogleChrome        --limit-output; <# pin; evergreen #> choco pin add --name GoogleChrome        --limit-output
choco install Firefox             --limit-output; <# pin; evergreen #> choco pin add --name Firefox             --limit-output
choco install Opera               --limit-output; <# pin; evergreen #> choco pin add --name Opera               --limit-output
choco install adobereader         --limit-output

# dev tools and frameworks
choco install vscode              --limit-output; <# pin; evergreen #> choco pin add --name VScode              --limit-output
choco install atom                --limit-output; <# pin; evergreen #> choco pin add --name Atom                --limit-output
choco install sourcetree          --limit-output
choco install hyper               --limit-output; <# pin; evergreen #> choco pin add --name Hyper               --limit-output
choco install postman             --limit-output
choco install awscli              --limit-output
choco install winmerge            --limit-output
choco install ccleaner            --limit-output
choco install treesizefree        --limit-output
choco install wox                 --limit-output
choco install autohotkey.install  --limit-output
choco install autodesk-fusion360  --limit-output

# communication
choco install slack               --limit-output; <# pin; evergreen #> choco pin add --name Slack               --limit-output
choco install telegram            --limit-output
choco install zoom                --limit-output

# games
choco install steam               --limit-output; <# pin; evergreen #> choco pin add --name Steam               --limit-output
choco install geforce-experience  --limit-output

# media
choco install spotify             --limit-output; <# pin; evergreen #> choco pin add --name Spotify             --limit-output
choco install vlc                 --limit-output
choco install calibre             --limit-output
choco install foxitreader         --limit-output
choco install youtube-dl          --limit-output
choco install ffmpeg              --limit-output
choco install audacity            --limit-output
   
# storage
choco install dropbox             --limit-output
choco install googledrive         --limit-output
choco install rufus               --limit-output

Refresh-Environment

nvm on
$nodeLtsVersion = choco search nodejs-lts --limit-output | ConvertFrom-String -TemplateContent "{Name:package-name}\|{Version:1.11.1}" | Select -ExpandProperty "Version"
nvm install $nodeLtsVersion
nvm use $nodeLtsVersion
Remove-Variable nodeLtsVersion

gem pristine --all --env-shebang

### Windows Features
Write-Host "Installing Windows Features..." -ForegroundColor "Yellow"
# IIS Base Configuration
Enable-WindowsOptionalFeature -Online -All -FeatureName `
    "IIS-BasicAuthentication", `
    "IIS-DefaultDocument", `
    "IIS-DirectoryBrowsing", `
    "IIS-HttpCompressionDynamic", `
    "IIS-HttpCompressionStatic", `
    "IIS-HttpErrors", `
    "IIS-HttpLogging", `
    "IIS-ISAPIExtensions", `
    "IIS-ISAPIFilter", `
    "IIS-ManagementConsole", `
    "IIS-RequestFiltering", `
    "IIS-StaticContent", `
    "IIS-WebSockets", `
    "IIS-WindowsAuthentication" `
    -NoRestart | Out-Null

# ASP.NET Base Configuration
Enable-WindowsOptionalFeature -Online -All -FeatureName `
    "NetFx3", `
    "NetFx4-AdvSrvs", `
    "NetFx4Extended-ASPNET45", `
    "IIS-NetFxExtensibility", `
    "IIS-NetFxExtensibility45", `
    "IIS-ASPNET", `
    "IIS-ASPNET45" `
    -NoRestart | Out-Null

# Web Platform Installer for remaining Windows features
webpicmd /Install /AcceptEula /Products:"UrlRewrite2"

### Node Packages
Write-Host "Installing Node Packages..." -ForegroundColor "Yellow"
if (which npm) {
    npm update npm
    npm install -g gulp
    npm install -g mocha
    npm install -g node-inspector
    npm install -g yo
}
choco install yarn --limit-output

### Janus for vim
Write-Host "Installing Janus..." -ForegroundColor "Yellow"
if ((which curl) -and (which vim) -and (which rake) -and (which bash)) {
    curl.exe -L https://bit.ly/janus-bootstrap | bash
}


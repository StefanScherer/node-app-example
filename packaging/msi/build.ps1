$ErrorActionPreference = "Stop"

# Create plossys.exe
nexe -i bin/plossys.js -o output/plossys.exe

# Create a tmpdir
$tmp_dir = [io.path]::GetTempFileName()
Remove-Item $tmp_dir
mkdir $tmp_dir

# Parse package.json
$packageJson = (Get-Content package.json) -join "`n" | ConvertFrom-Json

# Copy excluding .git and installer
robocopy bin\ $tmp_dir\bin /COPYALL /S /NFL /NDL /NS /NC /NJH /NJS /XF *.sh
robocopy lib\ $tmp_dir\lib /COPYALL /S /NFL /NDL /NS /NC /NJH /NJS
robocopy node_modules\ $tmp_dir\node_modules /COPYALL /S /NFL /NDL /NS /NC /NJH /NJS
cp package.json $tmp_dir

$env:SERVICE_NAME = $packageJson.plossys.serviceName
$env:KEYWORDS = $packageJson.keywords

# Generate the MSI version number from package.json + AppVeyor build number
$package_version = $packageJson.version
$env:MSI_VERSION = "$package_version.$env:APPVEYOR_BUILD_NUMBER"
$env:PACKAGE_NAME = $packageJson.name
$env:PACKAGE_DESCRIPTION = $packageJson.description
$env:UPGRADE_CODE = $packageJson.plossys.packaging.msi.upgradeCode
$env:AUTHOR = $packageJson.author
$env:COMPANY_FOLDER = $packageJson.author -Replace " AG$",""

# Find name of bin/*.js file to start the Node.js application
$env:MAIN_JS_FILE = (get-childitem -path bin -filter *.js).name

# Generate the installer
$wix_dir="c:\Program Files (x86)\WiX Toolset v3.9\bin"

. "$wix_dir\heat.exe" dir $tmp_dir -srd -dr INSTALLDIR -cg MainComponentGroup -out temp\directory.wxs -ke -sfrag -gg -var var.SourceDir -sreg -scom
. "$wix_dir\candle.exe" "-dSourceDir=$tmp_dir" -arch x64 msi\*.wxs temp\*.wxs -o temp\ -ext WiXUtilExtension
. "$wix_dir\light.exe" -o output\$($env:PACKAGE_NAME)-$($env:MSI_VERSION).msi temp\*.wixobj -cultures:en-US -ext WixUIExtension.dll -ext WiXUtilExtension

# Remove the temp
Remove-Item -Recurse -Force $tmp_dir

# $ErrorActionPreference = "Stop"

# Create single exe
nexe -i bin/app.js -o output/node-app-example.exe

# Create a tmpdir
$tmp_dir = [io.path]::GetTempFileName()
Remove-Item $tmp_dir
mkdir $tmp_dir

# Parse package.json
$packageJson = (Get-Content package.json) -join "`n" | ConvertFrom-Json

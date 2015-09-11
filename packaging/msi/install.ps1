$ErrorActionPreference = "Stop"

# Switch to build folder
cd "$env:APPVEYOR_BUILD_FOLDER"

# Clean
@(
    'output'
    'temp'
) |
Where-Object { Test-Path $_ } |
ForEach-Object { Remove-Item $_ -Recurse -Force -ErrorAction Stop }

# Create output and temp dir
mkdir output
mkdir temp

# Install dependencies
$ErrorActionPreference = "Continue"
npm install -g flatten-deps
npm install -g nexe
npm install --production
flatten-deps

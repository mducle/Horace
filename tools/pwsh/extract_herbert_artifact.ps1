. $PSScriptRoot/powershell_helpers.ps1 <# Imports:
  Write-And-Invoke
#>

# Index "-1" here to deal with case where we may have more than one artifact.
# We always want the last in the list, that will be the latest as they're
# sorted alphabetically
$zip_name_filter = "build/Herbert-*.zip"
try {
  $zip_file = (Get-Item "$zip_name_filter")[-1]
} catch [System.Management.Automation.RuntimeException] {
  Write-Output "Could not find archive matching pattern '$zip_name_filter'"
  exit 1;
}

# Extract Herbert archive to user's temp directory
# We extract to the temp directory instead of the current directory as the path
# lengths can exceed the maximum allowed (255 characters) and the
# "Expand-Archive" command does not offer a renaming utility
Write-Output "Extracting '$zip_file'..."
$extract_cmd = "Expand-Archive -Force -LiteralPath " + $zip_file.FullName
$extract_cmd += " -DestinationPath $env:TEMP"
Write-And-Invoke "$extract_cmd"

# Make sure there's no Herbert already in the working directory. PowerShell
# will not overwrite directories - even with the "-Force" flag
if (Test-Path "Herbert") {
  Write-Output "Removing existing Herbert directory..."
  Write-And-Invoke "Remove-Item -Force -Recurse Herbert"
}

# Move only the required 'Herbert' directory from the extracted zip
$extraction_path = [IO.Path]::Combine($env:TEMP, $zip_file.BaseName)
$herbert_path = [IO.Path]::Combine($extraction_path, "Herbert")
Write-And-Invoke "Move-Item -Force $herbert_path ."
try {
  Write-And-Invoke "Remove-Item -Force -Recurse $extraction_path -ErrorAction Stop"
} catch {
  Write-Output "Could not remove directory '$extraction_path'"
}

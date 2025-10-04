$link = "https://github.com/7xeh/XehInstaller/releases/latest/download/XehInstallerCli.exe"

$outfile = "$env:TEMP\XehInstallerCli.exe"

Write-Output "Downloading installer to $outfile"

Invoke-WebRequest -Uri "$link" -OutFile "$outfile"

Write-Output ""

Start-Process -Wait -NoNewWindow -FilePath "$outfile"

# Cleanup
Remove-Item -Force "$outfile"

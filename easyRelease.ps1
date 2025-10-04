#!/usr/bin/env pwsh
<#
.SYNOPSIS
    XehInstaller Easy Release Script
    
.DESCRIPTION
    This script helps you create a new release with minimal effort.
    It performs all necessary checks and guides you through the process.
#>

# Set error action
$ErrorActionPreference = "Stop"

Write-Host "🚀 XehInstaller Easy Release`n" -ForegroundColor Cyan

function Exec-Command {
    param (
        [string]$Command,
        [bool]$Silent = $false
    )
    
    try {
        $output = Invoke-Expression $Command 2>&1 | Out-String
        return @{ Success = $true; Output = $output.Trim() }
    }
    catch {
        if (-not $Silent) {
            Write-Host "❌ Command failed: $Command" -ForegroundColor Red
        }
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

function Read-UserInput {
    param (
        [string]$Prompt
    )
    
    Write-Host $Prompt -NoNewline -ForegroundColor Yellow
    return Read-Host
}

# 1. Check for uncommitted changes
Write-Host "📋 Checking git status..." -ForegroundColor Blue
$status = git status --porcelain

if ($status) {
    Write-Host "⚠️  You have uncommitted changes:" -ForegroundColor Yellow
    Write-Host $status
    
    $commit = Read-UserInput "`nCommit changes now? (y/n): "
    
    if ($commit -eq "y") {
        $message = Read-UserInput "Commit message: "
        git add .
        git commit -m $message
        Write-Host "✅ Changes committed" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Please commit changes before releasing" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "✅ Working directory clean" -ForegroundColor Green
}

# 2. Get current version from git
Write-Host "`n📦 Getting current version..." -ForegroundColor Blue
$currentTag = git describe --tags --abbrev=0 2>$null

if ($currentTag) {
    $currentVersion = $currentTag -replace "^v", ""
    Write-Host "Current version: v$currentVersion" -ForegroundColor Cyan
}
else {
    $currentVersion = "1.0.0"
    Write-Host "No existing tags found. Starting with: v$currentVersion" -ForegroundColor Cyan
}

# 3. Ask for new version
$newVersionInput = Read-UserInput "New version (press Enter to use current): "
$versionToUse = if ($newVersionInput) { $newVersionInput } else { $currentVersion }
$tag = "v$versionToUse"

# 4. Check if tag already exists
$existingTag = git tag -l $tag

if ($existingTag -eq $tag) {
    Write-Host "`n⚠️  Tag $tag already exists!" -ForegroundColor Yellow
    $overwrite = Read-UserInput "Delete and recreate? (y/n): "
    
    if ($overwrite -eq "y") {
        git tag -d $tag
        git push origin ":refs/tags/$tag" 2>$null
        Write-Host "✅ Existing tag deleted" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Release cancelled" -ForegroundColor Red
        exit 0
    }
}

# 5. Test build
Write-Host "`n🔨 Testing build..." -ForegroundColor Blue
Write-Host "Building GUI executable..." -ForegroundColor Cyan

# Set up environment for CGO
$env:PATH = "C:\Windows\mingw64\bin;$env:PATH"
$env:CGO_ENABLED = "1"

# Get git info for build
$gitHash = git rev-parse --short HEAD
$gitTag = $versionToUse

# Build GUI
Write-Host "  📦 Building XehInstaller.exe..." -ForegroundColor Cyan
$buildGuiResult = Exec-Command "go build -v -tags 'static,gui' -ldflags `"-H windowsgui -s -w -X 'vencord/buildinfo.InstallerGitHash=$gitHash' -X 'vencord/buildinfo.InstallerTag=$gitTag'`" -o XehInstaller.exe"

if (-not $buildGuiResult.Success) {
    Write-Host "❌ GUI build failed! Fix errors and try again." -ForegroundColor Red
    exit 1
}

# Build CLI
Write-Host "  📦 Building XehInstallerCli.exe..." -ForegroundColor Cyan
$buildCliResult = Exec-Command "go build -v -tags 'static,cli' -ldflags `"-s -w -X 'vencord/buildinfo.InstallerGitHash=$gitHash' -X 'vencord/buildinfo.InstallerTag=$gitTag'`" -o XehInstallerCli.exe"

if (-not $buildCliResult.Success) {
    Write-Host "❌ CLI build failed! Fix errors and try again." -ForegroundColor Red
    exit 1
}

# Check if executables exist
if (-not (Test-Path "XehInstaller.exe") -or -not (Test-Path "XehInstallerCli.exe")) {
    Write-Host "❌ Executables not found! Build may have failed." -ForegroundColor Red
    exit 1
}

$guiSize = [math]::Round((Get-Item "XehInstaller.exe").Length / 1MB, 2)
$cliSize = [math]::Round((Get-Item "XehInstallerCli.exe").Length / 1MB, 2)
Write-Host "✅ Build successful" -ForegroundColor Green
Write-Host "   XehInstaller.exe: $guiSize MB" -ForegroundColor Cyan
Write-Host "   XehInstallerCli.exe: $cliSize MB" -ForegroundColor Cyan

# 6. Confirm release
Write-Host "`n📋 Release Summary:" -ForegroundColor Magenta
Write-Host "   Version: $tag" -ForegroundColor White
Write-Host "   Commit: $gitHash" -ForegroundColor White
Write-Host "   GUI size: $guiSize MB" -ForegroundColor White
Write-Host "   CLI size: $cliSize MB" -ForegroundColor White

Write-Host "`nThis will:" -ForegroundColor Yellow
Write-Host "   1. Create tag: $tag" -ForegroundColor White
Write-Host "   2. Push to GitHub" -ForegroundColor White
Write-Host "   3. Trigger automatic build & release" -ForegroundColor White
Write-Host "   4. Upload executables to release" -ForegroundColor White

$confirm = Read-UserInput "`n🎯 Proceed with release? (y/n): "

if ($confirm -ne "y") {
    Write-Host "❌ Release cancelled" -ForegroundColor Red
    exit 0
}

# 7. Push changes if needed
Write-Host "`n📤 Pushing changes..." -ForegroundColor Blue
$pushResult = Exec-Command "git push" -Silent $true

if (-not $pushResult.Success) {
    Write-Host "⚠️  Push failed, but continuing..." -ForegroundColor Yellow
}

# 8. Create and push tag
Write-Host "`n🏷️  Creating tag $tag..." -ForegroundColor Blue
git tag -a $tag -m "Release $tag"

Write-Host "📤 Pushing tag to GitHub..." -ForegroundColor Blue
$pushTagResult = Exec-Command "git push origin $tag"

if (-not $pushTagResult.Success) {
    Write-Host "❌ Failed to push tag!" -ForegroundColor Red
    exit 1
}

# 9. Success!
Write-Host "`n🎉 Release initiated successfully!`n" -ForegroundColor Green

Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "   1. Monitor build: https://github.com/7xeh/XehInstaller/actions" -ForegroundColor White
Write-Host "   2. Check release: https://github.com/7xeh/XehInstaller/releases/tag/$tag" -ForegroundColor White
Write-Host "   3. Download and test the release" -ForegroundColor White

Write-Host "`nThe GitHub Actions workflow will:" -ForegroundColor Yellow
Write-Host "   - Build for Windows, macOS, and Linux" -ForegroundColor White
Write-Host "   - Create the release" -ForegroundColor White
Write-Host "   - Upload all executables" -ForegroundColor White

Write-Host "`nExpected time: 5-10 minutes" -ForegroundColor Cyan
Write-Host "`n✨ Happy releasing! 🚀`n" -ForegroundColor Magenta

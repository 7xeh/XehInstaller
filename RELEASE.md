# XehInstaller Release Guide

This guide explains how to create a new release for XehInstaller, similar to the XehCord release process.

## Quick Release (Recommended)

The easiest way to create a release is using the interactive script:

```sh
pnpm easyRelease
```

This will guide you through the entire process step by step.

## What the Script Does

The `easyRelease` script automates the entire release process:

1. **Checks Git Status**: Ensures all changes are committed
2. **Version Selection**: Prompts for the new version number
3. **Tag Management**: Handles existing tags and creates new ones
4. **Builds & Tests**: Compiles both GUI and CLI executables
5. **Creates Release**: Tags the commit and pushes to GitHub
6. **Triggers Workflow**: GitHub Actions automatically builds for all platforms

## Manual Release Process

If you prefer manual control:

### 1. Prepare Your Changes

```sh
git add .
git commit -m "Prepare release v1.0.2"
git push
```

### 2. Create a Git Tag

```sh
# Create an annotated tag
git tag -a v1.0.2 -m "Release v1.0.2"

# Push the tag to GitHub
git push origin v1.0.2
```

### 3. Automatic Build

Once the tag is pushed, GitHub Actions will:
- Build XehInstaller for Windows (GUI + CLI)
- Build XehInstaller for macOS (GUI)
- Build XehInstaller for Linux (GUI + CLI, both X11 and Wayland)
- Create a GitHub Release
- Upload all executables as release assets

## Version Numbering

Follow semantic versioning:
- **v1.0.0** - Major release (breaking changes)
- **v1.1.0** - Minor release (new features)
- **v1.0.1** - Patch release (bug fixes)

## Platform-Specific Commands

### Windows (PowerShell)
```powershell
pwsh -ExecutionPolicy Bypass -File ./easyRelease.ps1
```

### Linux/macOS (Bash)
```bash
bash ./easyRelease.sh
```

### Using pnpm
```sh
# Standard (uses PowerShell on Windows)
pnpm easyRelease

# Force bash version
pnpm easyRelease:bash
```

## What Gets Built

The release includes:

### Windows
- **XehInstaller.exe** - GUI version with purple theme
- **XehInstallerCli.exe** - Command-line version

### macOS
- **XehInstaller.MacOS.zip** - GUI application bundle

### Linux
- **XehInstaller-x11** - GUI version for X11
- **XehInstaller-wayland** - GUI version for Wayland
- **XehInstallerCli-Linux** - Command-line version

## Build Information

Each release includes:
- Git commit hash
- Version tag
- Build timestamp
- Build flags for optimization

## Troubleshooting

### "CGO_ENABLED" not set
Make sure GCC/MinGW is installed and in your PATH.

**Windows**: Add `C:\Windows\mingw64\bin` to PATH
**Linux**: Install `build-essential` or `gcc`
**macOS**: Install Xcode Command Line Tools

### Build fails
1. Run `go mod tidy` to ensure dependencies are updated
2. Check that you have the latest Go version (1.24+)
3. Verify GCC/MinGW is installed correctly

### Tag already exists
The script will ask if you want to delete and recreate it:
```sh
git tag -d v1.0.2
git push origin :refs/tags/v1.0.2
```

### GitHub Actions fails
- Check the [Actions tab](https://github.com/7xeh/XehInstaller/actions)
- Review error logs for specific issues
- Ensure `.github/workflows/release.yml` is up to date

## Testing Before Release

### Local Build Test
```sh
# Set up environment (Windows)
$env:PATH = "C:\Windows\mingw64\bin;$env:PATH"
$env:CGO_ENABLED = "1"

# Build GUI
go build -tags static,gui -ldflags="-H windowsgui" -o XehInstaller.exe

# Build CLI
go build -tags static,cli -o XehInstallerCli.exe

# Test the executables
.\XehInstaller.exe
.\XehInstallerCli.exe --help
```

## Monitoring Releases

After pushing a tag:
1. Watch the [Actions page](https://github.com/7xeh/XehInstaller/actions)
2. Typical build time: 5-10 minutes
3. Once complete, check the [Releases page](https://github.com/7xeh/XehInstaller/releases)
4. Download and test the release assets

## Release Checklist

Before releasing:
- [ ] All changes are committed and pushed
- [ ] Code compiles without errors
- [ ] GUI theme looks correct (purple theme applied)
- [ ] CLI version works as expected
- [ ] Version number follows semantic versioning
- [ ] README is updated if needed

After releasing:
- [ ] GitHub Actions workflow completed successfully
- [ ] All platform binaries are attached to release
- [ ] Release notes are accurate
- [ ] Executables download and run correctly

## Integration with XehCord

XehInstaller automatically downloads the latest XehCord release:
- Source: `https://api.github.com/repos/7xeh/Xehcord/releases/latest`
- Asset: `desktop.asar`
- Installation: Patches Discord with XehCord modifications

## Support

If you encounter issues:
1. Check this guide first
2. Review the [XehCord release guide](https://github.com/7xeh/XehCord/blob/main/RELEASE.md)
3. Open an issue with:
   - Your operating system
   - Go version (`go version`)
   - GCC version (`gcc --version`)
   - Error messages or logs

---

**Last Updated**: October 4, 2025  
**Script Version**: 1.0.0  
**Compatible with**: XehInstaller v1.0.0+

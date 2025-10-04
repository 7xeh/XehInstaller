# XehInstaller

The Xehcord Installer allows you to install [Xehcord](https://github.com/7xeh/Xehcord)

![image](https://cdn.discordapp.com/attachments/1234049336388882456/1423916004437655594/JCwiFRy.png?ex=68e20c9e&is=68e0bb1e&hm=f4c9db1a7a6be091314fc1bd01a388ff8c58e32b2bd44360c168e86ba7ecc3d9&)

## Usage

Windows
- [GUI](https://github.com/7xeh/XehInstaller/releases/latest/download/XehInstaller.exe) 
- [CLI](https://github.com/7xeh/XehInstaller/releases/latest/download/XehInstallerCli.exe)

MacOS
- [GUI](https://github.com/7xeh/XehInstaller/releases/latest/download/XehInstaller.MacOS.zip)

Linux 
- [GUI](https://github.com/7xeh/XehInstaller/releases/latest/download/XehInstaller-x11)
- [CLI](https://github.com/7xeh/XehInstaller/releases/latest/download/XehInstallerCli-Linux)
## Building from source

### Prerequisites 

You need to install the [Go programming language](https://go.dev/doc/install) and GCC, the GNU Compiler Collection (MinGW on Windows)

<details>
<summary>Additionally, if you're using Linux, you have to install some additional dependencies:</summary>

#### Base dependencies
```sh
apt install -y pkg-config libsdl2-dev libglx-dev libgl1-mesa-dev
dnf install pkg-config libGL-devel libXxf86vm-devel
```

#### X11 dependencies
```sh
apt install -y xorg-dev
dnf install libXcursor-devel libXi-devel libXinerama-devel libXrandr-devel
```

#### Wayland dependencies
```sh
apt install -y libwayland-dev libxkbcommon-dev wayland-protocols extra-cmake-modules
dnf install wayland-devel libxkbcommon-devel wayland-protocols-devel extra-cmake-modules
```

</details>

### Building

#### Install dependencies

```sh
go mod tidy
```

#### Build the GUI

##### Windows / Mac / Linux X11
```sh
go build
```

##### Linux Wayland
```sh
go build --tags wayland
```

#### Build the CLI
```
go build --tags cli
```

You might want to pass some flags to this command to get a better build.
See [the GitHub workflow](https://github.com/7xeh/XehInstaller/blob/main/.github/workflows/release.yml) for what flags I pass or if you want more precise instructions

## Creating a Release

XehInstaller includes an easy release script similar to Xehcord's workflow. To create a new release:

### Using pnpm (Recommended)

```sh
pnpm easyRelease
```

This interactive script will:
- ✅ Check for uncommitted changes
- ✅ Build and test both GUI and CLI versions
- ✅ Create a git tag with your version
- ✅ Push to GitHub and trigger automatic release builds
- ✅ Guide you through the entire process

### Manual Release

If you prefer to do it manually:

```sh
# 1. Commit all changes
git add .
git commit -m "Prepare release v1.x.x"
git push

# 2. Create and push a tag
git tag v1.x.x
git push origin v1.x.x
```

The GitHub Actions workflow will automatically build for Windows, macOS, and Linux, then create a release with all executables.

### Platform-Specific Scripts

- **Windows/PowerShell**: `pwsh ./easyRelease.ps1`
- **Linux/macOS/Bash**: `bash ./easyRelease.sh`

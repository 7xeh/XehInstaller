#!/usr/bin/env bash
#
# XehInstaller Easy Release Script
#
# This script helps you create a new release with minimal effort.
# It performs all necessary checks and guides you through the process.

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${CYAN}🚀 XehInstaller Easy Release\n${NC}"

# Function to execute commands
exec_command() {
    local cmd="$1"
    local silent="${2:-false}"
    
    if output=$(eval "$cmd" 2>&1); then
        echo "$output"
        return 0
    else
        if [ "$silent" != "true" ]; then
            echo -e "${RED}❌ Command failed: $cmd${NC}"
        fi
        return 1
    fi
}

# Function to read user input
read_input() {
    local prompt="$1"
    local response
    echo -ne "${YELLOW}$prompt${NC}"
    read -r response
    echo "$response"
}

# 1. Check for uncommitted changes
echo -e "${BLUE}📋 Checking git status...${NC}"
status=$(git status --porcelain)

if [ -n "$status" ]; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes:${NC}"
    echo "$status"
    
    commit=$(read_input "\nCommit changes now? (y/n): ")
    
    if [ "$commit" = "y" ]; then
        message=$(read_input "Commit message: ")
        git add .
        git commit -m "$message"
        echo -e "${GREEN}✅ Changes committed${NC}"
    else
        echo -e "${RED}❌ Please commit changes before releasing${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Working directory clean${NC}"
fi

# 2. Get current version from git
echo -e "\n${BLUE}📦 Getting current version...${NC}"
currentTag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -n "$currentTag" ]; then
    currentVersion="${currentTag#v}"
    echo -e "${CYAN}Current version: v$currentVersion${NC}"
else
    currentVersion="1.0.0"
    echo -e "${CYAN}No existing tags found. Starting with: v$currentVersion${NC}"
fi

# 3. Ask for new version
newVersionInput=$(read_input "New version (press Enter to use current): ")
versionToUse="${newVersionInput:-$currentVersion}"
tag="v$versionToUse"

# 4. Check if tag already exists
existingTag=$(git tag -l "$tag")

if [ "$existingTag" = "$tag" ]; then
    echo -e "\n${YELLOW}⚠️  Tag $tag already exists!${NC}"
    overwrite=$(read_input "Delete and recreate? (y/n): ")
    
    if [ "$overwrite" = "y" ]; then
        git tag -d "$tag"
        git push origin ":refs/tags/$tag" 2>/dev/null || true
        echo -e "${GREEN}✅ Existing tag deleted${NC}"
    else
        echo -e "${RED}❌ Release cancelled${NC}"
        exit 0
    fi
fi

# 5. Test build
echo -e "\n${BLUE}🔨 Testing build...${NC}"
echo -e "${CYAN}Building executables...${NC}"

# Get git info for build
gitHash=$(git rev-parse --short HEAD)
gitTag="$versionToUse"

# Determine the OS for build
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS build
    echo -e "  ${CYAN}📦 Building XehInstaller (macOS)...${NC}"
    go build -v -tags "static,gui" -ldflags "-s -w -X 'vencord/buildinfo.InstallerGitHash=$gitHash' -X 'vencord/buildinfo.InstallerTag=$gitTag'" -o XehInstaller || {
        echo -e "${RED}❌ Build failed! Fix errors and try again.${NC}"
        exit 1
    }
    
    guiSize=$(du -h XehInstaller | cut -f1)
    echo -e "${GREEN}✅ Build successful${NC}"
    echo -e "   ${CYAN}XehInstaller: $guiSize${NC}"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    # Windows build (using Git Bash or similar)
    export CGO_ENABLED=1
    echo -e "  ${CYAN}📦 Building XehInstaller.exe...${NC}"
    go build -v -tags "static,gui" -ldflags "-H windowsgui -s -w -X 'vencord/buildinfo.InstallerGitHash=$gitHash' -X 'vencord/buildinfo.InstallerTag=$gitTag'" -o XehInstaller.exe || {
        echo -e "${RED}❌ GUI build failed! Fix errors and try again.${NC}"
        exit 1
    }
    
    echo -e "  ${CYAN}📦 Building XehInstallerCli.exe...${NC}"
    go build -v -tags "static,cli" -ldflags "-s -w -X 'vencord/buildinfo.InstallerGitHash=$gitHash' -X 'vencord/buildinfo.InstallerTag=$gitTag'" -o XehInstallerCli.exe || {
        echo -e "${RED}❌ CLI build failed! Fix errors and try again.${NC}"
        exit 1
    }
    
    guiSize=$(du -h XehInstaller.exe | cut -f1)
    cliSize=$(du -h XehInstallerCli.exe | cut -f1)
    echo -e "${GREEN}✅ Build successful${NC}"
    echo -e "   ${CYAN}XehInstaller.exe: $guiSize${NC}"
    echo -e "   ${CYAN}XehInstallerCli.exe: $cliSize${NC}"
else
    # Linux build
    echo -e "  ${CYAN}📦 Building XehInstaller (Linux)...${NC}"
    go build -v -tags "static,gui" -ldflags "-s -w -X 'vencord/buildinfo.InstallerGitHash=$gitHash' -X 'vencord/buildinfo.InstallerTag=$gitTag'" -o XehInstaller || {
        echo -e "${RED}❌ GUI build failed! Fix errors and try again.${NC}"
        exit 1
    }
    
    echo -e "  ${CYAN}📦 Building XehInstallerCli (Linux)...${NC}"
    go build -v -tags "static,cli" -ldflags "-s -w -X 'vencord/buildinfo.InstallerGitHash=$gitHash' -X 'vencord/buildinfo.InstallerTag=$gitTag'" -o XehInstallerCli || {
        echo -e "${RED}❌ CLI build failed! Fix errors and try again.${NC}"
        exit 1
    }
    
    guiSize=$(du -h XehInstaller | cut -f1)
    cliSize=$(du -h XehInstallerCli | cut -f1)
    echo -e "${GREEN}✅ Build successful${NC}"
    echo -e "   ${CYAN}XehInstaller: $guiSize${NC}"
    echo -e "   ${CYAN}XehInstallerCli: $cliSize${NC}"
fi

# 6. Confirm release
echo -e "\n${MAGENTA}📋 Release Summary:${NC}"
echo -e "   ${NC}Version: $tag${NC}"
echo -e "   ${NC}Commit: $gitHash${NC}"

echo -e "\n${YELLOW}This will:${NC}"
echo -e "   ${NC}1. Create tag: $tag${NC}"
echo -e "   ${NC}2. Push to GitHub${NC}"
echo -e "   ${NC}3. Trigger automatic build & release${NC}"
echo -e "   ${NC}4. Upload executables to release${NC}"

confirm=$(read_input "\n🎯 Proceed with release? (y/n): ")

if [ "$confirm" != "y" ]; then
    echo -e "${RED}❌ Release cancelled${NC}"
    exit 0
fi

# 7. Push changes if needed
echo -e "\n${BLUE}📤 Pushing changes...${NC}"
git push 2>/dev/null || echo -e "${YELLOW}⚠️  Push failed, but continuing...${NC}"

# 8. Create and push tag
echo -e "\n${BLUE}🏷️  Creating tag $tag...${NC}"
git tag -a "$tag" -m "Release $tag"

echo -e "${BLUE}📤 Pushing tag to GitHub...${NC}"
if ! git push origin "$tag"; then
    echo -e "${RED}❌ Failed to push tag!${NC}"
    exit 1
fi

# 9. Success!
echo -e "\n${GREEN}🎉 Release initiated successfully!\n${NC}"

echo -e "${CYAN}Next steps:${NC}"
echo -e "   ${NC}1. Monitor build: https://github.com/7xeh/XehInstaller/actions${NC}"
echo -e "   ${NC}2. Check release: https://github.com/7xeh/XehInstaller/releases/tag/$tag${NC}"
echo -e "   ${NC}3. Download and test the release${NC}"

echo -e "\n${YELLOW}The GitHub Actions workflow will:${NC}"
echo -e "   ${NC}- Build for Windows, macOS, and Linux${NC}"
echo -e "   ${NC}- Create the release${NC}"
echo -e "   ${NC}- Upload all executables${NC}"

echo -e "\n${CYAN}Expected time: 5-10 minutes${NC}"
echo -e "\n${MAGENTA}✨ Happy releasing! 🚀\n${NC}"

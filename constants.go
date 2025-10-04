/*
 * SPDX-License-Identifier: GPL-3.0
 * Vencord Installer, a cross platform gui/cli app for installing Vencord
 * Copyright (c) 2023 Vendicated and Vencord contributors
 */

package main

import (
	"image/color"
	"vencord/buildinfo"
)

const ReleaseUrl = "https://api.github.com/repos/7xeh/Xehcord/releases/latest"
const ReleaseUrlFallback = "https://xehcord.org/releases/xehcord"
const InstallerReleaseUrl = "https://api.github.com/repos/7xeh/XehInstaller/releases/latest"
const InstallerReleaseUrlFallback = "https://xehcord.org/releases/xehinstaller"

var UserAgent = "XehInstaller/" + buildinfo.InstallerGitHash + " (https://github.com/7xeh/XehInstaller)"

var (
	DiscordGreen  = color.RGBA{R: 0x2D, G: 0x7C, B: 0x46, A: 0xFF}
	DiscordRed    = color.RGBA{R: 0xEC, G: 0x41, B: 0x44, A: 0xFF}
	DiscordBlue   = color.RGBA{R: 0x58, G: 0x65, B: 0xF2, A: 0xFF}
	DiscordYellow = color.RGBA{R: 0xfe, G: 0xe7, B: 0x5c, A: 0xff}

	// Purple Theme Colors
	PurplePrimary   = color.RGBA{R: 0x9B, G: 0x59, B: 0xB6, A: 0xFF} // Main purple
	PurpleSecondary = color.RGBA{R: 0x8E, G: 0x44, B: 0xAD, A: 0xFF} // Darker purple
	PurpleAccent    = color.RGBA{R: 0xBB, G: 0x86, B: 0xFC, A: 0xFF} // Light purple
	PurpleDanger    = color.RGBA{R: 0xE7, G: 0x4C, B: 0x3C, A: 0xFF} // Red for uninstall
	DarkBg          = color.RGBA{R: 0x1A, G: 0x1A, B: 0x1A, A: 0xFF} // Dark background
	DarkerBg        = color.RGBA{R: 0x0F, G: 0x0F, B: 0x0F, A: 0xFF} // Even darker
	LightText       = color.RGBA{R: 0xE0, G: 0xE0, B: 0xE0, A: 0xFF} // Light text
)

var LinuxDiscordNames = []string{
	"Discord",
	"DiscordPTB",
	"DiscordCanary",
	"DiscordDevelopment",
	"discord",
	"discordptb",
	"discordcanary",
	"discorddevelopment",
	"discord-ptb",
	"discord-canary",
	"discord-development",
	// Flatpak
	"com.discordapp.Discord",
	"com.discordapp.DiscordPTB",
	"com.discordapp.DiscordCanary",
	"com.discordapp.DiscordDevelopment",
}

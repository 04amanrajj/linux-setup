# 🛠️ Linux Setup Automation Script

[![Ubuntu Tested](https://img.shields.io/badge/Ubuntu-22.04%20%7C%2024.04-blue?logo=ubuntu)](https://ubuntu.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Made with ❤️ by Aman Raj](https://img.shields.io/badge/Made%20with-%E2%9D%A4-red)](https://github.com/amanrajj)

A modular and powerful setup script for Ubuntu that helps you automate the installation of:

- APT packages (System tools, dev tools, multimedia, etc.)
- Snap apps (Spotify, VS Code, etc.)
- Flatpak apps (GIMP, Discord, etc.)
- GNOME Extensions (Productivity & UI customizations)

Great for fresh installs, system recovery, or syncing setups across multiple devices.

---

## 📁 Structure

```jsonc
{
  "apt": ["package1", "package2", "..."],
  "snap": ["snap-app1", "snap-app2 --classic", "..."],
  "flatpak": [
    { "id": "app.id.Here", "repo": "flathub" }
  ],
  "extensions": ["extension@site.com.shell-extension.zip"]
}

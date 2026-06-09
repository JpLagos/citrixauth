#!/usr/bin/env bash
set -euo pipefail

echo "Citrix Auth — Keychain Setup"
echo "Credentials will be stored securely in macOS Keychain."
echo ""

read -r -p "Citrix username: " citrix_user
security add-generic-password -U -a "$USER" -s "citrixauth-user" -w "$citrix_user"

read -r -s -p "Citrix password: " citrix_password
echo ""
security add-generic-password -U -a "$USER" -s "citrixauth-password" -w "$citrix_password"

read -r -s -p "stoken master password: " token_password
echo ""
security add-generic-password -U -a "$USER" -s "citrixauth-token-password" -w "$token_password"

echo ""
echo "Done. Credentials stored in macOS Keychain."
echo "You can now run: osascript citrixauth.scpt"

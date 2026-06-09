# Citrix Secure Access Automation

> Note: This project is intended for internal or enterprise use, as it requires credentials and configuration files typically provided by your organization.

## macOS Version Compatibility

This repository contains two branches for different macOS versions:

- **`main`** - For **macOS Tahoe (26.1)** and newer
- **`sequoia`** - For **macOS Sequoia** and older versions

Make sure to use the appropriate branch for your macOS version. The UI hierarchy changed significantly in Tahoe, requiring different element paths.

## Overview

This project automates the login process for **Citrix Secure Access** on macOS using AppleScript and `expect`. AppleScript is used to control UI interactions, while `expect` handles terminal automation such as entering passwords or responding to prompts.

It performs the following steps:

- Clicking the "Connect" or "Conectar" button.
- Filling in the username, password, and one-time password (OTP).
- Submitting the form using the `Return` key.

The scripts are designed to securely externalize sensitive information and make them configurable for different users. The paths to configuration files are determined dynamically, making the scripts more portable and easier to manage.

## Features

- Automates the full Citrix login process.
- Dynamically waits for UI elements to load.
- Uses a secure OTP generation script (`stoken`).
- Supports configurable credentials and dynamic path resolution through `config.sh`, improving portability across systems.

## Prerequisites

1. **macOS** with support for AppleScript and `expect`.

    - AppleScript can be executed via the `osascript` command, which should be available by default.
    - Make sure both `osascript` and `expect` are available in your terminal by running:

     ```bash
     which osascript
     which expect
     ```

2. **Install and configure `stoken` for OTP generation:**

   `stoken` is used to generate the temporary one-time password (OTP) for authentication. Follow these steps:

   > Note: The `.sdtid` file is typically provided by your organization for RSA token-based authentication.

   1. Install `stoken`:

      ```bash
      brew install stoken
      ```

   2. In the directory where your `.sdtid` token file is located, run:

      ```bash
      stoken import --file=FILENAME.sdtid --force
      ```

   3. You will be prompted to create a **master password**. This password will be required each time you want to generate a token.

   4. To test the setup:

      ```bash
      stoken
      ```

      Enter your password when prompted. A token should be displayed if everything is set up correctly.

   For more information, visit the [stoken GitHub page](https://github.com/stoken-dev/stoken).

3. A working Citrix Secure Access installation. You can download it from your organization's internal software portal or the official Citrix site, depending on your enterprise setup.

## Installation

1. Clone the repository:

```bash
git clone https://github.com/sebasalas/citrixauth.git
cd citrixauth
```

2. Store your credentials in macOS Keychain by running the setup script once:

```bash
bash utils/setup-keychain.sh
```

You will be prompted for your Citrix username, Citrix password, and stoken master password. Credentials are stored encrypted in the macOS Keychain and never written to disk in plain text.

> Note: To update a credential later, simply run `setup-keychain.sh` again — it overwrites the existing entry.

3. Make the script executable:

```bash
chmod +x utils/get_token.sh
```

## Usage

Launch the automation script:

```bash
osascript citrixauth.scpt
```

## Workflow Overview

- The script launches Citrix Secure Access.
- It uses AppleScript to detect when the login window is ready.
- It securely retrieves credentials and OTP from environment variables or helper scripts.
- It silently simulates keyboard input to fill in the login form and submits it, requiring no user interaction once running.

## Troubleshooting

### Error: "execution error: System Events got an error: osascript is not allowed assistive access."

If you encounter this error, it means your terminal application (e.g., Terminal, iTerm2) does not have the necessary permissions to use assistive access. To resolve this:

1. Open **System Settings** on your Mac.
2. Go to **Privacy & Security** > **Accessibility**.
3. Locate your terminal application (e.g., Terminal, iTerm2) in the list.

   - If it’s not listed, click the `+` button, and manually add it from the `/Applications` folder.

4. Enable the checkbox next to your terminal application to grant it permission.
5. Re-run the command:

```bash
osascript citrixauth.scpt
```

## File Structure

```bash
citrixauth/
├── citrixauth.scpt        # Main AppleScript automation
├── utils/
│   ├── get_token.sh       # OTP retrieval using stoken
│   ├── setup-keychain.sh  # One-time credential setup (stores to macOS Keychain)
│   └── config.sh          # User-specific overrides if needed (excluded from Git)
└── README.md              # Project documentation
```

## Security Best Practices

- Credentials are stored in **macOS Keychain**, not in plain text files.
- `utils/config.sh` is excluded from Git via `.gitignore` — do not remove that entry.
- Never share or commit any file containing your Citrix password or stoken master password.

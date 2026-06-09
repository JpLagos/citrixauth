-- Get the directory of the current script
set scriptDir to POSIX path of (do shell script "dirname " & quoted form of POSIX path of (path to me)) & "/utils"

-- Load credentials from macOS Keychain
set citrixUser to do shell script "security find-generic-password -a \"$USER\" -s \"citrixauth-user\" -w"
set citrixPassword to do shell script "security find-generic-password -a \"$USER\" -s \"citrixauth-password\" -w"

set maxWait to 150 -- 30 seconds at 0.2s intervals

tell application "Citrix Secure Access"
    activate
end tell

tell application "System Events"
    tell process "Citrix Secure Access"

        -- Wait for the main window to appear
        set waitCount to 0
        repeat until (exists window "Citrix Secure Access")
            delay 0.2
            set waitCount to waitCount + 1
            if waitCount >= maxWait then
                error "Timeout: Citrix Secure Access window did not appear after 30 seconds." number -1
            end if
        end repeat

        -- Wait for the "Connect" or "Conectar" button to appear
        tell window "Citrix Secure Access"
            set buttonFound to false
            set waitCount to 0
            repeat until buttonFound
                if (exists button "Connect") then
                    click button "Connect"
                    set buttonFound to true
                else if (exists button "Conectar") then
                    click button "Conectar"
                    set buttonFound to true
                else
                    delay 0.2
                    set waitCount to waitCount + 1
                    if waitCount >= maxWait then
                        error "Timeout: Connect button did not appear after 30 seconds." number -1
                    end if
                end if
            end repeat
        end tell

        set otpCode to ""

        -- Wait for the auth window to appear
        set waitCount to 0
        repeat until (exists window "Citrix Secure Access auth")
            delay 0.2
            set waitCount to waitCount + 1
            if waitCount >= maxWait then
                error "Timeout: Citrix Secure Access auth window did not appear after 30 seconds." number -1
            end if
        end repeat

        -- Get OTP now (while form is loading)
        set otpCode to do shell script scriptDir & "/get_token.sh | tail -n 1"

        -- Wait for the input fields and fill the form
        tell window "Citrix Secure Access auth"
            tell group 1
                tell group 1
                    tell scroll area 1
                        tell UI element 1
                            tell group 1
                                set waitCount to 0
                                repeat until (exists group 3)
                                    delay 0.2
                                    set waitCount to waitCount + 1
                                    if waitCount >= maxWait then
                                        error "Timeout: Login form fields did not appear after 30 seconds." number -1
                                    end if
                                end repeat

                                click text field 1 of group 3
                                delay 0.2
                                keystroke "a" using {command down}
                                keystroke citrixUser

                                keystroke tab
                                delay 0.2
                                keystroke citrixPassword

                                keystroke tab
                                delay 0.2
                                keystroke otpCode

                                delay 0.2
                                click UI element "Enviar"
                            end tell
                        end tell
                    end tell
                end tell
            end tell
        end tell
    end tell
end tell

log "Citrix login submitted successfully."

-- Get the directory of the current script
set scriptDir to POSIX path of (do shell script "dirname " & quoted form of POSIX path of (path to me)) & "/utils"

-- Load sensitive information from config.sh
set configPath to scriptDir & "/config.sh"
set citrixUser to (do shell script "source " & configPath & " && echo $CITRIX_USER")
set citrixPassword to (do shell script "source " & configPath & " && echo $CITRIX_PASSWORD")
set scriptDir to (do shell script "source " & configPath & " && echo $CITRIX_SCRIPT_DIR")

tell application "Citrix Secure Access"
    activate
end tell

tell application "Citrix Secure Access"
    activate
end tell

-- Wait dynamically for the first window to appear
tell application "System Events"
    tell process "Citrix Secure Access"
        repeat until (exists window "Citrix Secure Access")
            delay 0.5 -- Check every 0.5 seconds
        end repeat

        -- Wait dynamically for the "Connect" or "Conectar" button to appear
        tell window "Citrix Secure Access"
            set buttonFound to false
            repeat until buttonFound
                if (exists button "Connect") then
                    click button "Connect"
                    set buttonFound to true
                else if (exists button "Conectar") then
                    click button "Conectar"
                    set buttonFound to true
                else
                    delay 0.5 -- Check every 0.5 seconds
                end if
            end repeat
        end tell

        -- Wait dynamically for the login window to appear
        repeat until (exists window "Citrix Secure Access auth")
            delay 0.5 -- Check every 0.5 seconds
        end repeat

        -- Wait dynamically for the input fields to appear (new hierarchy in macOS Tahoe)
        tell window "Citrix Secure Access auth"
            tell group 1
                tell group 1
                    tell scroll area 1
                        tell UI element 1 -- Web Area
                            tell UI element 1 -- First nested group
                                tell UI element 1 -- Second nested group
                                    repeat until (exists UI element 3)
                                        delay 0.5 -- Check every 0.5 seconds
                                    end repeat

                                    -- Enter the username (Group 3)
                                    tell UI element 3
                                        set value of text field 1 to citrixUser
                                    end tell

                                    -- Enter the password (Group 5)
                                    tell UI element 5
                                        set value of text field 1 to citrixPassword
                                    end tell

                                    -- Retrieve the OTP using the `get_token.sh` script
                                    set otpCode to do shell script scriptDir & "/utils/get_token.sh | tail -n 1"

                                    -- Enter the OTP into the passcode field (Group 7)
                                    tell UI element 7
                                        set value of text field 1 to otpCode
                                    end tell
                                end tell
                            end tell
                        end tell
                    end tell
                end tell
            end tell
        end tell
    end tell
end tell

-- Fallback: Simulate pressing the "Return" key
tell application "System Events"
    delay 0.5 -- Ensure all fields are filled before pressing Return
    key code 36 -- Press Return key
end tell

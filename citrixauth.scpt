-- Get the directory of the current script
set scriptDir to POSIX path of (do shell script "dirname " & quoted form of POSIX path of (path to me)) & "/utils"

-- Load sensitive information from config.sh (optimized: single call)
set configPath to scriptDir & "/config.sh"
set configData to (do shell script "source " & configPath & " && echo \"$CITRIX_USER
$CITRIX_PASSWORD
$CITRIX_SCRIPT_DIR\"")
set configLines to paragraphs of configData
set citrixUser to item 1 of configLines
set citrixPassword to item 2 of configLines
set scriptDir to item 3 of configLines

tell application "Citrix Secure Access"
    activate
end tell

-- Wait dynamically for the first window to appear
tell application "System Events"
    tell process "Citrix Secure Access"
        repeat until (exists window "Citrix Secure Access")
            delay 0.2 -- Check every 0.2 seconds (optimized)
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
                    delay 0.2 -- Check every 0.2 seconds (optimized)
                end if
            end repeat
        end tell

        -- Start getting OTP in background while waiting for login window
        set otpCode to ""

        -- Wait dynamically for the login window to appear
        repeat until (exists window "Citrix Secure Access auth")
            delay 0.2 -- Check every 0.2 seconds (optimized)
        end repeat

        -- Get OTP now (while form is loading)
        set otpCode to do shell script scriptDir & "/utils/get_token.sh | tail -n 1"

        -- Wait dynamically for the input fields to appear (new hierarchy in macOS Tahoe)
        tell window "Citrix Secure Access auth"
            tell group 1
                tell group 1
                    tell scroll area 1
                        tell UI element 1 -- Web Area
                            tell UI element 1 -- First nested group
                                tell UI element 1 -- Second nested group
                                    repeat until (exists UI element 3)
                                        delay 0.2 -- Check every 0.2 seconds (optimized)
                                    end repeat

                                    -- Enter the username (Group 3)
                                    tell UI element 3
                                        set value of text field 1 to citrixUser
                                    end tell

                                    -- Enter the password (Group 5)
                                    tell UI element 5
                                        set value of text field 1 to citrixPassword
                                    end tell

                                    -- Enter the OTP into the passcode field (Group 7)
                                    -- (OTP was already retrieved earlier while form was loading)
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

-- Simulate pressing the "Return" key
tell application "System Events"
    delay 0.2 -- Brief pause to ensure all fields are filled (optimized)
    key code 36 -- Press Return key
end tell

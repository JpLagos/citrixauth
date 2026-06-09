#!/usr/bin/expect
set token_password [exec security find-generic-password -a $env(USER) -s citrixauth-token-password -w]

spawn stoken
expect "Enter password to decrypt token:"
send "$token_password\r"
expect eof

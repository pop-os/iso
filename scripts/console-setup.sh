#!/usr/bin/expect

spawn dpkg-reconfigure console-setup -f readline

expect "Encoding to use on the console: "
send "UTF-8\r"

expect "Character set to support: "
send "Guess optimal character set\r"

expect "Font for the console: "
send "Terminus\r"

expect "Font size: "
send "16x32\r"

expect eof

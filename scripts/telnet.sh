#!/usr/bin/expect

log_user 0

set hostname [lindex $argv 0]
set port [lindex $argv 1]
set command [lindex $argv 2]

spawn telnet $hostname $port
expect "Test server\r"
send "$command\r"
expect "$command\r"
expect "*\r"

log_user 1
puts $expect_out(buffer)

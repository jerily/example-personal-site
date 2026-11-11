# This entry point works from both a checkout and the installed package directory.
lappend auto_path [file dirname [file normalize [info script]]]
package require example-personal-site 0.1.2

try {
    ::personal_site::main $argv
} on error {message options} {
    puts stderr "example-personal-site: $message"
    exit 1
}

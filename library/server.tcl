# 
# Copyright Jerily LTD. All Rights Reserved.
# SPDX-FileCopyrightText: 2026 Neofytos Dimitriou (neo@jerily.cy)
# SPDX-License-Identifier: MIT.
# 

# Worker state belongs to the worker interpreter, including its content and router.
proc ::personal_site::worker {content port} {
    variable routes [router $content]
    variable listen_port $port
}

proc ::personal_site::process_conn {context request} {
    variable routes
    variable listen_port

    try {
        set result [dispatch $routes $listen_port $request $context]
    } on error {message options} {
        puts stderr "example-personal-site: $message"
        set result [dict create statusCode 500 \
            headers {content-type text/plain} body {Internal server error}]
    }

    ::twebserver::return_response [dict get $context conn] $result
}

proc ::personal_site::serve {content port} {
    # Fail invalid content or templates in the main interpreter before listening.
    set validation [router $content]
    $validation destroy

    set init [join [list \
        [list set auto_path $::auto_path] \
        {package require example-personal-site 0.2.1} \
        [list ::personal_site::worker $content $port]] \n]
    set config [dict create rootdir $content \
        max_request_read_bytes 4259840 gzip off]
    set server [::twebserver::create_server $config ::personal_site::process_conn $init]

    try {
        ::twebserver::listen_server -http -host 127.0.0.1 -num_threads 1 $server $port
        puts "Personal site: http://localhost:$port"
        puts "Content: $content"
        puts "Edit the Markdown files, then restart to see changes. Ctrl-C stops the server."
        flush stdout

        ::twebserver::wait_signal
    } finally {
        ::twebserver::destroy_server $server
    }
}

proc ::personal_site::main {arguments} {
    variable root

    if {$arguments eq {--help}} {
        puts [read_text [file join $root usage.txt]]
        return
    }

    # Prefer content in the consuming project over the installed sample files.
    set base [expr {[info exists ::env(PROJECT_HOME)] ? $::env(PROJECT_HOME) : [pwd]}]
    set content [file join $base content]
    if {![file isdirectory $content]} {
        set content [file join $root content]
    }

    set options [dict create --port 8080 --content $content]

    if {[llength $arguments] % 2} {
        error "options require values; use --help"
    }

    foreach {option value} $arguments {
        if {![dict exists $options $option] || $value eq {}} {
            error "invalid option: $option; use --help"
        }
        dict set options $option $value
    }

    set port [dict get $options --port]
    if {![string is integer -strict $port] || $port < 1 || $port > 65535} {
        error "--port must be between 1 and 65535"
    }

    set content [file normalize [file join $base [dict get $options --content]]]
    serve $content $port
}

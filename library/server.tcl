# Worker state belongs to the worker interpreter, including its database and router.
proc ::personal_site::worker {database port token} {
    variable connection [connect $database]
    variable routes [router $connection $token]
    variable listen_port $port
}

proc ::personal_site::process {context request} {
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

proc ::personal_site::serve {database content port} {
    file mkdir [file dirname $database]
    set connection [connect $database]

    # Initialization completes before the HTTP worker can accept any requests.
    try {
        if {[initialize $connection $content]} {
            puts "Initialized content in $database"
        }
    } finally {
        ::tpersist::db_disconnect $connection
    }

    set token [binary encode hex [::twebserver::random_bytes 32]]
    set init [join [list \
        [list set auto_path $::auto_path] \
        {package require example-personal-site 0.1.1} \
        [list ::personal_site::worker $database $port $token]] \n]
    set config [dict create rootdir [file dirname $database] \
        max_request_read_bytes 4259840 gzip off]
    set server [::twebserver::create_server $config ::personal_site::process $init]

    try {
        ::twebserver::listen_server -http -host 127.0.0.1 -num_threads 1 $server $port
        puts "Personal site: http://localhost:$port"
        puts "Edit or add journal entries and notebook pages in your browser. Ctrl-C stops the server."
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

    # Keep runtime data in the consuming project, outside the installed package.
    set base [expr {[info exists ::env(PROJECT_HOME)] ? $::env(PROJECT_HOME) : [pwd]}]
    set content [file join $base content]
    if {![file isdirectory $content]} {
        set content [file join $root content]
    }

    set options [dict create --port 8080 \
        --database [file join $base data personal-site.sqlite3] --content $content]

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

    set database [file normalize [file join $base [dict get $options --database]]]
    set content [file normalize [file join $base [dict get $options --content]]]
    serve $database $content $port
}

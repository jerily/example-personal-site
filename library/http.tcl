proc ::personal_site::read_text {filename} {
    set channel [open $filename r]

    try {
        fconfigure $channel -encoding utf-8
        return [read $channel]
    } finally {
        close $channel
    }
}

proc ::personal_site::header {request name} {
    if {[dict exists $request headers]} {
        dict for {key value} [dict get $request headers] {
            if {[string equal -nocase $key $name]} {
                return $value
            }
        }
    }

    return {}
}

# Editing is intended for the local operator; context comes from the HTTP server.
proc ::personal_site::authorize {request context action path} {
    expr {[dict exists $context addr] &&
        [dict get $context addr] in {127.0.0.1 ::1 ::ffff:127.0.0.1}}
}

# A new unpredictable token is created at server startup and never stored in content.
proc ::personal_site::csrf {expected action request context submitted} {
    if {$action eq "issue"} {
        return $expected
    }

    return [expr {$submitted eq $expected}]
}

proc ::personal_site::response {type body} {
    dict create statusCode 200 headers [dict create content-type $type] body $body
}

proc ::personal_site::stylesheet {request context params} {
    variable root

    response {text/css; charset=utf-8} [read_text [file join $root assets site.css]]
}

# Typed JSON keeps titles and paths as strings when passing them to Jinja.
proc ::personal_site::entries {items prefix} {
    set rows {}

    foreach item $items {
        set fields [dict create \
            title [list S [dict get $item title]] \
            url [list S $prefix[dict get $item path]]]

        if {[dict exists $item published_at]} {
            dict set fields date [list S [dict get $item published_at]]
        }

        lappend rows [list M $fields]
    }

    return [list L $rows]
}

proc ::personal_site::home {collections templates request context params} {
    set posts [lrange [::web::blog::posts [dict get $collections blog]] 0 2]
    set notes [lrange [::web::wiki::children [dict get $collections wiki] /] 0 3]
    set fields [dict create \
        title {S Home} \
        assets {S /wiki/_assets} \
        editing {BOOL 0} \
        posts [entries $posts /blog] \
        notes [entries $notes /wiki]]

    set html [::jinja2::render [dict get $templates home.html.jinja] \
        [::tjson::typed_to_json [list M $fields]] \
        -templates $templates -path home.html.jinja]

    response {text/html; charset=utf-8} $html
}

proc ::personal_site::router {connection token} {
    variable root

    set templates {}
    foreach filename {page.html.jinja home.html.jinja} {
        dict set templates $filename [read_text [file join $root assets $filename]]
    }

    set collections [stores $connection]
    set layout [dict get $templates page.html.jinja]
    set router [::tpathexp::router]

    # Mount the packages before host routes. They supply forms, assets, and revisions.
    foreach kind {wiki blog} {
        ::web::${kind}::mount $router -store [dict get $collections $kind] \
            -prefix /$kind -authorize ::personal_site::authorize \
            -csrf [list ::personal_site::csrf $token] \
            -config [dict create allow_create true master_template $layout]
    }

    $router add GET / [list ::personal_site::home $collections $templates] -strict true
    $router add GET /site.css ::personal_site::stylesheet -strict true

    return $router
}

proc ::personal_site::dispatch {router port request context} {
    # twebserver uses httpMethod; tpathexp uses method. Preserve all other fields.
    if {![dict exists $request method]} {
        dict set request method [dict get $request httpMethod]
    }

    # Reject unrelated DNS names before a request can reach the local editor.
    set host [string tolower [header $request host]]
    if {$host ni [list localhost:$port 127.0.0.1:$port]} {
        return [dict create statusCode 403 headers {content-type text/plain} body {Use the localhost URL.}]
    }

    set result [$router dispatch $request $context]

    # Editor pages contain CSRF tokens; none of this small demo needs shared caching.
    dict set result headers cache-control no-store
    dict set result headers x-content-type-options nosniff
    dict set result headers x-frame-options DENY
    dict set result headers referrer-policy same-origin

    return $result
}

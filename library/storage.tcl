# Copyright Jerily LTD. All Rights Reserved.
# SPDX-FileCopyrightText: 2026 Neofytos Dimitriou (neo@jerily.cy)
# SPDX-License-Identifier: MIT.

# The host owns connections. Each twebserver worker opens its own connection.
proc ::personal_site::connect {database} {
    ::tpersist::db_connect -database $database -autobegin 0
}

proc ::personal_site::stores {connection} {
    dict create \
        wiki [::web::wiki::create -connection $connection -title Notebook] \
        blog [::web::blog::create -connection $connection -title Journal]
}

# A persistent marker distinguishes a completed import from an empty or failed one.
# Schema creation, both imports, and the marker commit together or roll back together.
proc ::personal_site::initialize {connection content} {
    variable root
    set collections [stores $connection]
    set initialized 0

    ::tpersist::db_transaction $connection {
        ::tpersist::db_apply_schema $connection [file join $root sql schema.json] -additive true

        set query [::tpersist::db_select personal_site_state]
        set query [::tpersist::db_where $query \
            [::tpersist::db_eq [::tpersist::db_col name] [::tpersist::db_value initialized]]]
        set rows [dict get [::tpersist::db_execute $connection $query] rows]

        ::web::wiki::initdb $connection
        ::web::blog::initdb $connection

        if {![llength $rows]} {
            ::web::wiki::sync [dict get $collections wiki] [file join $content wiki]
            ::web::blog::sync [dict get $collections blog] [file join $content blog]

            set marker [::tpersist::db_values \
                [::tpersist::db_insert personal_site_state] {name initialized}]
            ::tpersist::db_execute $connection $marker
            set initialized 1
        }
    }

    return $initialized
}

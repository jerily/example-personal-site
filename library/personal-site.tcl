# Copyright Jerily LTD. All Rights Reserved.
# SPDX-FileCopyrightText: 2026 Neofytos Dimitriou (neo@jerily.cy)
# SPDX-License-Identifier: MIT.

# Load the site packages and shared storage support.
package require tpersist 0.1.4
package require Tcl 8.6 9
package require -exact web-wiki 0.1.4
package require -exact web-blog 0.1.4
package require twebserver 1.47.55

namespace eval ::personal_site {
    variable root [file dirname [file dirname [info script]]]
}

# Package files have separate responsibilities; the web packages own content editing.
foreach module {storage http server} {
    source [file join $::personal_site::root library ${module}.tcl]
}

package provide example-personal-site 0.1.3

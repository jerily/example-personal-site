# Copyright Jerily LTD. All Rights Reserved.
# SPDX-FileCopyrightText: 2026 Neofytos Dimitriou (neo@jerily.cy)
# SPDX-License-Identifier: MIT.

# Load the read-only content packages.
package require Tcl 8.6 9
package require -exact web-static-wiki 0.1.8
package require -exact web-static-blog 0.1.7
package require twebserver 1.47.58
package require tpathexp 1.2.0

namespace eval ::personal_site {
    variable root [file dirname [file dirname [info script]]]
}

# The content packages own Markdown reading and rendering.
foreach module {content http server} {
    source [file join $::personal_site::root library ${module}.tcl]
}

package provide example-personal-site 0.2.0

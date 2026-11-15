# Copyright Jerily LTD. All Rights Reserved.
# SPDX-FileCopyrightText: 2026 Neofytos Dimitriou (neo@jerily.cy)
# SPDX-License-Identifier: MIT.

# Each worker reads a fresh snapshot of the trusted Markdown directories.
proc ::personal_site::stores {content} {
    dict create \
        wiki [::web::static::wiki::create -directory [file join $content wiki] -title Notebook] \
        blog [::web::static::blog::create -directory [file join $content blog] -title Journal]
}

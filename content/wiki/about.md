# About this site

Welcome! This is a working personal-site example for Tcl programmers, developers, and engineers. Alex Rivers is a fictional profile: replace the name and introduction with your own.

## Make yourself at home

Use **Edit** to change this page. Choose **New page** in the notebook or **New post** in the journal to add something of your own. The editor offers both a visual mode and Markdown source.

Your changes are saved in SQLite, along with revision history. Restarting the server does not replace them with the sample files.

## Follow the code

- `library/storage.tcl` opens SQLite and performs the first import atomically.
- `library/http.tcl` mounts `web-wiki` and `web-blog` on a `tpathexp` router.
- `library/server.tcl` starts a single local `twebserver` worker.
- `assets/` contains the host templates and stylesheet.
- `content/` contains the initial Markdown. It is read only during initialization.

This demonstration serves only on localhost. There is no cloud setup or account to create.

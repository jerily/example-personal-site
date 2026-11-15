# About this site

Welcome! This is a working personal-site example for Tcl programmers, developers, and engineers. Alex Rivers is a fictional profile: replace the name and introduction with your own.

## Make yourself at home

Edit `content/wiki/about.md` in your text editor, save it, and restart the server. Add notebook pages under `content/wiki/` and dated journal entries under `content/blog/`.

Your Markdown files are the source of truth. The browser presents the finished pages; writing happens in your own editor.

## Follow the code

- `library/content.tcl` reads the notebook and journal directories.
- `library/http.tcl` mounts `web-static-wiki` and `web-static-blog` on a `tpathexp` router.
- `library/server.tcl` starts a single local `twebserver` worker.
- `assets/` contains the host templates and stylesheet.
- `content/` contains the Markdown, read afresh at startup.

The local preview needs no database, cloud setup, or account.

![A notebook and a growing personal website](notebook.svg)

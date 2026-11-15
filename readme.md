# example-personal-site

A personal homepage, journal, and notebook for Tcl developers. Write Markdown in
your editor; `web-static-wiki` and `web-static-blog` serve it read-only with a
shared design. The example runs a Tcl HTTP server and does not export an HTML
build directory.

## Start with your own copy

```sh
ttrek clone example-personal-site -outdir my-personal-site
cd my-personal-site
ttrek install -y
ttrek run -script start
```

Open **http://localhost:8080**. Stop with Ctrl-C. From an existing source checkout,
run just `ttrek install -y` and `ttrek run -script start`.
`clone` downloads source, without dependencies or Git history; no `ttrek init`
is needed because the example already includes `ttrek.json`.

You can also try the installed package in an initialized ttrek project:

```sh
ttrek install -y example-personal-site@0.2.0
ttrek run -package example-personal-site -script start
```

The example pins its content packages and uses `tpathexp` ^1.2.0. Routing
belongs to `tpathexp`; `twebserver` calls the site's `process_conn` callback.

Optional arguments work with either start script:

```sh
ttrek run -script start -- --port 8090 --content ./content
```

The installed `bin/example-personal-site` launcher also runs directly when the
dependencies are on the Tcl package path. `TCLSH` selects an interpreter.
Under ttrek, relative paths resolve against `PROJECT_HOME`. A project-local
`content/` takes precedence over the installed samples; `--content` selects
another root. The `wiki/`, `blog/`, and `images/` subdirectories must exist, even if empty.

## Make it yours

Alex Rivers is a fictional sample profile. Edit `assets/page.html.jinja` for your
name, monogram and shared navigation; `assets/home.html.jinja` for your
introduction; and `assets/site.css` for colors, spacing and typography.

Write notebook pages in `content/wiki/`, for example `about.md`. Add journal
entries with dated filenames such as `content/blog/2026-11-15-hello.md`.
The first heading provides the display title; filenames determine URLs:

| File | URL |
| --- | --- |
| `content/wiki/about.md` | `/wiki/about` |
| `content/wiki/projects/first-tool.md` | `/wiki/projects/first-tool` |
| `content/blog/2026-11-15-hello.md` | `/blog/2026-11-15-hello` |

Restart after changing Markdown or templates, then refresh your browser.
New files appear in the lists, deleted files disappear, and title changes keep
the same URL. Journal entries are ordered by filename date, newest first;
future-dated files are visible too. Keep drafts outside `content/`.

The Markdown files are the source of truth. Back up or version your content,
templates and stylesheet. No database, import command, account, browser editor,
or revision table is involved in this example. The content packages also support
SQL stores, but this host uses their directory API.

## Add images

Put pictures in `content/images/`, for example `content/images/photo.jpg`.
Use `![My photo](photo.jpg)` in any notebook page or journal post. Subfolders
work too: `![My project](projects/photo.jpg)` reads
`content/images/projects/photo.jpg`. Restart after adding files.

The shared Tcl image renderer turns those references into `/images/...` URLs,
independent of the page's address. The `tpathexp` image route serves the original
bytes through `twebserver`. PNG, JPEG, GIF, WebP, AVIF, SVG, ICO and BMP are
supported, up to 20 MiB each. Image references cannot escape the image directory.
No AWS settings are needed for local images.

## How it works

| File | Responsibility |
| --- | --- |
| `main.tcl` | Load the package and report startup errors |
| `library/personal-site.tcl` | Dependencies and module loading |
| `library/content.tcl` | Create notebook and journal directory stores |
| `library/http.tcl` | Mount packages, render the homepage, and serve CSS |
| `library/server.tcl` | CLI options and one local HTTP worker |
| `assets/` | Shared layout, homepage, and responsive CSS |
| `content/wiki/`, `content/blog/` | Markdown source |
| `start.sh` | File-based ttrek start script |
| `bin/example-personal-site` | Source/installed launcher |

Startup validates the content and templates before listening. The worker creates
its own stores and router, mounts the wiki at `/wiki` and the blog at `/blog`,
and adds `/`, `/site.css`, and `/images/...`. The stores remain unchanged for that process;
a restart reads the files again. Templates and CSS live in `assets/`; Tcl code
does not build HTML strings.


## Verification

With dependencies on the Tcl package path:

```sh
ttrek run tclsh9.1 tests/all.tcl
ttrek run python3 tests/http_test.py tclsh9.1
```

Tests cover content validation, filename-based links, read-only routes, empty
collections, and refreshing file additions, changes and deletions after restart.
The HTTP suite exercises the real launcher and server. Installation needs only
CMake for this pure Tcl package:

```sh
cmake -S . -B build -DBUILD_TESTING=OFF
cmake --install build --prefix "$PWD/stage"
```

## Hosting

The launcher is a local preview: it binds to loopback and accepts only
localhost/127.0.0.1 Host headers. Packages expose GET/HEAD content routes, render
safe Markdown, and escape metadata. The host bounds requests and adds response
headers.

Production AWS deployment instructions are pending the CloudFormation template
updates. This repository currently has no production deploy script, Lambda
adapter, or static HTML export. Configuring AWS credentials alone does not
publish the site. Keep deployment credentials outside the source tree.

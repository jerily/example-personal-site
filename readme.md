# example-personal-site

A local personal site for Tcl developers: a journal, notebook, and browser editor backed by SQLite.

## Rules

- Keep the example small, readable, and runnable with one start command.
- Serve through `twebserver` on `127.0.0.1` only. No cloud services are involved.
- Import `content/` once; preserve browser changes on every later start.

## Principles

The host owns startup, connections, local editing policy, and the router.
`web-wiki` and `web-blog` own their schemas, content rules, editors, and revisions.
Templates and CSS live in `assets/`; Tcl code does not build HTML strings.

## Start

In an initialized ttrek project:

```sh
ttrek install -y example-personal-site
ttrek run -package example-personal-site -script start
```

Open **http://localhost:8080**. Edit any notebook page or journal entry, or use
**New page** / **New post** to add one. Stop with Ctrl-C and run the same command
again; your changes remain in `data/personal-site.sqlite3`.

From a source checkout:

```sh
ttrek install -y
ttrek run -script start
```

The installed `bin/example-personal-site` launcher can also run directly when
the dependencies are on the Tcl package path. `TCLSH` selects an interpreter.
The package supports Tcl 8.6 and 9.x with matching native dependencies.

Optional arguments use the same start script:

```sh
ttrek run -package example-personal-site -script start -- \
  --port 8090 --database ./data/demo.sqlite3 --content ./content
```

Named-script argument forwarding requires a current ttrek build. Use `--help`
for defaults. Under ttrek, relative paths resolve against `PROJECT_HOME`.

## How the example works

| File | Responsibility |
| --- | --- |
| `main.tcl` | Load the package and report startup errors |
| `library/personal-site.tcl` | Dependencies and module loading |
| `library/storage.tcl` | Connections and transactional first-run initialization |
| `library/http.tcl` | Package mounts, homepage, local policy, and CSRF |
| `library/server.tcl` | CLI options and one local HTTP worker |
| `assets/` | Shared page layout, homepage, and responsive CSS |
| `content/wiki/`, `content/blog/` | Initial Markdown |
| `bin/example-personal-site` | Source/installed launcher |

Startup creates a connection with `-autobegin 0`. One transaction creates both
package schemas, imports both directories, and records an initialization marker.
A failed import rolls back the whole operation and is retried on the next start.
An existing empty database is initialized too; file existence is not the check.

Once initialized, startup does not read the content directories again. Browser
edits, new items, and their history remain in SQLite, even if seed files change
or disappear. To try a fresh seed, choose another `--database` path.

After initialization, the startup connection closes. A single twebserver worker
opens its own connection and router. The wiki mounts at `/wiki`, the blog at
`/blog`, and the host adds `/` and `/site.css`. Both mounts enable `allow_create`
and use the same master template. No package internals are called.

## Make it yours

Alex Rivers is a fictional sample profile. Change the identity in
`assets/page.html.jinja`, the introduction in `assets/home.html.jinja`, and the
homepage title in `library/http.tcl`. Adjust the palette in `assets/site.css`.
The journal and notebook lists on the homepage come from SQLite.

Place Markdown in `content/wiki` and dated files such as `2026-11-07-hello.md`
in `content/blog` before the first start. A project-local `content/` takes
precedence over the bundled sample; `--content` selects another directory.
Both subdirectories must exist. After initialization, write through the browser.

## Verification

With dependencies on `TCLLIBPATH`, run `tclsh tests/all.tcl`. Tests cover atomic
initialization, restart persistence, browser creation/editing, CSRF, and routing.
`python3 tests/http_test.py /path/to/tclsh` exercises the real server and launcher.
Installation needs only CMake; no compiler or JavaScript build is required:

```sh
cmake -S . -B build -DBUILD_TESTING=OFF
cmake --install build --prefix "$PWD/stage"
```

## Security

### Surface

This local demonstration enables editing and creation without a login.
Do not put it behind a public reverse proxy or expose it through a tunnel.

### Protections

The server binds to loopback, accepts only localhost/127.0.0.1 Host headers,
checks the connection's loopback address for editing, and verifies an
unpredictable startup CSRF token. Requests are bounded. Package handlers bind
SQL values, escape template data, render safe Markdown, and reject stale edits.

### Pending

Public hosting and multi-user authentication are outside this example's scope.
Stop the server before copying its SQLite file for a simple backup.

# What happens when you open a page?

Type `http://localhost:8080/wiki/about` into your browser. A page appears. What happened between those two moments?

You can understand this little site by following three jobs: finding the right page, turning the writing into HTML, and sending the result back.

## 1. The browser asks for an address

`localhost` means your own computer. `8080` is the port where the preview server listens. `/wiki/about` is the path you want.

The browser sends a GET request. In everyday language, that means “please give me this page.” `twebserver` receives the request and passes it to the site's handler.

## 2. The router chooses who answers

A router is like the reception desk in a small building. It looks at the path and sends the request to the right place.

This site's router uses `tpathexp`. Requests beginning with `/wiki` go to `web-static-wiki`; requests beginning with `/blog` go to `web-static-blog`. The host handles the homepage at `/`.

The content packages read your Markdown directories at startup. They know which filenames correspond to which paths. `about.md` becomes `/wiki/about`; a heading inside the file supplies the displayed title.

## 3. The page gets its frame

Markdown describes your writing. HTML describes a page the browser can display. The content package renders the Markdown and places it inside a Jinja template.

A template is a reusable page frame. It gives every page the same navigation, name, and footer, while leaving space for a different title and body. CSS supplies the colors and spacing.

The server sends the finished HTML back. The browser displays it and requests the stylesheets it needs.

## Why keep these jobs separate?

You can change a paragraph without changing the router. You can change the colors without rewriting the content reader. Each piece has a small job you can understand.

Try following one request in `library/http.tcl`. Find the two package mounts, then the homepage route. You do not need to understand the whole application at once: one address, one handler, and one response are enough to start.

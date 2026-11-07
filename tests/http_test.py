"""Exercise the launcher, real HTTP transport, edits, and restart persistence."""

import html
import os
from pathlib import Path
import re
import signal
import socket
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request


ROOT = Path(__file__).resolve().parents[1]


def fetch(url, fields=None):
    data = None if fields is None else urllib.parse.urlencode(fields).encode()
    with urllib.request.urlopen(url, data=data, timeout=3) as response:
        return response.read().decode()


def start(database, port, log):
    environment = dict(os.environ, TCLSH=sys.argv[1])
    process = subprocess.Popen(
        [str(ROOT / "bin/example-personal-site"), "--port", str(port),
         "--database", str(database), "--content", str(ROOT / "content")],
        cwd=ROOT, env=environment, stdout=log, stderr=log,
    )
    for _ in range(100):
        if process.poll() is not None:
            raise AssertionError("server exited during startup")
        try:
            fetch(f"http://localhost:{port}/")
            return process
        except (OSError, urllib.error.URLError):
            time.sleep(0.05)

    process.terminate()
    process.wait(timeout=5)
    raise AssertionError("server did not become ready")


def stop(process):
    process.send_signal(signal.SIGTERM)
    process.wait(timeout=5)


def main():
    with socket.socket() as listener:
        listener.bind(("127.0.0.1", 0))
        port = listener.getsockname()[1]

    base = f"http://localhost:{port}"
    with tempfile.TemporaryDirectory() as folder:
        database = Path(folder) / "site.sqlite3"
        with tempfile.TemporaryFile(mode="w+") as log:
            try:
                process = start(database, port, log)
                try:
                    homepage = fetch(base + "/")
                    assert "Fresh from the workbench" in homepage

                    for kind in ("wiki", "blog"):
                        form = fetch(base + f"/{kind}/_new")
                        token = html.unescape(re.search(r'name="csrf" value="([^"]+)"', form)[1])
                        fields = {"title": "HTTP entry", "markdown": "Written over HTTP", "csrf": token}
                        path = "/http-entry"
                        if kind == "blog":
                            fields["published_at"] = "2026-11-07"
                            path = "/2026-11-07-http-entry"

                        assert "Written over HTTP" in fetch(base + f"/{kind}/_new", fields)
                        fields.update(markdown="Edited over HTTP", revision="1")
                        fields.pop("published_at", None)
                        assert "Edited over HTTP" in fetch(base + f"/{kind}/_edit{path}", fields)
                finally:
                    stop(process)

                process = start(database, port, log)
                try:
                    for path in ("/wiki/http-entry", "/blog/2026-11-07-http-entry"):
                        assert "Edited over HTTP" in fetch(base + path)
                finally:
                    stop(process)
            except Exception:
                log.seek(0)
                print(log.read(), file=sys.stderr)
                raise

    print("HTTP smoke passed: first start, wiki/blog creation and editing, restart persistence.")


if __name__ == "__main__":
    main()

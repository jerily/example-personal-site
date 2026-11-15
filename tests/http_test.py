"""Exercise the launcher, read-only HTTP routes, and Markdown edits across restarts."""

import os
from pathlib import Path
import signal
import shutil
import socket
import subprocess
import sys
import tempfile
import time
import urllib.error
import urllib.request

ROOT = Path(__file__).resolve().parents[1]
LAUNCHER = Path(sys.argv[2]) if len(sys.argv) > 2 else ROOT / "bin/example-personal-site"


def fetch(url, method="GET", binary=False):
    request = urllib.request.Request(url, method=method)
    try:
        with urllib.request.urlopen(request, timeout=3) as response:
            body = response.read()
            return response.status, body if binary else body.decode()
    except urllib.error.HTTPError as error:
        return error.code, error.read().decode()


def start(content, port, log):
    environment = dict(os.environ, TCLSH=sys.argv[1])
    process = subprocess.Popen(
        [str(LAUNCHER), "--port", str(port), "--content", str(content)],
        cwd=content.parent, env=environment, stdout=log, stderr=log,
    )
    for _ in range(100):
        if process.poll() is not None:
            raise AssertionError("server exited during startup")
        try:
            if fetch(f"http://localhost:{port}/")[0] == 200:
                return process
        except (OSError, urllib.error.URLError):
            pass
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
        content = Path(folder) / "content"
        shutil.copytree(ROOT / "content", content)
        image_bytes = bytes.fromhex("89504e470d0a1a0a00ff80")
        (content / "images/photo.png").write_bytes(image_bytes)
        (content / "wiki/nested").mkdir()
        (content / "wiki/nested/image.md").write_text("# Image\n![Photo](photo.png)")
        (content / "blog/2026-11-16-images.md").write_text("# Images\n![Photo](photo.png)")
        with tempfile.TemporaryFile(mode="w+") as log:
            try:
                process = start(content, port, log)
                try:
                    assert "Fresh from the workbench" in fetch(base + "/")[1]
                    for path in ("/wiki/about", "/blog/2026-11-07-small-tools",
                                 "/wiki/_assets/style.css", "/blog/_assets/style.css", "/site.css"):
                        assert fetch(base + path)[0] == 200, path
                    for kind in ("wiki", "blog"):
                        assert fetch(base + f"/{kind}/_new")[0] == 404
                        assert fetch(base + f"/{kind}/_new", "POST")[0] == 405
                    assert fetch(base + "/wiki/about", "HEAD") == (200, "")
                    for path in ("/wiki/nested/image", "/blog/2026-11-16-images"):
                        assert 'src="/images/photo.png"' in fetch(base + path)[1]
                    assert fetch(base + "/images/photo.png", binary=True) == (200, image_bytes)
                    assert fetch(base + "/images/photo.png", "HEAD", binary=True) == (200, b"")
                    assert fetch(base + "/images/%2e%2e/secret.png")[0] == 400
                    assert fetch(base + "/images/not-present.png")[0] == 404
                    (content / "wiki/about.md").write_text("# A new title\nChanged in a file.\n")
                    (content / "wiki/hello.md").write_text("# Hello\nA new note.\n")
                    (content / "blog/2026-11-15-hello.md").write_text("# Hello journal\nA new post.\n")
                    (content / "wiki/reading.md").unlink()
                    assert "Changed in a file." not in fetch(base + "/wiki/about")[1]
                finally:
                    stop(process)

                process = start(content, port, log)
                try:
                    assert "Changed in a file." in fetch(base + "/wiki/about")[1]
                    assert "A new note." in fetch(base + "/wiki/hello")[1]
                    assert "A new post." in fetch(base + "/blog/2026-11-15-hello")[1]
                    assert "Hello journal" in fetch(base + "/")[1]
                    assert fetch(base + "/wiki/reading")[0] == 404
                    assert not list(Path(folder).rglob("*.sqlite3"))
                finally:
                    stop(process)
            except Exception:
                log.seek(0)
                print(log.read(), file=sys.stderr)
                raise

    print("HTTP smoke passed: read-only routes, Markdown edits, additions and deletions after restart.")


if __name__ == "__main__":
    main()

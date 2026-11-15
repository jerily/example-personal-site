#!/bin/sh
set -eu

# Package recipes may cache this script outside the original source checkout.
site_project=${PROJECT_HOME:-$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)}
if [ -x "$site_project/bin/example-personal-site" ]; then
    exec "$site_project/bin/example-personal-site" "$@"
fi

# ttrek places installed package launchers on PATH.
exec example-personal-site "$@"

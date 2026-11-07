# Tcl field notes

A few patterns worth keeping close to the keyboard.

## Close what you open

`try` and `finally` make ownership visible, even when reading fails:

```tcl
set channel [open $filename r]

try {
    fconfigure $channel -encoding utf-8
    set text [read $channel]
} finally {
    close $channel
}
```

## Build command prefixes as lists

```tcl
set handler [list ::myapp::show_page $store]
$router add GET /notes $handler
```

List construction preserves argument boundaries. It also makes the callback's dependencies easy to see.

## Keep state near its owner

Open a database connection inside the interpreter that will use it. Pass a store or a connection explicitly where practical. A small procedure with visible inputs is easier to read and test.

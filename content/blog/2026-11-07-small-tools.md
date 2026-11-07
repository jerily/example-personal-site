# In praise of small, useful tools

There is something satisfying about a tool you can understand in an afternoon. One entry point. A few well-named procedures. Data you can back up by stopping the process and copying a file.

This little site is an experiment in that direction. Tcl connects the pieces, SQLite keeps the words, and the browser gives us a comfortable place to write.

## Start with the lifecycle

Before adding features, decide what happens when the program starts, handles a request, and stops. In this example, initialization finishes before the server listens. Each worker then opens its own connection.

That small boundary keeps import work out of request handlers and makes the application easier to reason about.

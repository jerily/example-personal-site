# One command, and a place to write

The first version of a personal site should make starting easy. This example needs no separate database setup or import command.

```sh
ttrek install -y example-personal-site
ttrek run -package example-personal-site -script start
```

On the first run, the startup code creates the tables and imports the Markdown in `content/wiki` and `content/blog`. It records completion in the same transaction.

On later runs, that marker tells the application to use the existing database. Your browser edits and new pages remain yours.

The next step is simple: replace this sample entry with something you want to say.

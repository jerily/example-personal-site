# Your first page starts with a plain text file

A website can feel like a big project before you have written anything. Start with one page instead. Say who you are, write down something useful, and give yourself a reason to come back.

This example already supplies the layout and the server. To get your own copy of the static edition with version 0.2.1:

```sh
ttrek clone example-personal-site@0.2.1 -outdir my-personal-site
cd my-personal-site
ttrek install -y
ttrek run -script start
```

The first command copies the example. The second moves into your copy. The third gets the building blocks it needs. The last starts a preview at `http://localhost:8080`.

## Write something small

Open `content/wiki/about.md` in a text editor. Replace the sample introduction with three sentences:

- Who are you?
- What do you like making or learning?
- What will you write about here?

Keep the first line as a heading, such as `# About me`. That `#` is Markdown's way of saying “this is a heading.” You can write ordinary paragraphs beneath it without learning HTML.

## Save, restart, refresh

Save the file. In the terminal running the server, press Ctrl-C, then run `ttrek run -script start` again. Refresh the browser and open `/wiki/about`.

Why restart? The server reads the files when it starts. Think of it as taking a photograph of your notebook: changing the notebook does not change the old photograph. Starting again takes a new one.

The filename `about.md` chooses the address `/wiki/about`. The heading chooses the title people see. Changing the title does not move the page.

## A useful first milestone

You now have a page you understand and can change. Keep a copy of your project, then add one more page about something you learned. A small site with a useful explanation is already worth visiting.

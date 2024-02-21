---
syntax: markdown
tags: [tldr, common]
source: https://github.com/tldr-pages/tldr.git
---
# coffee

> Executes CoffeeScript scripts or compiles them into JavaScript.
> More information: <https://coffeescript.org#cli>.

- Run a script:

`coffee {{path/to/file.coffee}}`

- Compile to JavaScript and save to a file with the same name:

`coffee --compile {{path/to/file.coffee}}`

- Compile to JavaScript and save to a given output file:

`coffee --compile {{path/to/file.coffee}} --output {{path/to/file.js}}`

- Start a REPL (interactive shell):

`coffee --interactive`

- Watch script for changes and re-run script:

`coffee --watch {{path/to/file.coffee}}`

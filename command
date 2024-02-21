---
syntax: markdown
tags: [tldr, common]
source: https://github.com/tldr-pages/tldr.git
---
# command

> Command forces the shell to execute the program and ignore any functions, builtins and aliases with the same name.
> More information: <https://manned.org/command>.

- Execute the `ls` program literally, even if an `ls` alias exists:

`command {{ls}}`

- Display the path to the executable or the alias definition of a specific command:

`command -v {{command_name}}`

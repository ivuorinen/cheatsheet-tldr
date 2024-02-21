# ivuorinen/cheatsheet-tldr

This repository is a collection of [cheat/cheat](https://github.com/cheat/cheat)
compatible cheatsheets derived from [tldr](https://github.com/tldr-pages/tldr) pages.

## Installation

Add the cheatsheets to your `cheat` installation by cloning this repository to
`~/.cheat/cheatsheets/tldr`:

```sh
git clone https://github.com/ivuorinen/cheatsheet-tldr.git ~/.cheat/cheatsheets/tldr
```

Configure your `cheat.yaml` to include the cheatsheets:

```yaml
- name: tldr
  path: ~/.cheat/cheatsheets/tldr/tldr
  tags: [tldr]
  readonly: true
```

## Usage

Use `cheat` as you normally would, but include the `tldr` tag to filter the
cheatsheets:

```sh
cheat --tags tldr
```

## License

Files under `.github/` are licensed under the [MIT License](LICENSE.md).
TLDR pages under `tldr/` licensed under [CC-BY-4.0](https://github.com/tldr-pages/tldr/blob/main/LICENSE.md).

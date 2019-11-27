# ⌚ Unfog.vim

A Vim plugin for [Unfog](https://github.com/unfog-io/unfog-cli), a simple task
and time manager written in [Haskell](https://www.haskell.org).

![image](https://user-images.githubusercontent.com/10437171/69494189-cd56a380-0eb8-11ea-9b9c-b7a441d6e941.png)

## Table of contents

  * [Installation](#installation)
  * [Usage](#usage)
    * [Create](#create)
    * [Show](#show)
    * [Update](#update)
    * [Toggle](#toggle)
    * [Done/Delete](#donedelete)
    * [Context](#context)
    * [Worktime](#worktime)
  * [Mappings](#mappings)
  * [Contributing](#contributing)
  * [Changelog](#changelog)
  * [Credits](#credits)

## Installation

First you need to install the [unfog
CLI](https://github.com/unfog-io/unfog-cli#installation):

```bash
curl -sSL https://raw.githubusercontent.com/unfog-io/unfog-cli/master/install.sh | sh
```

Then you can install this plugin with your favorite plugin manager. For eg:
with [vim-plug](https://github.com/junegunn/vim-plug), add to your `.vimrc`:

```viml
Plug "unfog-io/unfog-vim"
```

Then:

```viml
:PlugInstall
```

## Usage

It is recommanded to first read [the Unfog CLI
documentation](https://github.com/unfog-io/unfog-cli#usage) to understand the
concept.

To list tasks:

```viml
:Unfog
```

Then you can manage tasks using Vim mapping. The table will automatically
readjust on buffer save (`:w`). Also have a look at the [mappings](#mappings)
section for special actions.

### Create

![gif](https://user-images.githubusercontent.com/10437171/69496343-8d4fea80-0ed1-11ea-8dc0-bea520390104.gif)

### Show

![gif](https://user-images.githubusercontent.com/10437171/69496439-84134d80-0ed2-11ea-9737-64e4ac11c88c.gif)

### Update

![gif](https://user-images.githubusercontent.com/10437171/69496694-069d0c80-0ed5-11ea-8d54-9c06aeaead4c.gif)

### Toggle

![gif](https://user-images.githubusercontent.com/10437171/69496733-6a273a00-0ed5-11ea-85a3-8afdde52511c.gif)

### Done/Delete

![gif](https://user-images.githubusercontent.com/10437171/69496764-b8d4d400-0ed5-11ea-97fb-d8799f961c62.gif)

### Context

![gif](https://user-images.githubusercontent.com/10437171/69496799-444e6500-0ed6-11ea-95f8-32a72c86bcbd.gif)

### Worktime

![gif](https://user-images.githubusercontent.com/10437171/69496824-91cad200-0ed6-11ea-9da5-b21b6c1f3390.gif)

## Mappings

Here the default mappings:

| Function | Mapping |
| --- | --- |
| Toggle task | `<CR>` |
| [Show task infos](#show) | `K` |
| [Set context](#context) | `gc` |
| [Show worktime](#worktime) | `gw` |
| Jump to the next cell | `<C-n>` |
| Jump to the prev cell | `<C-p>` |
| Delete in cell | `dic` |
| Change in cell | `cic` |
| Visual in cell | `vic` |

You can customize them:

```vim
nmap <cr>   <plug>(unfog-toggle)
nmap K      <plug>(unfog-info)
nmap gc     <plug>(unfog-context)
nmap gw     <plug>(unfog-worktime)
nmap <c-n>  <plug>(unfog-next-cell)
nmap <c-p>  <plug>(unfog-prev-cell)
nmap dic    <plug>(unfog-delete-in-cell)
nmap cic    <plug>(unfog-change-in-cell)
nmap vic    <plug>(unfog-visual-in-cell)
```

## Contributing

Git commit messages follow the [Angular
Convention](https://gist.github.com/stephenparish/9941e89d80e2bc58a153), but
contain only a subject.

  > Use imperative, present tense: “change” not “changed” nor
  > “changes”<br>Don't capitalize first letter<br>No dot (.) at the end

Code should be as clean as possible, variables and functions use the camel case
convention. A line should never contain more than `80` characters.

Tests should be added for each new functionality. Be sure to run tests before
proposing a pull request.

## Changelog

- **Nov. 24, 2019** - First release v0.1.0

## Credits

- [Taskwarrior](https://taskwarrior.org), a task manager
- [Timewarrior](https://taskwarrior.org/docs/timewarrior), a time tracker
- [vim-taskwarrior](https://github.com/blindFS/vim-taskwarrior), a Taskwarrior wrapper for vim
- [vimwiki](https://github.com/vimwiki/vimwiki), for the idea of managing tasks inside a buffer
- [Kronos](https://github.com/soywod/kronos.vim), the Unfog predecessor

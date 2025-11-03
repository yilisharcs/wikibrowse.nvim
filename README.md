# wikibrowse.nvim

Browse wikipedia articles from the comfort of your favorite editor.

## Installation

Using Neovim's built-in package manager:

```sh
mkdir -p ~/.config/nvim/pack/yilisharcs/start
cd ~/.config/nvim/pack/yilisharcs/start
git clone https://github.com/yilisharcs/wikibrowse.nvim.git
```

<!-- # vim -u NONE -c "helptags wikibrowse.nvim/doc" -c q -->
<!-- TODO: helptags command? -->

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
    "yilisharcs/wikibrowse.nvim",
    dependencies = {
        -- Optional
        -- "folke/snacks.nvim" -- For image rendering
    }
    init = function()
        vim.g.wikibrowse = {}
    end
}
```

> [!NOTE]
>
> No setup or require needed; simply place it in your runtimepath to use.

### Dependencies

- `neovim` v0.11.4+
- `nushell` v0.107.0+
- `pandoc` v3.1.11.1+

## Configuration

Wikibrowse.nvim uses a global table for configuration. User options are merged
with the default table prior to initialization unless `vim.g.wikibrowse.default`
is set to false. Below are the available options and their default values:

```lua
local width = math.floor(vim.o.columns * 0.79)
local height = math.floor(vim.o.lines * 0.63)
local col = math.floor((vim.o.columns - width) / 2) -- Center the window
local row = math.floor((vim.o.lines - height) / 2) - 2

vim.g.wikibrowse = {
    lang = "en",
    winopts = {
        width  = width,
        height = height,
        col    = col,
        row    = row,
    }
}
```

## Usage

Fetching an article is as simple as running the following command:

```vim
:Wikibrowse <args>

" Examples
:Wikibrowse pizza
:Wikibrowse pizza tower
:Wikibrowse domino's pizza
:Wikibrowse 披萨
```

> [!TIP]
>
> Leverage built-in Neovim features to make navigation more pleasant:

- Jump between headings with `]]` and `[[`
- View the Table of Contents with `gO`

## License

Copyright (C) 2025 yilisharcs <yilisharcs@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

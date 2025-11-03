# TODO

- [ ] 1.0 Milestones:
    * [x] Handle footnotes correctly
    * [ ] Chop up navboxes and fold them
    * [ ] Convert infobox and assorted tables
    * [x] Format wikilinks, removing extra attributes
    - [ ] Convert non-reflist superscript
- [x] Find out what is the minimum version this plugin supports:
    * [x] Neovim: (Use `vim.version().minor` instead of `vim.fn.has`)
    * [x] Nushell: Building with `v0.107.0`
    * [x] Pandoc: Building with `v3.1.11.1`
- [ ] Opt-in/out UI elements:
    * [ ] Portals
    * [ ] Bottom-page categories
    * [ ] "Edit" buttons
- [ ] Reverse footnote search (for references that point to the same footnote)
- [ ] Open links for `Wikipedia:` `Special:` `Help:`
- [ ] How to handle links that contain description, article link, and image link?
    Potential solution: put image links inside less than signs, like so
    > `Message [with](foo) [links](bar) <link>`
- [ ] Remove extra caption under lone images
- [ ] Format wiktionary links
- [ ] Disambiguation pages should be pretty too
- [ ] Some search extracts are dreadfully short. Investigate
- [ ] Main command needs a lang=<lang> option to override the table
- [ ] Langlinks?
- [ ] Write a proper help file (`:h help-writing`)
    - [ ] Provided highlight groups go here
- [ ] Fix wikiget interaction with `:bd`
- [ ] Add demo images, gif, or video
- [ ] Create a luarc json to make luals shut up about global pandoc variable
- [ ] Remove dependency on Nushell (now depends on nvim 0.11.0)

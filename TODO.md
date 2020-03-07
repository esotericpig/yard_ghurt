# TODO | YardGhurt

## [v2.0.0]
- [ ] Extract out AnchorLinks (and App) and put into a new Gem/project called "anclids" (Anchor + Links + IDs)
    - Anclids::Yard
    - Anclids::GitHub
    - Anclids top module has convenience methods for using Yard/GH
    - CLI app code will also be moved here
    - Probably under MIT license instead of LGPL?
    - Also will need code for gsubbing a file, since needed in YardGhup (below)
- [ ] Create a new project called "yard_ghup" (p is for plugin)
    - Create a yard plugin that can be used in `--plugin` option (and `.yardopts`)
    - Use Anclids common code to gsub files
    - Look at [this project](https://github.com/haines/yard-relative_markdown_links/blob/master/lib/yard/relative_markdown_links.rb) for inspiration?
        - I don't want to use Nokogiri, too big of a dependency for something so simple, even though it ensures correct parsing. It also requires OS-dependent libraries.
        - I don't like how he created the plugin, seems hacky. Is there a better way to hook in so can gsub files?

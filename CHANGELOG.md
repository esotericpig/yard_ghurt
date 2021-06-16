# Changelog | YardGhurt

All notable changes to this project will be documented in this file.

Format is based on [Keep a Changelog v1.0.0](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning v2.0.0](https://semver.org/spec/v2.0.0.html).

## [[Unreleased]](https://github.com/esotericpig/yard_ghurt/compare/v1.2.1...HEAD)
-


## [v1.2.1] - 2021-06-16
### Fixed
- Fixed to work with YARD v0.9.25+
    - From v0.9.25, YARD changed to use RedCarpert's method of trying to create GitHub-style anchor links. RedCarpet does NOT match GitHub's algorithm exactly, so it all got messed up. I changed the code to grab the new `id="..."` field from `<h\d+...` tags and use that as the YARD ID. I tried recreating RedCarpert's C code (`rndr_header_anchor()` in `ext/redcarpet/html.c`) but this failed miserably, so resorted to just this. All that matters is that it works!

### Changed
- Formatted code using RuboCop.


## [v1.2.0] - 2020-02-29
### Added
- bin/yard_ghurt
    - For getting the GitHub/YARDoc anchor link ID from a string
- App class
- AnchorLinks.escape()

### Changed
- README to talk about bin/yard_ghurt

### Fixed
- In AnchorLinks, don't use obsolete method URI.escape()/encode()
    - This outputted a lot of warnings


## [v1.1.0] - 2019-07-31
### Added
- Added environment var *dryrun* to GFMFixTask:
    - rake yard_gfm_fix dryrun=true

### Changed
- Renamed GFMFixerTask to GFMFixTask
    - lib/yard_ghurt/gfm_fixer_task.rb => lib/yard_ghurt/gfm_fix_task.rb
- Renamed GHPSyncerTask to GHPSyncTask
    - lib/yard_ghurt/ghp_syncer_task.rb => lib/yard_ghurt/ghp_sync_task.rb
- Updated development dependency gems


## [v1.0.1] - 2019-07-28
### Changed
- Some minor comments/doc
- Refactored the Gemspec (minor)

### Fixed
- In GFMFixerTask, ignore empty lines


## [v1.0.0] - 2019-07-23
### Added
- .gitignore
- CHANGELOG.md
- Gemfile
- LICENSE.txt
- README.md
- Rakefile
- yard_ghurt.gemspec
- lib/yard_ghurt.rb
- lib/yard_ghurt/anchor_links.rb
- lib/yard_ghurt/gfm_fixer_task.rb
- lib/yard_ghurt/ghp_syncer_task.rb
- lib/yard_ghurt/util.rb
- lib/yard_ghurt/version.rb
- yard/templates/default/layout/html/footer.erb

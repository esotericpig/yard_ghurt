# Changelog | YardGhurt

Format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [[Unreleased]](https://github.com/esotericpig/yard_ghurt/compare/v1.1.0...master)

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

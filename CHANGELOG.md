Changelog for Fryse 0.x
=======================

Fryse 0.4.0
-----------

Released: 2020-10-31. Notable changes:

- Added support for clean urls via the `clean_urls` (default `false`) config option [#18](https://github.com/fryse/fryse/pull/18)
- Updated: Update dependencies [#16](https://github.com/fryse/fryse/pull/16)

Fryse 0.3.1
-----------

Released: 2019-10-31. Notable changes:

 - Fixed: `path_prefix` handling in `asset/2` template helper function [#12](https://github.com/fryse/fryse/pull/12)

Fryse 0.3.0
-----------

Released: 2019-10-30. Notable changes:

 - Added: `path_prefix` config setting [#11](https://github.com/fryse/fryse/pull/11)
 - Added: Config Override [#7](https://github.com/fryse/fryse/pull/7)
 - Changed: Do not delete dot files when rebuilding page [#10](https://github.com/fryse/fryse/pull/10)
 - Changed: Replace `poison` with `jason` [#9](https://github.com/fryse/fryse/pull/9)
 - Changed: Rename `path` field on `Page` struct to `url` [#6](https://github.com/fryse/fryse/pull/6)
 - Updated: Update dependencies and bump required Elixir version to 1.8 [#8](https://github.com/fryse/fryse/pull/8)

Fryse 0.2.1
-----------

Released: 2018-10-29. Notable changes:

 - Fixed: Require `plug_cowboy` dependency
 
Fryse 0.2.0
-----------

Released: 2018-10-29. Notable changes:

 - Added: Config Validation [#5](https://github.com/fryse/fryse/pull/5)
 - Added: CLI help command and command documentation [#3](https://github.com/fryse/fryse/pull/3)
 - Refactored: Error Flow [#4](https://github.com/fryse/fryse/pull/4)
 - Refactored: Builder Optimization [#2](https://github.com/fryse/fryse/pull/2)
 - Refactored: Path handling [#1](https://github.com/fryse/fryse/pull/1)
 - Updated: Update dependencies and bump required Elixir version to 1.6

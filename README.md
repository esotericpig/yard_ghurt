# YardGhurt

[![Gem Version](https://badge.fury.io/rb/yard_ghurt.svg)](https://badge.fury.io/rb/yard_ghurt)
[![Documentation](https://img.shields.io/badge/doc-yard-%23A0522D.svg)](https://esotericpig.github.io/docs/yard_ghurt/yardoc/index.html)
[![Source Code](https://img.shields.io/badge/source-github-%23211F1F.svg)](https://github.com/esotericpig/yard_ghurt)
[![License](https://img.shields.io/github/license/esotericpig/yard_ghurt.svg)](LICENSE.txt)

<u>YARD</u>oc <u>G</u>it<u>Hu</u>b <u>R</u>ake <u>T</u>asks

- Fix GitHub Flavored Markdown files.
- Sync YARDoc to a local GitHub Pages repo.

## // Contents

- [Setup](#-setup)
- [Using](#-using)
  - [GFMFixTask](#-gfmfixtask)
  - [GHPSyncTask](#-ghpsynctask)
  - [Util / YardGhurt](#-util--yardghurt)
  - [AnchorLinks](#-anchorlinks)
- [CLI App](#-cli-app)
- [Hacking](#-hacking)
  - [Testing](#-testing)
- [Tests](#-tests)
- [License](#-license)

## [//](#-contents) Setup

Pick your poison...

With the RubyGems CLI package manager:

```bash
gem install yard_ghurt
```

In your *Gemspec*:

```ruby
spec.add_development_dependency 'yard_ghurt', '~> X.X.X'
```

In your *Gemfile*:

```ruby
gem 'yard_ghurt', '~> X.X.X', group: %i[development test]
# or...
gem 'yard_ghurt', git: 'https://github.com/esotericpig/yard_ghurt.git',
                  branch: main, group: %i[development test]
```

From source:

```bash
git clone --depth 1 'https://github.com/esotericpig/yard_ghurt.git'
cd yard_ghurt
bundle install
bundle exec rake install:local
```

## [//](#-contents) Using

Currently, you can't use this project as a YARDoc Plugin, but planning on it for v2.0. Read the [TODO](TODO.md) for more info.

**Rake Tasks:**

| Task                         | Description                               |
|------------------------------|-------------------------------------------|
| [GFMFixTask](#-gfmfixtask)   | Fix GitHub Flavored Markdown files.       |
| [GHPSyncTask](#-ghpsynctask) | Sync YARDoc to a local GitHub Pages repo. |

**Helpers:**

| Helper                                | Description                   |
|---------------------------------------|-------------------------------|
| [Util / YardGhurt](#-util--yardghurt) | Utility methods for tasks.    |
| [AnchorLinks](#-anchorlinks)          | A “database” of anchor links. |

### [//](#-contents) GFMFixTask

Fix (find & replace) text in the GitHub Flavored Markdown (GFM) files in the YARDoc directory, for differences between the two formats.

**Very Important!**

In order for this to work, you must also add `redcarpet` as a dependency (per YARDoc's documentation), else, you'll get a bunch of `label-*` relative links.

```ruby
gem 'redcarpet','~> X.X' # For YARDoc Markdown (*.md).
```

You can set *dry_run* on the command line:

```bash
rake yard_gfm_fix dryrun=true
```

**What I typically use:**

```ruby
YardGhurt::GFMFixTask.new do |task|
  task.arg_names = %i[dev]
  task.dry_run = false
  task.fix_code_langs = true
  task.md_files = ['index.html']

  task.before = proc do |task2,args|
    # Delete this file as it's never used (`index.html` is an exact copy).
    YardGhurt.rm_exist(File.join(task2.doc_dir,'file.README.html'))

    # Root dir of my GitHub Page for CSS/JS.
    ghp_root_dir = YardGhurt.to_bool(args.dev) ? '../../esotericpig.github.io' : '../../..'

    task2.css_styles << %(<link rel="stylesheet" type="text/css" href="#{ghp_root_dir}/css/prism.css" />)
    task2.js_scripts << %(<script src="#{ghp_root_dir}/js/prism.js"></script>)
  end
end
```

**All options:**

```ruby
YardGhurt::GFMFixTask.new(:yard_fix) do |task|
  task.anchor_db           = {'tests' => 'Testing'} # Anchor links `#tests` become `#Testing`.
  task.arg_names          << :name # Custom args.
  task.css_styles         << '<link rel="stylesheet" href="css/my_css.css" />' # Inserted at `</head>`.
  task.css_styles         << '<style>body { background-color: linen; }</style>'
  task.custom_gsub         = proc { |line| !line.gsub!('YardGhurt','YARD GHURT!').nil? }
  task.custom_gsubs       << [/newline/i,'Do you smell what The Rock is cooking?']
  task.deps               << :yard # Custom dependencies.
  task.description         = 'Fix it'
  task.doc_dir             = 'doc'
  task.dry_run             = true
  task.exclude_code_langs  = Set['ruby']
  task.fix_anchor_links    = true
  task.fix_code_langs      = true
  task.fix_file_links      = true
  task.js_scripts         << '<script src="js/my_js.js"></script>' # Inserted at `</body>`.
  task.js_scripts         << '<script>document.write("Hello World!");</script>'
  task.md_files            = ['index.html']
  task.verbose             = false

  task.before = proc { |_task2,args| puts "Hi, #{args.name}!" }
  task.during = proc { |_task2,args,file| puts "#{args.name} can haz #{file}?" }
  task.after  = proc { |_task2,args| puts "Goodbye, #{args.name}!" }
end
```

### [//](#-contents) GHPSyncTask

Sync YARDoc to a local GitHub Pages repo (uses `rsync` by default).

**What I typically use:**

```ruby
YardGhurt::GHPSyncTask.new do |task|
  task.ghp_dir = '../esotericpig.github.io/docs/yard_ghurt/yardoc'
  task.sync_args << '--delete-after'
end
```

**All options:**

```ruby
# Execute: rake ghp_doc[false,'Custom']
YardGhurt::GHPSyncTask.new(:ghp_doc) do |task|
  task.arg_names   << :name                      # Custom args ('Custom').
  task.deps        << :yard                      # Custom dependencies.
  task.description  = 'Rsync my_doc/ to my page'
  task.doc_dir      = 'my_doc'                   # YARDoc directory of generated files.
  task.ghp_dir      = '../dest_dir/my_page'
  task.strict       = true                       # Fail if doc_dir doesn't exist.
  task.sync_args   << '--delete-after'
  task.sync_cmd     = '/usr/bin/rsync'

  task.before = proc { |_task2,args| puts "Hi, #{args.name}!" }
  task.after  = proc { |_task2,args| puts "Goodbye, #{args.name}!" }
end
```

### [//](#-contents) Util / YardGhurt

Utility methods for tasks.

```ruby
require 'yard_ghurt/util'

# If the file exists, delete it, and if `output` is true, log it to stdout.
YardGhurt::Util.rm_exist('doc/file.README.html')
YardGhurt::Util.rm_exist('doc/file.README.html',false)

# Convert an Object to true or false.
puts YardGhurt::Util.to_bool('true') #=> true
puts YardGhurt::Util.to_bool('on')   #=> true
puts YardGhurt::Util.to_bool('yes')  #=> true
puts YardGhurt::Util.to_bool(nil)    #=> false
```

For convenience, *Util*'s methods are also included in the top module *YardGhurt*. However, this will also include all the Tasks and Helpers, so *Util* is preferred, unless you're already requiring *yard_ghurt*.

```Ruby
require 'yard_ghurt'

YardGhurt.rm_exist('doc/file.README.html')
puts YardGhurt.to_bool('true')
```

### [//](#-contents) AnchorLinks

A “database” of anchor links specific to GitHub Flavored Markdown (GFM) and YARDoc.

You can use this by itself to view what anchor IDs would be generated:

```ruby
require 'yard_ghurt/anchor_links'

al = YardGhurt::AnchorLinks.new

puts al.to_github_anchor_id('This is a test!') #=> this-is-a-test
puts al.to_yard_anchor_id('This is a test!')   #=> This_is_a_test_
```

Be aware that YARDoc depends on a common number that will be incremented for all duplicates, while GFM's number is only local to each duplicate:

```ruby
al = YardGhurt::AnchorLinks.new
name = 'This is a test!'

puts al.to_yard_anchor_id(name)   #=> This_is_a_test_
puts al.to_yard_anchor_id(name)   #=> This_is_a_test_

puts al.to_github_anchor_id(name) #=> this-is-a-test
puts al.to_github_anchor_id(name) #=> this-is-a-test

al << name # Officially add it to the database.

# Instead of being 0 & 0, it will be 0 & 1 (incremented),
#   even without being added to the database.
puts al.to_yard_anchor_id(name)   #=> This_is_a_test_0
puts al.to_yard_anchor_id(name)   #=> This_is_a_test_1

puts al.to_github_anchor_id(name) #=> this-is-a-test-1
puts al.to_github_anchor_id(name) #=> this-is-a-test-1

name = 'This is another test!'
al << name # Officially add it to the database.

# Instead of being 0 & 1, it will be 2 & 3 (global increment),
#   even without being added to the database.
puts al.to_yard_anchor_id(name)   #=> This_is_another_test_2
puts al.to_yard_anchor_id(name)   #=> This_is_another_test_3

puts al.to_github_anchor_id(name) #=> this-is-another-test-1
puts al.to_github_anchor_id(name) #=> this-is-another-test-1
```

## [//](#-contents) CLI App

A CLI app has been added for convenience for when writing your own README.

On the command line:

```bash
$ yard_ghurt -g "What's this ID?"
# => whats-this-id

$ yard_ghurt -y "What's this ID?"
# => What_s_this_ID_

$ yard_ghurt -a "What's this ID?"
# => GitHub: whats-this-id
#    YARDoc: What_s_this_ID_
```

Help:

```
Usage: yard_ghurt [options]
    -a, --anchor <string>            Print GitHub & YARDoc anchor link IDs of <string>
    -g, --github <string>            Print GitHub anchor link ID of <string>
    -y, --yard <string>              Print YARDoc anchor link ID of <string>
    ---
    -h, --help                       Print this help
    -v, --version                    Print the version
```

## [//](#-contents) Hacking

```bash
git clone 'https://github.com/esotericpig/yard_ghurt.git'
cd yard_ghurt
bundle install
bundle exec rake -T
```

### [//](#-contents) Testing

First, execute this:

```bash
bundle exec rake clobber yard yard_gfm_fix[true]
```

Then execute this and make sure there are no warnings and no changes:

```bash
bundle exec rake yard_gfm_fix[true]
```

It should output this:

```
[doc/file.README.html]:
= Nothing written (up-to-date)
[doc/index.html]:
= Nothing written (up-to-date)
```

Then open up [doc/index.html](doc/index.html) and check all the [anchor links](#-tests), [local file links](#-license), etc.

Lastly, the 2 files should be almost identical, except for 1 line:

```bash
diff doc/index.html doc/file.README.html
```

## [//](#-contents) Tests

These are actual tests for this gem.

- [This is Test #1](#this-is-test-1)
- [This-is-Test-#2](#this-is-test-2)
- [This_is_Test_#3](#this_is_test_3)
- ["This is Test #4"](#this-is-test-4)
- ["This is Test #4"](#this-is-test-4-1)
- [this is test #5](#this-is-test-5)
- [THIS IS TEST #6](#this-is-test-6)
- [日本語？](#日本語)
- [テスト？](#テスト)
- [中文？](#中文)
- [汉语？](#汉语)

### [This is Test #1](#-tests)
### [This-is-Test-#2](#-tests)
### [This_is_Test_#3](#-tests)
### ["This is Test #4"](#-tests)
### ["This is Test #4"](#-tests)
### [this is test #5](#-tests)
### [THIS IS TEST #6](#-tests)
### [日本語？](#-tests)
### [テスト？](#-tests)
### [中文？](#-tests)
### [汉语？](#-tests)

```
Newline
Newline
Newline
Newline
Newline
Newline
Newline
Newline
Newline
Newline
Newline
```

## [//](#-contents) License

[GNU LGPL v3+](LICENSE.txt)

> YardGhurt (<https://github.com/esotericpig/yard_ghurt>)  
> Copyright (c) 2019-2025 Bradley Whited  
> 
> YardGhurt is free software: you can redistribute it and/or modify  
> it under the terms of the GNU Lesser General Public License as published by  
> the Free Software Foundation, either version 3 of the License, or  
> (at your option) any later version.  
> 
> YardGhurt is distributed in the hope that it will be useful,  
> but WITHOUT ANY WARRANTY; without even the implied warranty of  
> MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
> GNU Lesser General Public License for more details.  
> 
> You should have received a copy of the GNU Lesser General Public License  
> along with YardGhurt.  If not, see <https://www.gnu.org/licenses/>.  

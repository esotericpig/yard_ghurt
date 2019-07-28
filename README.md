# YardGhurt

[![Gem Version](https://badge.fury.io/rb/yard_ghurt.svg)](https://badge.fury.io/rb/yard_ghurt)

[![Documentation](https://img.shields.io/badge/doc-yard-%23A0522D.svg?style=for-the-badge)](https://esotericpig.github.io/docs/yard_ghurt/yardoc/index.html)
[![Source Code](https://img.shields.io/badge/source-github-%23A0522D.svg?style=for-the-badge)](https://github.com/esotericpig/yard_ghurt)
[![Changelog](https://img.shields.io/badge/changelog-md-%23A0522D.svg?style=for-the-badge)](CHANGELOG.md)
[![License](https://img.shields.io/github/license/esotericpig/yard_ghurt.svg?color=%23A0522D&style=for-the-badge)](LICENSE.txt)

<u>YARD</u>oc <u>G</u>it<u>Hu</u>b <u>R</u>ake <u>T</u>asks

- Fix GitHub Flavored Markdown files.
- Sync YARDoc to a local GitHub Pages repo.

## Contents

- [Setup](#setup)
- [Using](#using)
    - [GFMFixerTask](#gfmfixertask)
    - [GHPSyncerTask](#ghpsyncertask)
    - [Util / YardGhurt](#util--yardghurt)
    - [AnchorLinks](#anchorlinks)
- [Hacking](#hacking)
    - [Testing](#testing)
- [Tests](#tests)
- [License](#license)

## [Setup](#contents)

Pick your poison...

With the RubyGems CLI package manager:

`$ gem install yard_ghurt`

In your *Gemspec* (*&lt;project&gt;.gemspec*):

```Ruby
spec.add_development_dependency 'yard_ghurt', '~> X.X.X'
```

In your *Gemfile*:

```Ruby
gem 'yard_ghurt', '~> X.X.X', :group => [:development, :test]
# or...
gem 'yard_ghurt', :git => 'https://github.com/esotericpig/yard_ghurt.git',
                  :tag => 'vX.X.X', :group => [:development, :test]
```

Manually:

```
$ git clone 'https://github.com/esotericpig/yard_ghurt.git'
$ cd yard_ghurt
$ bundle install
$ bundle exec rake install:local
```

## [Using](#contents)

**Rake Tasks:**

| Task | Description |
| --- | --- |
| [GFMFixerTask](#gfmfixertask) | Fix GitHub Flavored Markdown files |
| [GHPSyncerTask](#ghpsyncertask) | Sync YARDoc to a local GitHub Pages repo. |

**Helpers:**

| Helper | Description |
| --- | --- |
| [Util / YardGhurt](#util--yardghurt) | Utility methods for tasks |
| [AnchorLinks](#anchorlinks) | A “database” of anchor links |

### [GFMFixerTask](#using)

Fix (find & replace) text in the GitHub Flavored Markdown (GFM) files in the YARDoc directory, for differences between the two formats.

**What I typically use:**

```Ruby
YardGhurt::GFMFixerTask.new() do |task|
  task.arg_names = [:dev]
  task.dry_run = false
  task.fix_code_langs = true
  task.md_files = ['index.html']
  
  task.before = Proc.new() do |task,args|
    # Delete this file as it's never used (index.html is an exact copy)
    YardGhurt.rm_exist(File.join(task.doc_dir,'file.README.html'))
    
    # Root dir of my GitHub Page for CSS/JS
    GHP_ROOT_DIR = YardGhurt.to_bool(args.dev) ? '../../esotericpig.github.io' : '../../..'
    
    task.css_styles << %Q(<link rel="stylesheet" type="text/css" href="#{GHP_ROOT_DIR}/css/prism.css" />)
    task.js_scripts << %Q(<script src="#{GHP_ROOT_DIR}/js/prism.js"></script>)
  end
end
```

**Using all options:**

```Ruby
YardGhurt::GFMFixerTask.new(:yard_fix) do |task|
  task.anchor_db           = {'tests' => 'Testing'} # #tests => #Testing
  task.arg_names          << :name # Custom args
  task.css_styles         << '<link rel="stylesheet" href="css/my_css.css" />' # Inserted at </head>
  task.css_styles         << '<style>body{ background-color: linen; }</style>'
  task.custom_gsub         = Proc.new() {|line| !line.gsub!('YardGhurt','YARD GHURT!').nil?()}
  task.custom_gsubs       << [/newline/i,'Do you smell what The Rock is cooking?']
  task.deps               << :yard # Custom dependencies
  task.description         = 'Fix it'
  task.doc_dir             = 'doc'
  task.dry_run             = false
  task.exclude_code_langs  = Set['ruby']
  task.fix_anchor_links    = true
  task.fix_code_langs      = true
  task.fix_file_links      = true
  task.js_scripts         << '<script src="js/my_js.js"></script>' # Inserted at </body>
  task.js_scripts         << '<script>document.write("Hello World!");</script>'
  task.md_files            = ['index.html']
  task.verbose             = false
  
  task.before = Proc.new() {|task,args| puts "Hi, #{args.name}!"}
  task.during = Proc.new() {|task,args,file| puts "#{args.name} can haz #{file}?"}
  task.after  = Proc.new() {|task,args| puts "Goodbye, #{args.name}!"}
end
```

### [GHPSyncerTask](#using)

Sync YARDoc to a local GitHub Pages repo (uses `rsync` by default).

**What I typically use:**

```Ruby
YardGhurt::GHPSyncerTask.new() do |task|
  task.ghp_dir = '../esotericpig.github.io/docs/yard_ghurt/yardoc'
  task.sync_args << '--delete-after'
end
```

**Using all options:**

```Ruby
# Execute: rake ghp_doc[false,'Ruby']
YardGhurt::GHPSyncerTask.new(:ghp_doc) do |task|
  task.arg_names   << :name                      # Custom args
  task.deps        << :yard                      # Custom dependencies
  task.description  = 'Rsync my_doc/ to my page'
  task.doc_dir      = 'my_doc'                   # YARDoc directory of generated files
  task.ghp_dir      = '../dest_dir/my_page'
  task.strict       = true                       # Fail if doc_dir doesn't exist
  task.sync_args   << '--delete-after'
  task.sync_cmd     = '/usr/bin/rsync'
  
  task.before = Proc.new() {|task,args| puts "Hi, #{args.name}!"}
  task.after  = Proc.new() {|task,args| puts "Goodbye, #{args.name}!"}
end
```

### [Util / YardGhurt](#using)

Utility methods for tasks.

```Ruby
require 'yard_ghurt/util'

# If the file exists, delete it, and if +output+ is true, log it to stdout
YardGhurt::Util.rm_exist('doc/file.README.html')
YardGhurt::Util.rm_exist('doc/file.README.html',false)

# Convert an Object to true or false
puts YardGhurt::Util.to_bool('true') # true
puts YardGhurt::Util.to_bool('on')   # true
puts YardGhurt::Util.to_bool('yes')  # true
puts YardGhurt::Util.to_bool(nil)    # false
```

For convenience, *Util*'s methods are also included in the top module *YardGhurt*. However, this will also include all of the Tasks and Helpers, so *Util* is preferred, unless you're already requiring *yard_ghurt*.

```Ruby
require 'yard_ghurt'

YardGhurt.rm_exist('doc/file.README.html')
puts YardGhurt.to_bool('true')
```

### [AnchorLinks](#using)
A “database” of anchor links specific to GitHub Flavored Markdown (GFM) and YARDoc.

You can use this by itself to view what anchor IDs would be generated:

```Ruby
require 'yard_ghurt/anchor_links'

al = YardGhurt::AnchorLinks.new()

puts al.to_github_anchor_id('This is a test!')
puts al.to_yard_anchor_id('This is a test!')

# Output:
# ---
# this-is-a-test
# This_is_a_test_
```

Be aware that YARDoc depends on a common number that will be incremented for all duplicates, while GFM's number is only local to each specific duplicate:

```Ruby
al = YardGhurt::AnchorLinks.new()
name = 'This is a test!'

puts al.to_yard_anchor_id(name)   # This_is_a_test_
puts al.to_yard_anchor_id(name)   # This_is_a_test_

puts al.to_github_anchor_id(name) # this-is-a-test
puts al.to_github_anchor_id(name) # this-is-a-test

al << name # Officially add it to the database

# Instead of being 0 & 0, will be 0 & 1 (incremented),
#   even without being added to the database
puts al.to_yard_anchor_id(name)   # This_is_a_test_0
puts al.to_yard_anchor_id(name)   # This_is_a_test_1

puts al.to_github_anchor_id(name) # this-is-a-test-1
puts al.to_github_anchor_id(name) # this-is-a-test-1

name = 'This is another test!'
al << name # Officially add it to the database

# Instead of being 0 & 1, will be 2 & 3 (global increment),
#   even without being added to the database
puts al.to_yard_anchor_id(name)   # This_is_another_test_2
puts al.to_yard_anchor_id(name)   # This_is_another_test_3

puts al.to_github_anchor_id(name) # this-is-another-test-1
puts al.to_github_anchor_id(name) # this-is-another-test-1
```

## [Hacking](#contents)

```
$ git clone 'https://github.com/esotericpig/yard_ghurt.git'
$ bundle install
$ bundle exec rake -T
```

### [Testing](#hacking)

First, execute this:

`$ bundle exec rake clobber yard yard_gfm_fix[true]`

Then execute this and make sure there are no warnings and no changes:

`$ bundle exec rake yard_gfm_fix[true]`

It should output this:

```
[doc/file.README.html]:
= Nothing written (up-to-date)
[doc/index.html]:
= Nothing written (up-to-date)
```

Then open up **doc/index.html** and check all of  the [anchor links](#tests), [local file links](#license), etc.

Lastly, the 2 files should be almost identical, except for 1 line:

`$ diff doc/index.html doc/file.README.html`

## [Tests](#contents)

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

### [This is Test #1](#tests)
### [This-is-Test-#2](#tests)
### [This_is_Test_#3](#tests)
### ["This is Test #4"](#tests)
### ["This is Test #4"](#tests)
### [this is test #5](#tests)
### [THIS IS TEST #6](#tests)
### [日本語？](#tests)
### [テスト？](#tests)
### [中文？](#tests)
### [汉语？](#tests)

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

## [License](#contents)

[GNU LGPL v3+](LICENSE.txt)

> YardGhurt (<https://github.com/esotericpig/yard_ghurt>)  
> Copyright (c) 2019 Jonathan Bradley Whited (@esotericpig)  
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

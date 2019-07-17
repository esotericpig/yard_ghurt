# YardGhurt

<u>YARD</u>oc <u>G</u>it<u>Hu</u>b <u>R</u>ake <u>T</u>asks

- Fix GitHub Flavored Markdown files.
- Sync YARDoc to a local GitHub Pages repo.

## Contents

- [Setup](#setup)
- [Using](#using)
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

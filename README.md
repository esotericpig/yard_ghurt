# YardGhurt

<u>YARD</u>oc <u>G</u>it<u>Hu</u>b <u>R</u>ake <u>T</u>asks

- Fix GitHub Flavored Markdown files.
- Sync YARDoc to GitHub Pages repo.

## Contents

- [Setup](#setup)
- [Using](#using)
- [Hacking](#hacking)
- [Tests](#tests)
- [License](#license)

## [Setup](#contents)

Pick your poison...

With the RubyGems CLI package manager:

```Bash
$ gem install yard_ghurt
```

In your *Gemspec* (*&lt;project&gt;.gemspec*):

```Ruby
spec.add_development_dependency 'yard_ghurt', '~> X.X.X'
```

In your *Gemfile*:

```Bash
gem 'yard_ghurt', '~> X.X.X', :group => [:development, :test]
# or...
gem 'yard_ghurt', :git => 'https://github.com/esotericpig/yard_ghurt.git',
                  :tag => 'vX.X.X', :group => [:development, :test]
```

Manually:

```Bash
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

## [Tests](#contents)

These are actual tests for this gem.

- [This is Test #1](#this-is-test-1)
- [This-is-Test-#2](#this-is-test-2)
- [This_is_Test_#3](#this_is_test_3)
- ["This is Test #4"](#this-is-test-4)
- ["This is Test #4"](#this-is-test-4-1)

### This is Test #1
### This-is-Test-#2
### This_is_Test_#3
### "This is Test #4"
### "This is Test #4"

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

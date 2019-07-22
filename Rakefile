# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of YardGhurt.
# Copyright (c) 2019 Jonathan Bradley Whited (@esotericpig)
# 
# YardGhurt is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# YardGhurt is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public License
# along with YardGhurt.  If not, see <https://www.gnu.org/licenses/>.
#++


require 'bundler/gem_tasks'

require 'yard'
require 'yard_ghurt'

require 'rake/clean'

task default: [:yard,:yard_gfm_fix]

CLEAN.exclude('.git/','stock/')
CLOBBER.include('doc/')

YARD::Rake::YardocTask.new() do |task|
  task.files = [File.join('lib','**','*.rb')]
  
  task.options += ['--files','CHANGELOG.md,LICENSE.txt']
  task.options += ['--readme','README.md']
  
  task.options << '--protected' # Show protected methods
  task.options += ['--template-path',File.join('yard','templates')]
  task.options += ['--title',"YardGhurt v#{YardGhurt::VERSION} Doc"]
end

desc 'Generate pristine YARDoc'
task :yard_fresh => [:clobber,:yard,:yard_gfm_fix] do |task|
end

YardGhurt::GFMFixerTask.new() do |task|
  task.arg_names = [:dev]
  task.dry_run = false
  task.fix_code_langs = true
  
  task.before = Proc.new() do |task,args|
    # Root dir of my GitHub Page for CSS/JS
    GHP_ROOT_DIR = YardGhurt.to_bool(args.dev) ? '../../esotericpig.github.io' : '../../..'
    
    task.css_styles << %Q(<link rel="stylesheet" type="text/css" href="#{GHP_ROOT_DIR}/css/prism.css" />)
    task.js_scripts << %Q(<script src="#{GHP_ROOT_DIR}/js/prism.js"></script>)
  end
end

# Probably not useful for others.
YardGhurt::GHPSyncerTask.new() do |task|
  task.ghp_dir = '../esotericpig.github.io/docs/yard_ghurt/yardoc'
  task.sync_args << '--delete-after'
end

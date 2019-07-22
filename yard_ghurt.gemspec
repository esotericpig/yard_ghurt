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


lib = File.expand_path('../lib',__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'yard_ghurt/version'

Gem::Specification.new() do |spec|
  spec.name        = 'yard_ghurt'
  spec.version     = YardGhurt::VERSION
  spec.authors     = ['Jonathan Bradley Whited (@esotericpig)']
  spec.email       = ['bradley@esotericpig.com']
  spec.licenses    = ['LGPL-3.0-or-later']
  spec.homepage    = 'https://github.com/esotericpig/yard_ghurt'
  spec.summary     = 'YARDoc GitHub Rake Tasks'
  spec.description = 'YARDoc GitHub Rake Tasks. Fix GitHub Flavored Markdown (GFM) files.'
  
  spec.metadata = {
    'bug_tracker_uri'   => 'https://github.com/esotericpig/yard_ghurt/issues',
    'changelog_uri'     => 'https://github.com/esotericpig/yard_ghurt/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://esotericpig.github.io/docs/yard_ghurt/yardoc/index.html',
    'homepage_uri'      => 'https://github.com/esotericpig/yard_ghurt',
    'source_code_uri'   => 'https://github.com/esotericpig/yard_ghurt'
  }
  
  spec.require_paths = ['lib']
  
  spec.files = Dir.glob(File.join("{#{spec.require_paths.join(',')},test,yard}",'**','*.{erb,rb}')) +
               %W( Gemfile #{spec.name}.gemspec Rakefile ) +
               %w( CHANGELOG.md LICENSE.txt README.md )
  
  spec.required_ruby_version = '>= 2.1.10'
  
  spec.add_runtime_dependency 'rake' #,'~> 12.3'
  
  spec.add_development_dependency 'bundler'  ,'~> 1.17'
  spec.add_development_dependency 'rdoc'     ,'~> 6.1'  # For RDoc for YARD (*.rb)
  spec.add_development_dependency 'redcarpet','~> 3.4'  # For Markdown for YARD (*.md)
  spec.add_development_dependency 'yard'     ,'~> 0.9'
end

# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of YardGhurt.
# Copyright (c) 2019-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++


lib = File.expand_path(File.join('..','lib'),__FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'yard_ghurt/version'

Gem::Specification.new do |spec|
  spec.name        = 'yard_ghurt'
  spec.version     = YardGhurt::VERSION
  spec.authors     = ['Jonathan Bradley Whited']
  spec.email       = ['code@esotericpig.com']
  spec.licenses    = ['LGPL-3.0-or-later']
  spec.homepage    = 'https://github.com/esotericpig/yard_ghurt'
  spec.summary     = 'YARDoc GitHub Rake Tasks'
  spec.description = "#{spec.summary}. Fix GitHub Flavored Markdown (GFM) files."

  spec.metadata = {
    'homepage_uri'      => 'https://github.com/esotericpig/yard_ghurt',
    'source_code_uri'   => 'https://github.com/esotericpig/yard_ghurt',
    'bug_tracker_uri'   => 'https://github.com/esotericpig/yard_ghurt/issues',
    'changelog_uri'     => 'https://github.com/esotericpig/yard_ghurt/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://esotericpig.github.io/docs/yard_ghurt/yardoc/index.html',
  }

  spec.required_ruby_version = '>= 2.1.10'
  spec.require_paths         = ['lib']
  spec.bindir                = 'bin'
  spec.executables           = [spec.name]

  spec.files = [
    Dir.glob(File.join("{#{spec.require_paths.join(',')}}",'**','*.{erb,rb}')),
    Dir.glob(File.join(spec.bindir,'*')),
    Dir.glob(File.join('{samples,test,yard}','**','*.{erb,rb}')),
    %W[ Gemfile #{spec.name}.gemspec Rakefile .yardopts ],
    %w[ LICENSE.txt CHANGELOG.md README.md ],
  ].flatten

  # Test using different Gem versions:
  #   GST=1 bundle update && bundle exec rake doc
  gemspec_test = ENV.fetch('GST','').to_s.strip
  yard_gemv = false

  if !gemspec_test.empty?
    case gemspec_test
    when '1' then yard_gemv = '0.9.24'
    end

    puts 'Using Gem versions:'
    puts "  yard: #{yard_gemv.inspect}"
  end

  spec.add_runtime_dependency 'rake'                      # 13.0.3
  spec.add_runtime_dependency 'yard',yard_gemv || '>= 0'  # 0.9.26, 0.9.24 (diff)

  spec.add_development_dependency 'bundler'  ,'~> 2.2'
  spec.add_development_dependency 'rdoc'     ,'~> 6.3'  # For RDoc for YARD (*.rb)
  spec.add_development_dependency 'redcarpet','~> 3.5'  # For Markdown for YARD (*.md)
end

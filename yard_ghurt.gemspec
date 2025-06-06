# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of YardGhurt.
# Copyright (c) 2019 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require_relative 'lib/yard_ghurt/version'

Gem::Specification.new do |spec|
  spec.name        = 'yard_ghurt'
  spec.version     = YardGhurt::VERSION
  spec.authors     = ['Bradley Whited']
  spec.email       = ['code@esotericpig.com']
  spec.licenses    = ['LGPL-3.0-or-later']
  spec.homepage    = 'https://github.com/esotericpig/yard_ghurt'
  spec.summary     = 'YARDoc GitHub Rake Tasks.'
  spec.description = "#{spec.summary} Fix GitHub Flavored Markdown (GFM) files."

  spec.metadata = {
    'rubygems_mfa_required' => 'true',
    'homepage_uri'          => spec.homepage,
    'source_code_uri'       => 'https://github.com/esotericpig/yard_ghurt',
    'documentation_uri'     => 'https://esotericpig.github.io/docs/yard_ghurt/yardoc/index.html',
    'bug_tracker_uri'       => 'https://github.com/esotericpig/yard_ghurt/issues',
  }

  spec.required_ruby_version = '>= 2.3'
  spec.require_paths         = ['lib']
  spec.bindir                = 'bin'
  spec.executables           = [spec.name]

  spec.files = [
    Dir.glob("{#{spec.require_paths.join(',')}}/**/*.{erb,rb}"),
    Dir.glob("#{spec.bindir}/*"),
    Dir.glob('{spec,test,yard}/**/*.{erb,rb}'),
    %W[Gemfile #{spec.name}.gemspec Rakefile .yardopts],
    %w[LICENSE.txt README.md],
  ].flatten

  # TEST: Test using different Gem versions:
  #         GST=1 bundle update && bundle exec rake doc
  gemspec_test = ENV.fetch('GST','').to_s.strip
  yard_gemv = false

  if !gemspec_test.empty?
    case gemspec_test
    when '1' then yard_gemv = '0.9.24'
    end

    puts 'Using Gem versions:'
    puts "  yard: #{yard_gemv.inspect}"
  end

  spec.add_dependency 'rake'                     # 13.0.3.
  spec.add_dependency 'yard',yard_gemv || '>= 0' # 0.9.26, 0.9.24 (diff).
end

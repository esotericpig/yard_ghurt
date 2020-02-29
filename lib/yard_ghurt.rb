#!/usr/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of YardGhurt.
# Copyright (c) 2019-2020 Jonathan Bradley Whited (@esotericpig)
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


require 'optparse'
require 'yard_ghurt/anchor_links'
require 'yard_ghurt/gfm_fix_task'
require 'yard_ghurt/ghp_sync_task'
require 'yard_ghurt/util'
require 'yard_ghurt/version'


###
# YARDoc GitHub Rake Tasks
# 
# @author Jonathan Bradley Whited (@esotericpig)
# @since  1.0.0
###
module YardGhurt
  # Internal code should use +Util.+!
  # See {Util} for details.
  include Util
  
  ###
  # A simple CLI app used in file +bin/yard_ghurt+.
  # 
  # Mainly for getting GitHub/YARDoc anchor link IDs.
  # 
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  1.2.0
  ###
  class App
    attr_reader :args
    
    def initialize(args=ARGV)
      super()
      
      @args = args
    end
    
    def run()
      parser = OptionParser.new() do |op|
        op.program_name = 'yard_ghurt'
        op.version = VERSION
        
        op.banner = "Usage: #{op.program_name} [options]"
        
        op.on('-g','--github <string>','Print GitHub anchor link ID of <string>') do |str|
          al = AnchorLinks.new()
          puts al.to_github_anchor_id(str)
          exit
        end
        op.on('-y','--yard <string>','Print YARDoc anchor link ID of <string>') do |str|
          al = AnchorLinks.new()
          puts al.to_yard_anchor_id(str)
          exit
        end
        
        op.separator op.summary_indent + '---'
        
        op.on_tail('-h','--help','Print this help') do
          puts op
          exit
        end
        op.on_tail('-v','--version','Print the version') do
          puts "#{op.program_name} v#{op.version}"
          exit
        end
      end
      
      parser.parse!(@args)
      puts parser # Print help if nothing was parsed
    end
  end
end

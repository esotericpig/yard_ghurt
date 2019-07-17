#!/usr/bin/env ruby
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


require 'yard_ghurt/anchor_links'
require 'yard_ghurt/gfm_fixer_task'
require 'yard_ghurt/ghp_syncer_task'
require 'yard_ghurt/version'

###
# YARDoc GitHub Rake Tasks
# 
# @author Jonathan Bradley Whited (@esotericpig)
# @since  1.0.0
###
module YardGhurt
  # @return [Array<String>] the lower-case Strings that will equal to +true+
  TRUE_BOOLS = ['1','on','t','true','y','yes'].freeze()
  
  # If +filename+ exists, delete it, and if +output+ is true, log it to stdout.
  # 
  # @param filename [String] the file to remove
  # @param output [true,false] whether to log it to stdout
  def self.rm_exist(filename,output=true)
    return unless File.exist?(filename)
    
    puts "[#{filename}]: - Deleted" if output
    File.delete(filename)
  end
  
  # Convert +str+ to +true+ or +false+.
  # 
  # Even if +str+ is not a String, +to_s()+ will be called, so should be safe.
  # 
  # @param str [String,Object] the String (or Object) to convert
  # 
  # @return [true,false] the boolean value of +str+
  # 
  # @see TRUE_BOOLS
  # @see GHPSyncerTask#arg_names
  def self.to_bool(str)
    return TRUE_BOOLS.include?(str.to_s().downcase())
  end
end

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


require 'set'
require 'uri'

module YardGhurt
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  1.0.0
  ###
  class AnchorLinks
    attr_accessor :github_anchor_ids
    attr_accessor :yard_anchor_ids
    attr_accessor :yard_dup_num
    
    def initialize()
      reset()
    end
    
    def reset()
      @github_anchor_ids = {}
      @yard_anchor_ids = Set.new()
      @yard_dup_num = 0
    end
    
    def <<(name)
      return add_anchor(name)
    end
    
    def []=(github_anchor_id,yard_anchor_id)
      return set_anchor(github_anchor_id,yard_anchor_id)
    end
    
    def add_anchor(name)
      set_anchor(to_github_anchor_id(name),to_yard_anchor_id(name))
      
      return self
    end
    
    def set_anchor(github_anchor_id,yard_anchor_id)
      @github_anchor_ids[github_anchor_id] = yard_anchor_id
      @yard_anchor_ids << yard_anchor_id
      
      return yard_anchor_id
    end
    
    def [](github_anchor_id)
      return anchor_id(github_anchor_id)
    end
    
    def anchor_id(github_anchor_id)
      return @github_anchor_ids[github_anchor_id]
    end
    
    def yard_anchor_id?(id)
      return @yard_anchor_ids.include?(id)
    end
    
    # @see https://gist.github.com/asabaylus/3071099#gistcomment-2834467
    # @see https://github.com/jch/html-pipeline/blob/master/lib/html/pipeline/toc_filter.rb
    def to_github_anchor_id(name)
      id = name.dup()
      
      id.strip!()
      id.gsub!(/&[^;]+;/,'') # Remove entities: &...;
      id.gsub!(/[^\p{Word}\- ]/u,'')
      id.tr!(' ','-')
      
      if RUBY_VERSION >= '2.4'
        id.downcase!(:ascii)
      else
        id.downcase!()
      end
      
      id = URI.escape(id) # For non-English languages
      
      # Duplicates
      dup_num = 1
      orig_id = id.dup()
      
      while @github_anchor_ids.key?(id)
        id = "#{orig_id}-#{dup_num}"
        dup_num += 1
      end
      
      return id
    end
    
    def to_s()
      s = ''.dup()
      
      @github_anchor_ids.each do |github_id,yard_id|
        s << "[#{github_id}] => '#{yard_id}'\n"
      end
      
      return s
    end
    
    # doc/app.js#generateTOC()
    def to_yard_anchor_id(name)
      id = name.dup()
      
      id.strip!()
      id.gsub!(/&[^;]+;/,'_') # Replace entities: &...;
      id.gsub!(/[^a-z0-9-]/i,'_')
      id = URI.escape(id) # For non-English languages
      
      # Duplicates
      orig_id = id.dup()
      
      while @yard_anchor_ids.include?(id)
        id = "#{orig_id}#{@yard_dup_num}"
        @yard_dup_num += 1
      end
      
      return id
    end
  end
end

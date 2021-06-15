# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of YardGhurt.
# Copyright (c) 2019-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++


require 'set'
require 'uri'

module YardGhurt
  ###
  # A "database" of anchor links specific to GitHub Flavored Markdown (GFM) & YARDoc.
  #
  # You can use this by itself to view what anchor IDs would be generated:
  #   al = YardGhurt::AnchorLinks.new()
  #
  #   puts al.to_github_anchor_id('This is a test!')
  #   puts al.to_yard_anchor_id('This is a test!')
  #
  #   # Output:
  #   # ---
  #   # this-is-a-test
  #   # This_is_a_test_
  #
  # Be aware that YARDoc depends on a common number that will be incremented for all duplicates,
  # while GFM's number is only local to each specific duplicate:
  #   al = YardGhurt::AnchorLinks.new()
  #   name = 'This is a test!'
  #
  #   puts al.to_yard_anchor_id(name)   # This_is_a_test_
  #   puts al.to_yard_anchor_id(name)   # This_is_a_test_
  #
  #   puts al.to_github_anchor_id(name) # this-is-a-test
  #   puts al.to_github_anchor_id(name) # this-is-a-test
  #
  #   al << name # Officially add it to the database
  #
  #   # Instead of being 0 & 0, will be 0 & 1 (incremented),
  #   #   even without being added to the database
  #   puts al.to_yard_anchor_id(name)   # This_is_a_test_0
  #   puts al.to_yard_anchor_id(name)   # This_is_a_test_1
  #
  #   puts al.to_github_anchor_id(name) # this-is-a-test-1
  #   puts al.to_github_anchor_id(name) # this-is-a-test-1
  #
  #   name = 'This is another test!'
  #   al << name # Officially add it to the database
  #
  #   # Instead of being 0 & 1, will be 2 & 3 (global increment),
  #   #   even without being added to the database
  #   puts al.to_yard_anchor_id(name)   # This_is_another_test_2
  #   puts al.to_yard_anchor_id(name)   # This_is_another_test_3
  #
  #   puts al.to_github_anchor_id(name) # this-is-another-test-1
  #   puts al.to_github_anchor_id(name) # this-is-another-test-1
  #
  # @author Jonathan Bradley Whited
  # @since  1.0.0
  #
  # @see GFMFixTask
  ###
  class AnchorLinks
    # @return [Hash] the GFM-style anchor IDs pointing to their YARDoc ID equivalents that have been added
    attr_reader :anchor_ids

    # @return [Set] the YARDoc anchor IDs that have been added
    attr_accessor :yard_anchor_ids

    # @return [Integer] the next YARDoc number to use if there is a duplicate anchor ID
    attr_accessor :yard_dup_num

    def initialize
      super()
      reset
    end

    # Reset the database back to its fresh, pristine self,
    # including common numbers for duplicates.
    def reset
      @anchor_ids = {}
      @yard_anchor_ids = Set.new
      @yard_dup_num = 0
    end

    # (see #add_anchor)
    def <<(name)
      return add_anchor(name)
    end

    # (see #store_anchor)
    def []=(github_anchor_id,yard_anchor_id)
      store_anchor(github_anchor_id,yard_anchor_id)
    end

    # Convert +name+ (header text) to a GFM and YARDoc anchor ID and add the IDs to the database.
    #
    # @note +yard_id:+ was added in v1.2.1 for YARD v0.9.25+.
    #
    # @param  name [String] the name (header text) to convert to anchor IDs and add to the database
    # @return [self]
    def add_anchor(name,yard_id: nil)
      yard_id = to_yard_anchor_id(name) if yard_id.nil?

      store_anchor(to_github_anchor_id(name),yard_id)

      return self
    end

    # Escape +str+ for the web (e.g., "%20" for a space).
    #
    # Mainly used for non-English languages.
    #
    # @param str [String] the string to escape
    #
    # @return [String] the escaped string
    #
    # @since  1.2.0
    def self.escape(str)
      # URI.escape()/encode() is obsolete
      return URI.encode_www_form_component(str)
    end

    # Merge +anchor_ids+ with {anchor_ids} and {yard_anchor_ids}.
    #
    # @param anchor_ids [Hash] the anchor IDs (of GFM anchor IDs to YARDoc anchor IDs) to merge
    def merge_anchor_ids!(anchor_ids)
      @anchor_ids.merge!(anchor_ids)
      @yard_anchor_ids.merge(anchor_ids.values)

      return @anchor_ids
    end

    # Store & associate key +github_anchor_id+ with value +yard_anchor_id+,
    # and add +yard_anchor_id+ to the YARDoc anchor IDs.
    #
    # @param github_anchor_id [String] the GitHub anchor ID; the key
    # @param yard_anchor_id [String] the YARDoc anchor ID; the value
    #
    # @return [String] the +yard_anchor_id+ added
    def store_anchor(github_anchor_id,yard_anchor_id)
      @anchor_ids[github_anchor_id] = yard_anchor_id
      @yard_anchor_ids << yard_anchor_id

      return yard_anchor_id
    end

    def anchor_ids=(anchor_ids)
      @anchor_ids = anchor_ids
      @yard_anchor_ids.merge(anchor_ids.values)
    end

    # (see #anchor_id)
    def [](github_anchor_id)
      return anchor_id(github_anchor_id)
    end

    # Get the YARDoc anchor ID associated with this +github_anchor_id+.
    #
    # @param github_anchor_id [String] the GitHub anchor ID key to look up
    #
    # @return [String,nil] the YARDoc anchor ID associated with +github_anchor_id+
    def anchor_id(github_anchor_id)
      return @anchor_ids[github_anchor_id]
    end

    # Check if +id+ exists in the database of YARDoc anchor IDs
    #
    # @param id [String] the YARDoc anchor ID to check
    #
    # @return [true,false] whether this ID exists in the database of YARDoc anchor IDs
    def yard_anchor_id?(id)
      return @yard_anchor_ids.include?(id)
    end

    # Convert +name+ (header text) to a GitHub anchor ID.
    #
    # If the converted ID already exists in the database,
    # then the ID will be updated according to GFM rules.
    #
    # @param name [String] the name (header text) to convert
    #
    # @return [String] the converted GitHub anchor ID for this database
    #
    # @see https://gist.github.com/asabaylus/3071099#gistcomment-2834467
    # @see https://github.com/jch/html-pipeline/blob/master/lib/html/pipeline/toc_filter.rb
    def to_github_anchor_id(name)
      id = name.dup

      id.strip!
      id.gsub!(/&[^;]+;/,'') # Remove entities: &...;
      id.gsub!(/[^\p{Word}\- ]/u,'')
      id.tr!(' ','-')

      if RUBY_VERSION >= '2.4'
        id.downcase!(:ascii)
      else
        id.downcase!
      end

      id = self.class.escape(id) # For non-English languages

      # Duplicates
      dup_num = 1
      orig_id = id.dup

      while @anchor_ids.key?(id)
        id = "#{orig_id}-#{dup_num}"
        dup_num += 1
      end

      return id
    end

    # Dumps the key-value database of GFM & YARDoc anchor IDs.
    #
    # @return [String] the database of anchor IDs as a String
    def to_s
      s = ''.dup

      @anchor_ids.keys.sort_by(&:to_s).each do |key|
        s << "[#{key}] => '#{@anchor_ids[key]}'\n"
      end

      return s
    end

    # Convert +name+ (header text) to a YARDoc anchor ID.
    #
    # If the converted ID already exists in the database,
    # then the ID will be updated according to YARDoc rules,
    # which requires incrementing a common number variable.
    #
    # The logic for this is pulled from +doc/app.js#generateTOC()+
    # (or +doc/js/app.js+), which you can generate using +rake yard+
    # or +yardoc+ on the command line.
    #
    # @note Be aware that this will increment a common number variable
    #       every time you call this with a duplicate.
    #
    # @param name [String] the name (header text) to convert
    #
    # @return [String] the converted YARDoc anchor ID for this database
    def to_yard_anchor_id(name)
      id = name.dup

      id.strip!
      id.gsub!(/&[^;]+;/,'_') # Replace entities: &...;
      id.gsub!(/[^a-z0-9-]/i,'_')
      id = self.class.escape(id) # For non-English languages

      # Duplicates
      orig_id = id.dup

      while @yard_anchor_ids.include?(id)
        id = "#{orig_id}#{@yard_dup_num}"
        @yard_dup_num += 1
      end

      return id
    end
  end
end

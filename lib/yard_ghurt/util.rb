# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of YardGhurt.
# Copyright (c) 2019-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++


module YardGhurt
  ###
  # Utility methods in a separate module/mixin,
  # so that a programmer can require/load a sole task:
  #   require 'yard_ghurt/gfm_fix_task'
  #
  # Else, programmers would be required to always require/load the entire +yard_ghurt+ module:
  #   require 'yard_ghurt'
  #
  # All internal code should use this module.
  #
  # External code can either use this module or {YardGhurt},
  # which includes this module as a mixin.
  #
  # @author Jonathan Bradley Whited
  # @since  1.0.0
  ###
  module Util
    # @return [Array<String>] the lower-case Strings that will equal to +true+
    TRUE_BOOLS = %w[ 1 on t true y yes ].freeze

    # @return a very flexible (non-strict) Semantic Versioning regex, ignoring pre-release/build-metadata
    # @since  1.2.1
    SEM_VER_REGEX = /(?<major>\d+)(?:\.(?<minor>\d+))?(?:\.(?<patch>\d+))?/.freeze

    # If +include Util+ is called, extend {ClassMethods}.
    #
    # @param mod [Module] the module to extend
    def self.included(mod)
      mod.extend ClassMethods
    end

    module ClassMethods
      @yard_sem_ver = nil

      # If +filename+ exists, delete it, and if +output+ is +true+, log it to stdout.
      #
      # @param filename [String] the file to remove
      # @param output [true,false] whether to log it to stdout
      def rm_exist(filename,output=true)
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
      # @see GHPSyncTask#arg_names
      def to_bool(str)
        return TRUE_BOOLS.include?(str.to_s.downcase)
      end

      # Parse +str+ as a non-strict Semantic Version:
      #   \d+.\d+.\d+
      #
      # Unlike the specification, minor and patch are optional.
      # Also, pre-release and build metadata are ignored.
      # This is used for checking the YARD version internally,
      # so needs to be very flexible.
      #
      # @param  str [String,Object] the object to parse; +to_s()+ will be called on it
      # @return [Hash] the Semantic Version parts: +{:major, :minor, :patch}+
      #                defaults all values to +0+ if the version cannot be parsed
      # @see    SEM_VER_REGEX
      # @see    #yard_sem_ver
      # @since  1.2.1
      def parse_sem_ver(str)
        sem_ver = {
          major: 0,minor: 0,patch: 0,
        }

        match = SEM_VER_REGEX.match(str.to_s.gsub(/\s+/u,''))

        return sem_ver unless match

        sem_ver[:major] = match[:major].to_i
        sem_ver[:minor] = match[:minor].to_i unless match[:minor].nil?
        sem_ver[:patch] = match[:patch].to_i unless match[:patch].nil?

        return sem_ver
      end

      # Returns YARD's version as a +Hash+ of parts:
      #   { major: 0, minor: 0, patch: 0 }
      #
      # If the version can not be parsed, it will return the exact
      # same +Hash+ as above with all values to +0+.
      #
      # On initial call, it will parse it and store it.
      # On subsequent calls, it will return the stored value.
      #
      # @return [Hash] YARD's version parts
      # @see    parse_sem_ver
      # @since  1.2.1
      def yard_sem_ver
        return @yard_sem_ver unless @yard_sem_ver.nil?

        require 'yard'

        if defined?(YARD::VERSION)
          ver = YARD::VERSION
        else
          ver = ''
        end

        return(@yard_sem_ver = parse_sem_ver(ver))
      end
    end

    extend ClassMethods
  end
end

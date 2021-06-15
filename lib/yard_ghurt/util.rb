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

    # If +include Util+ is called, extend {ClassMethods}.
    #
    # @param mod [Module] the module to extend
    def self.included(mod)
      mod.extend ClassMethods
    end

    module ClassMethods
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
    end

    extend ClassMethods
  end
end

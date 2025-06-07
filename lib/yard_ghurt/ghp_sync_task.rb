# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of YardGhurt.
# Copyright (c) 2019 Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require 'rake'
require 'rake/tasklib'
require 'yard_ghurt/util'

module YardGhurt
  # Sync YARDoc to a local GitHub Pages repo (uses +rsync+ by default).
  #
  # @example What I Use
  #   YardGhurt::GHPSyncTask.new do |task|
  #     task.ghp_dir = '../esotericpig.github.io/docs/yard_ghurt/yardoc'
  #     task.sync_args << '--delete-after'
  #   end
  #
  # @since 1.1.0
  class GHPSyncTask < Rake::TaskLib
    # @return [Proc,nil] the Proc ( +respond_to?(:call)+ ) to call at the end of this task or +nil+;
    #                    default: +nil+
    attr_accessor :after

    # @note +:deploy+ will be added no matter what (cannot be deleted)
    #
    # @return [Array<Symbol>,Symbol] the custom arg(s) for this task; default: +[:deploy]+
    attr_accessor :arg_names

    # @return [Proc,nil] the Proc ( +respond_to?(:call)+ ) to call at the beginning of this task or +nil+;
    #                    default: +nil+
    attr_accessor :before

    # @example
    #   task.deps = :yard
    #   # or...
    #   task.deps = [:yard,:yard_gfm_fix]
    #
    # @return [Array<Symbol>,Symbol] the custom dependencies for this task; default: +[]+
    attr_accessor :deps

    # @return [String] the description of this task (customizable)
    attr_accessor :description

    # @return [String] the source directory of generated YARDoc files; default: +doc+
    attr_accessor :doc_dir

    # @note You must set this, else an error is thrown.
    #
    # @return [String] the destination directory to sync {doc_dir} to
    attr_accessor :ghp_dir

    # @return [String] the name of this task (customizable); default: +yard_ghp_sync+
    attr_accessor :name

    # If you want to use a non-local {doc_dir} (a remote host), set this to +false+.
    #
    # @return [true,false] whether to throw an error if {doc_dir} does not exist; default: +true+
    attr_accessor :strict

    # @note You should pass in multi-args separately: +['--exclude','*~']+
    # @note You should not single/double quote the args; +['"*~"']+ is unnecessary.
    #
    # @return [Array<String>] the args to pass to the {sync_cmd}; default: +['-ahv','--progress']+
    attr_accessor :sync_args

    # @return [String] the sync command to use on the command line; default: +rsync+
    attr_accessor :sync_cmd

    alias_method :strict?,:strict

    # @param name [Symbol] the name of this task to use on the command line with +rake+
    def initialize(name = :yard_ghp_sync)
      super()

      @after = nil
      @arg_names = []
      @before = nil
      @deps = []
      @description = 'Sync YARDoc to GitHub Pages repo'
      @doc_dir = 'doc'
      @ghp_dir = nil
      @name = name
      @strict = true
      @sync_args = ['-ahv','--progress']
      @sync_cmd = 'rsync'

      yield(self) if block_given?
      define
    end

    # Define the Rake task and description using the instance variables.
    def define
      @arg_names = *@arg_names
      @arg_names.unshift(:deploy) unless @arg_names.include?(:deploy)

      desc @description
      task @name,@arg_names => Array(@deps) do |_task,args|
        deploy = Util.to_bool(args.deploy)

        @before.call(self,args) if @before.respond_to?(:call)

        # Without the below checks, sh() raises some pretty cryptic errors.

        # If you want to use a non-local dir, set strict to false.
        if @strict && !File.exist?(@doc_dir)
          raise ArgumentError,%(#{self.class}.doc_dir [#{@doc_dir}] does not exist; execute "rake yard"?)
        end
        # Do not check if ghp_dir exists because rsync may create it.
        if @ghp_dir.nil? || @ghp_dir.to_s.strip.empty?
          raise ArgumentError,"#{self.class}.ghp_dir must be set"
        end

        sh(*build_sh_cmd(deploy))

        if !deploy
          puts
          puts %(Execute "rake #{@name}[true]" for actually deploying (not a dry-run))
        end

        @after.call(self,args) if @after.respond_to?(:call)
      end

      return self
    end

    # Build the sync command to use on the command line.
    #
    # @param deploy [true,false] whether to actually deploy (+true+) or to run a dry-run (+false+)
    #
    # @return [Array<String>] the sync command and its args
    def build_sh_cmd(deploy)
      sh_cmd = [@sync_cmd]

      sh_cmd << '--dry-run' unless deploy
      sh_cmd.push(*@sync_args)

      # File.join() to add a trailing '/' if not present
      sh_cmd << File.join(@doc_dir,'')
      sh_cmd << File.join(@ghp_dir,'')

      return sh_cmd
    end
  end
end

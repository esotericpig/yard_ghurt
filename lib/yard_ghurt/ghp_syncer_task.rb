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


require 'rake'

require 'rake/tasklib'

module YardGhurt
  ###
  # Sync YARDoc to a local GitHub Pages repo (uses +rsync+ by default).
  # 
  # @example What I Use
  #   YardGhurt::GHPSyncerTask.new() do |task|
  #     task.ghp_dir = '../esotericpig.github.io/docs/yard_ghurt/yardoc'
  #     task.sync_args << '--delete-after'
  #   end
  # 
  # @example Using All Options
  #   # Execute: rake ghp_doc[false,'Ruby']
  #   YardGhurt::GHPSyncerTask.new(:ghp_doc) do |task|
  #     task.arg_names   << :name                      # Custom args
  #     task.deps        << :yard                      # Custom dependencies
  #     task.description  = 'Rsync my_doc/ to my page'
  #     task.doc_dir      = 'my_doc'                   # YARDoc directory of generated files
  #     task.ghp_dir      = '../dest_dir/my_page'
  #     task.strict       = true                       # Fail if doc_dir doesn't exist
  #     task.sync_args   << '--delete-after'
  #     task.sync_cmd     = '/usr/bin/rsync'
  #     
  #     task.before = Proc.new() {|task,args| puts "Hi, #{args.name}!"}
  #     task.after  = Proc.new() {|task,args| puts "Goodbye, #{args.name}!"}
  #   end
  # 
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  1.0.0
  ###
  class GHPSyncerTask < Rake::TaskLib
    # @return [Proc,nil] the Proc ( +respond_to?(:call)+ ) to call at the end of this task or +nil+;
    #                    default: +nil+
    attr_accessor :after
    
    # @note +:deploy+ will be added no matter what (cannot be deleted)
    # @return [Array<Symbol>,Symbol] the custom arg(s) for this task; default: +[:deploy]+
    attr_accessor :arg_names
    
    # @return [Proc,nil] the Proc ( +respond_to?(:call)+ ) to call at the beginning of this task or +nil+;
    #                    default: +nil+
    attr_accessor :before
    
    # @example
    #   task.deps = :yard
    #   # or...
    #   task.deps = [:yard,:yard_gfm_fix]
    # @return [Array<Symbol>,Symbol] the custom dependencies for this task; default: +[]+
    attr_accessor :deps
    
    # @return [String] the description of this task (customizable)
    attr_accessor :description
    
    # @return [String] the directory of generated YARDoc files; default: +doc+
    attr_accessor :doc_dir
    
    # @note You must set this, else an error is thrown.
    # @return [String] the directory to sync {doc_dir} to
    attr_accessor :ghp_dir
    
    # @return [String] the name of this task (customizable); default: +yard_ghp_sync+
    attr_accessor :name
    
    # @return [true,false] whether to throw an error if {doc_dir} does not exist; default: +true+
    attr_accessor :strict
    
    # @note You should pass in multi-args separately: +['--exclude','*~']+
    # @note You should not single/double quote the args; +['"*~"']+ is unnecessary.
    # @return [Array<String>] the args to pass to the {sync_cmd}; default: +['-ahv','--progress']+
    attr_accessor :sync_args
    
    # @return [String] the sync command to use on the command line; default: +rsync+
    attr_accessor :sync_cmd
    
    alias_method :strict?,:strict
    
    # @param name [Symbol] the name of this task to use on the command line with +rake+
    def initialize(name=:yard_ghp_sync)
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
      
      yield self if block_given?()
      define()
    end
    
    # Define the Rake task and description using the instance variables.
    def define()
      @arg_names = *@arg_names
      @arg_names.unshift(:deploy) unless @arg_names.include?(:deploy)
      
      desc @description
      task @name,@arg_names => Array(@deps) do |task,args|
        deploy = YardGhurt.to_bool(args.deploy)
        
        @before.call(self,args) if @before.respond_to?(:call)
        
        # Without these checks, sh raises some pretty cryptic errors.
        if @strict
          # If you want to use a non-local dir, set strict to false.
          if !File.exist?(@doc_dir)
            raise ArgumentError,%Q(#{self.class}.doc_dir [#{@doc_dir}] does not exist; execute "rake yard"?)
          end
        end
        # Do not check if ghp_dir exists because rsync may create it.
        if @ghp_dir.nil?() || @ghp_dir.to_s().strip().empty?()
          raise ArgumentError,"#{self.class}.ghp_dir must be set"
        end
        
        sh *build_sh_cmd(deploy)
        
        if !deploy
          puts
          puts %Q(Execute "rake #{@name}[true]" for actually deploying (not a dry-run))
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

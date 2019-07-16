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
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  1.0.0
  ###
  class GHPSyncerTask < Rake::TaskLib
    attr_accessor :after
    attr_accessor :arg_names
    attr_accessor :before
    attr_accessor :deps
    attr_accessor :description
    attr_accessor :doc_dir
    attr_accessor :ghp_dir
    attr_accessor :name
    attr_accessor :strict
    attr_accessor :sync_args
    attr_accessor :sync_cmd
    
    alias_method :strict?,:strict
    
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
    
    def define()
      @arg_names << :deploy unless @arg_names.include?(:deploy)
      
      desc @description
      task @name,@arg_names => @deps do |task,args|
        @before.call(self,args) if @before.respond_to?(:call)
        
        # Without these checks, sh raises some pretty cryptic errors.
        if @strict
          # If you want to use a non-local dir, set strict to false.
          if !File.exist?(@doc_dir)
            raise ArgumentError,%Q(#{self.class}.doc_dir [#{@doc_dir}] does not exist; execute "rake yard"?)
          end
        end
        # Do not check if ghp_dir exists because rsync will create it.
        if @ghp_dir.nil?() || @ghp_dir.to_s().strip().empty?()
          raise ArgumentError,"#{self.class}.ghp_dir must be set"
        end
        
        sh *build_sh_cmd(args.deploy)
        
        if !args.deploy
          puts
          puts %Q(Execute "rake #{@name}[true]" for actually deploying (not a dry-run))
        end
        
        @after.call(self,args) if @after.respond_to?(:call)
      end
      
      return self
    end
    
    def build_sh_cmd(deploy)
      sh_cmd = [@sync_cmd]
      
      if !deploy
        sh_cmd << '--dry-run'
      end
      
      @sync_args.each do |sync_arg|
        sh_cmd << sync_arg
      end
      
      sh_cmd << "#{@doc_dir}/"
      sh_cmd << "#{@ghp_dir}/"
      
      return sh_cmd
    end
  end
end

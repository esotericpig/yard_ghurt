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
require 'set'

require 'rake/tasklib'

require 'yard_ghurt/anchor_links'

module YardGhurt
  ###
  # @author Jonathan Bradley Whited (@esotericpig)
  # @since  1.0.0
  ###
  class GFMFixerTask < Rake::TaskLib
    CSS_COMMENT = "<!-- #{self} CSS - Do NOT remove this comment! -->"
    JS_COMMENT = "<!-- #{self} JS - Do NOT remove this comment! -->"
    
    attr_accessor :after
    attr_accessor :arg_names
    attr_accessor :before
    attr_accessor :css_styles
    attr_accessor :custom_gsub
    attr_accessor :custom_gsubs # [['href="#This_Is_A_Test"','href="#This-is-a-Test"']]
    attr_accessor :deps
    attr_accessor :description
    attr_accessor :doc_dir
    attr_accessor :dry_run
    attr_accessor :during
    attr_accessor :exclude_code_langs # Case-sensitive
    attr_accessor :fix_code_langs
    attr_accessor :has_css_comment
    attr_accessor :has_js_comment
    attr_accessor :header_db
    attr_accessor :js_scripts
    attr_accessor :md_files
    attr_accessor :name
    attr_accessor :verbose
    
    alias_method :dry_run?,:dry_run
    alias_method :fix_code_langs?,:fix_code_langs
    alias_method :verbose?,:verbose
    
    def initialize(name=:yard_gfmf)
      @after = nil
      @arg_names = []
      @before = nil
      @css_styles = []
      @custom_gsub = nil
      @custom_gsubs = []
      @deps = []
      @description = 'Fix (find & replace) text in the YARDoc GitHub Flavored Markdown files'
      @doc_dir = 'doc'
      @dry_run = false
      @during = nil
      @exclude_code_langs = Set['ruby']
      @fix_code_langs = false
      @header_db = {}
      @js_scripts = []
      @md_files = ['file.README.html','index.html']
      @name = name
      @verbose = true
      
      yield self if block_given?()
      define()
    end
    
    def reset_per_file()
      @has_css_comment = false
      @has_js_comment = false
      
      @anchor_links = AnchorLinks.new()
      @anchor_links.github_anchor_ids = @header_db.dup()
    end
    
    def define()
      desc @description
      task @name,@arg_names => @deps do |task,args|
        @before.call(self,args) if @before.respond_to?(:call)
        
        @md_files.each do |md_file|
          reset_per_file()
          build_anchor_links_db(md_file)
          
          @during.call(self,args) if @during.respond_to?(:call)
          fix_md_file(md_file)
        end
        
        @after.call(self,args) if @after.respond_to?(:call)
      end
      
      return self
    end
    
    def build_anchor_links_db(md_file)
      filename = File.join(@doc_dir,md_file)
      
      return unless File.exist?(filename)
      
      File.open(filename,'r') do |file|
        file.each_line do |line|
          next if line !~ /<h\d+>/i
          
          line.gsub!(/<[^>]+>/,'') # Remove tags: <...>
          
          @anchor_links << line
        end
      end
    end
    
    def fix_md_file(md_file)
      filename = File.join(@doc_dir,md_file)
      
      puts "[#{filename}]:"
      
      if !File.exist?(filename)
        puts '! File does not exist'
        
        return
      end
      
      changes = 0
      lines = []
      
      puts @anchor_links.yard_anchor_ids
      
      File.open(filename,'r') do |file|
        file.each_line do |line|
          has_change = false
          
          # Standard
          has_change = add_css_styles!(line) || has_change
          has_change = add_js_scripts!(line) || has_change
          has_change = gsub_anchor_links!(line) || has_change
          has_change = gsub_code_langs!(line) || has_change
          has_change = gsub_local_file_links!(line) || has_change
          
          # Custom
          has_change = gsub_customs!(line) || has_change
          has_change = gsub_custom!(line) || has_change
          
          if has_change
            puts "+ #{line}" if @verbose
            
            changes += 1
          end
          
          lines << line
        end
      end
      
      print '= '
      
      if changes > 0
        if @dry_run
          puts 'Nothing written (dry run)'
        else
          File.open(filename,'w') do |file|
            file.puts lines
          end
          
          puts "#{changes} changes written"
        end
      else
        puts 'Nothing written (up-to-date)'
      end
    end
    
    def add_css_styles!(line)
      return false if @has_css_comment
      
      if line.strip() == CSS_COMMENT
        @has_css_comment = true
        
        return false
      end
      
      return false unless line =~ /^\s*<\/head>\s*$/i
      
      line.slice!(0,line.length())
      line << "    #{CSS_COMMENT}"
      
      @css_styles.each do |css_style|
        line << "\n    #{css_style}"
      end
      
      line << "\n\n  </head>"
      
      @has_css_comment = true
      
      return true
    end
    
    def add_js_scripts!(line)
      return false if @has_js_comment
      
      if line.strip() == JS_COMMENT
        @has_js_comment = true
        
        return false
      end
      
      return false unless line =~ /^\s*<\/body>\s*$/i
      
      line.slice!(0,line.length())
      line << "\n    #{JS_COMMENT}"
      
      @js_scripts.each do |js_script|
        line << "\n    #{js_script}"
      end
      
      line << "\n\n  </body>"
      
      @has_js_comment = true
      
      return true
    end
    
    #task.custom_gsubs = [['href="#This_Is_A_Test"','href="#This-is-a-Test"']]
    def gsub_anchor_links!(line)
      has_change = false
      tag = 'href="#'
      
      line.gsub!(Regexp.new(Regexp.quote(tag) + '[^"]*"')) do |href|
        link = href[tag.length..-2]
        
        # FIXME: fix this
        if @anchor_links.yard_anchor_id?(link)
          href
        else
          puts link
          
          link = URI.unescape(link) # For non-English languages
          yard_link = @anchor_links[link]
          
          if yard_link.nil?()
            link = link.split('-').map(&:capitalize).join('_')
          else
            link = yard_link
          end
          
          has_change = false
          
          %Q(#{tag}#{link}")
        end
      end
      
      return has_change
    end
    
    def gsub_code_langs!(line)
      return false unless @fix_code_langs
      
      has_change = false
      tag = 'code class="'
      
      line.gsub!(Regexp.new(Regexp.quote(tag) + '[^"]*"')) do |code_class|
        lang = code_class[tag.length..-2]
        
        if lang =~ /^language\-/ || @exclude_code_langs.include?(lang)
          code_class
        else
          has_change = true
          
          %Q(#{tag}language-#{lang.downcase()}")
        end
      end
      
      return has_change
    end
    
    def gsub_custom!(line)
      return false unless @custom_gsub.respond_to?(:call)
      return @custom_gsub.call(line)
    end
    
    def gsub_customs!(line)
      has_change = false
      
      @custom_gsubs.each do |custom_gsub|
        has_change = !line.gsub!(custom_gsub[0],custom_gsub[1]).nil?() || has_change
      end
      
      return has_change
    end
    
    def gsub_local_file_links!(line)
      has_change = false
      tag = 'href="'
      
      line.gsub!(Regexp.new(Regexp.quote(tag) + '[^#][^"]*"')) do |href|
        link = href[tag.length..-2]
        
        if File.exist?(link)
          link = File.basename(link,'.*')
          has_change = true
          
          %Q(#{tag}file.#{link}.html")
        else
          href
        end
      end
      
      return has_change
    end
  end
end

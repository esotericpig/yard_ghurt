# encoding: UTF-8
# frozen_string_literal: true

#--
# This file is part of YardGhurt.
# Copyright (c) 2019-2021 Jonathan Bradley Whited
#
# SPDX-License-Identifier: LGPL-3.0-or-later
#++


require 'rake'
require 'set'

require 'rake/tasklib'

require 'yard_ghurt/anchor_links'
require 'yard_ghurt/util'

module YardGhurt
  ###
  # Fix (find & replace) text in the GitHub Flavored Markdown (GFM) files in the YARDoc directory,
  # for differences between the two formats.
  #
  # You can set {dry_run} on the command line:
  #   rake yard_gfm_fix dryrun=true
  #
  # @example What I Use
  #   YardGhurt::GFMFixTask.new() do |task|
  #     task.arg_names = [:dev]
  #     task.dry_run = false
  #     task.fix_code_langs = true
  #     task.md_files = ['index.html']
  #
  #     task.before = Proc.new() do |t2,args|
  #       # Delete this file as it's never used (index.html is an exact copy)
  #       YardGhurt.rm_exist(File.join(t2.doc_dir,'file.README.html'))
  #
  #       # Root dir of my GitHub Page for CSS/JS
  #       ghp_root_dir = YardGhurt.to_bool(args.dev) ? '../../esotericpig.github.io' : '../../..'
  #
  #       t2.css_styles << %Q(<link rel="stylesheet" type="text/css" href="#{ghp_root_dir}/css/prism.css" />)
  #       t2.js_scripts << %Q(<script src="#{ghp_root_dir}/js/prism.js"></script>)
  #     end
  #   end
  #
  # @example Using All Options
  #   YardGhurt::GFMFixTask.new(:yard_fix) do |task|
  #     task.anchor_db           = {'tests' => 'Testing'} # #tests => #Testing
  #     task.arg_names          << :name # Custom args
  #     task.css_styles         << '<link rel="stylesheet" href="css/my_css.css" />' # Inserted at </head>
  #     task.css_styles         << '<style>body{ background-color: linen; }</style>'
  #     task.custom_gsub         = Proc.new() {|line| !line.gsub!('YardGhurt','YARD GHURT!').nil?()}
  #     task.custom_gsubs       << [/newline/i,'Do you smell what The Rock is cooking?']
  #     task.deps               << :yard # Custom dependencies
  #     task.description         = 'Fix it'
  #     task.doc_dir             = 'doc'
  #     task.dry_run             = false
  #     task.exclude_code_langs  = Set['ruby']
  #     task.fix_anchor_links    = true
  #     task.fix_code_langs      = true
  #     task.fix_file_links      = true
  #     task.js_scripts         << '<script src="js/my_js.js"></script>' # Inserted at </body>
  #     task.js_scripts         << '<script>document.write("Hello World!");</script>'
  #     task.md_files            = ['index.html']
  #     task.verbose             = false
  #
  #     task.before = Proc.new() {|task,args| puts "Hi, #{args.name}!"}
  #     task.during = Proc.new() {|task,args,file| puts "#{args.name} can haz #{file}?"}
  #     task.after  = Proc.new() {|task,args| puts "Goodbye, #{args.name}!"}
  #   end
  #
  # @author Jonathan Bradley Whited
  # @since  1.1.0
  ###
  class GFMFixTask < Rake::TaskLib
    # This is important so that a subsequent call to this task will not write the CSS again.
    #
    # @return [String] the comment tag of where to place {css_styles}
    #
    # @see add_css_styles!
    CSS_COMMENT = "<!-- #{self} CSS - Do NOT remove this comment! -->"

    # This is important so that a subsequent call to this task will not write the JS again.
    #
    # @return [String] the comment tag of where to place {js_scripts}
    #
    # @see add_js_scripts!
    JS_COMMENT = "<!-- #{self} JS - Do NOT remove this comment! -->"

    # @example
    #   task.arg_names = [:dev]
    #
    #   # @param task [self]
    #   # @param args [Rake::TaskArguments] the args specified by {arg_names}
    #   task.after = Proc.new do |task,args|
    #     puts args.dev
    #   end
    #
    # @return [Proc,nil] the Proc ( +respond_to?(:call)+ ) to call at the end of this task or +nil+;
    #                    default: +nil+
    attr_accessor :after

    # The anchor links to override in the database.
    #
    # The keys are GFM anchor IDs and the values are their equivalent YARDoc anchor IDs.
    #
    # @return [Hash] the custom database (key-value pairs) of GFM anchor links to YARDoc anchor links;
    #                default: +{}+
    #
    # @see build_anchor_links_db
    # @see AnchorLinks#merge_anchor_ids!
    attr_accessor :anchor_db

    # @return [Array<Symbol>,Symbol] the custom arg(s) for this task; default: +[]+
    attr_accessor :arg_names

    # @example
    #   task.arg_names = [:dev]
    #
    #   # @param task [self]
    #   # @param args [Rake::TaskArguments] the args specified by {arg_names}
    #   task.before = Proc.new do |task,args|
    #     puts args.dev
    #   end
    #
    # @return [Proc,nil] the Proc ( +respond_to?(:call)+ ) to call at the beginning of this task or +nil+;
    #                    default: +nil+
    attr_accessor :before

    # @example
    #   task.css_styles << '<link rel="stylesheet" type="text/css" href="css/prism.css" />'
    #
    # @return [Array<String>] the CSS styles to add to each file; default: +[]+
    attr_accessor :css_styles

    # @example
    #   # +gsub!()+ (and other mutable methods) must be used
    #   # as the return value must be +true+ or +false+.
    #   #
    #   # @param line [String] the current line being processed from the current file
    #   #
    #   # @return [true,false] whether there was a change
    #   task.custom_gsub = Proc.new do |line|
    #     has_change = false
    #
    #     has_change = !line.gsub!('dev','prod').nil?() || has_change
    #     # More changes...
    #
    #     return has_change
    #   end
    #
    # @return [Proc,nil] the custom Proc ( +respond_to?(:call)+ ) to call to gsub! each line for each file
    attr_accessor :custom_gsub

    # @example
    #   task.custom_gsubs = [
    #     ['dev','prod'],
    #     [/href="#[^"]*"/,'href="#contents"']
    #   ]
    #
    #   # Internal code:
    #   # ---
    #   # @custom_gsubs.each do |custom_gsub|
    #   #   line.gsub!(custom_gsub[0],custom_gsub[1])
    #   # end
    #
    # @return [Array<[Regexp,String]>] the custom args to use in gsub on each line for each file
    attr_accessor :custom_gsubs

    # @example
    #   task.deps = :yard
    #   # or...
    #   task.deps = [:clobber,:yard]
    #
    # @return [Array<Symbol>,Symbol] the custom dependencies for this task; default: +[]+
    attr_accessor :deps

    # @return [String] the description of this task (customizable)
    attr_accessor :description

    # @return [String] the directory of generated YARDoc files; default: +doc+
    attr_accessor :doc_dir

    # @return [true,false] whether to run a dry run (no writing to the files); default: +false+
    attr_accessor :dry_run

    # @example
    #   task.arg_names = [:dev]
    #
    #   # @param task [self]
    #   # @param args [Rake::TaskArguments] the args specified by {arg_names}
    #   # @param file [String] the current file being processed
    #   task.during = Proc.new do |task,args,file|
    #     puts args.dev
    #   end
    #
    # @return [Proc,nil] the Proc to call ( +respond_to?(:call)+ ) at the beginning of processing
    #                    each file or +nil+; default: +nil+
    attr_accessor :during

    # @return [Set<String>] the case-sensitive code languages to not fix; default: +Set[ 'ruby' ]+
    #
    # @see fix_code_langs
    attr_accessor :exclude_code_langs

    # @return [true,false] whether to fix anchor links; default: +true+
    attr_accessor :fix_anchor_links

    # If +true+, +language-+ will be added to code classes, except for {exclude_code_langs}.
    #
    # For example, +code class="ruby"+ will be changed to +code class="language-ruby"+.
    #
    # @return [true,false] whether to fix code languages; default: +false+
    attr_accessor :fix_code_langs

    # If +true+, local file links (if the local file exists), will be changed to +file.{filename}.html+.
    #
    # This is useful for +README.md+, +LICENSE.txt+, etc.
    #
    # @return [true,false] whether to fix local file links; default: +true+
    attr_accessor :fix_file_links

    # This is an internal flag meant to be changed internally.
    #
    # @return [true,false] whether {CSS_COMMENT} has been seen/added; default: +false+
    #
    # @see add_css_styles!
    attr_accessor :has_css_comment

    # This is an internal flag meant to be changed internally.
    #
    # @return [true,false] whether {JS_COMMENT} has been seen/added; default: +false+
    #
    # @see add_js_scripts!
    attr_accessor :has_js_comment

    # @example
    #   task.js_scripts << '<script src="js/prism.js"></script>'
    #
    # @return [Array<String>] the JS scripts to add to each file; default: +[]+
    attr_accessor :js_scripts

    # @return [Array<String>] the (GFM) Markdown files to fix; default: +['file.README.html','index.html']+
    attr_accessor :md_files

    # @return [String] the name of this task (customizable); default: +yard_gfm_fix+
    attr_accessor :name

    # @return [true,false] whether to output each change to stdout; default: +true+
    attr_accessor :verbose

    alias_method :dry_run?,:dry_run
    alias_method :fix_anchor_links?,:fix_anchor_links
    alias_method :fix_code_langs?,:fix_code_langs
    alias_method :fix_file_links?,:fix_file_links
    alias_method :has_css_comment?,:has_css_comment
    alias_method :has_js_comment?,:has_js_comment
    alias_method :verbose?,:verbose

    # @param name [Symbol] the name of this task to use on the command line with +rake+
    def initialize(name=:yard_gfm_fix)
      super()

      @after = nil
      @anchor_db = {}
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
      @fix_anchor_links = true
      @fix_code_langs = false
      @fix_file_links = true
      @js_scripts = []
      @md_files = ['file.README.html','index.html']
      @name = name
      @verbose = true

      yield self if block_given?
      define
    end

    # Reset certain instance vars per file.
    def reset_per_file
      @anchor_links = AnchorLinks.new
      @has_css_comment = false
      @has_js_comment = false
      @has_verbose_anchor_links = false
    end

    # Define the Rake task and description using the instance variables.
    def define
      desc @description
      task @name,Array(@arg_names) => Array(@deps) do |task,args|
        env_dryrun = ENV['dryrun']

        if !env_dryrun.nil? && !(env_dryrun = env_dryrun.to_s.strip).empty?
          @dry_run = Util.to_bool(env_dryrun)
        end

        @before.call(self,args) if @before.respond_to?(:call)

        @md_files.each do |md_file|
          reset_per_file
          build_anchor_links_db(md_file)

          @during.call(self,args,md_file) if @during.respond_to?(:call)

          fix_md_file(md_file)
        end

        @after.call(self,args) if @after.respond_to?(:call)
      end

      return self
    end

    # Convert each HTML header tag in +md_file+ to a GFM & YARDoc anchor link
    # and build a database using them.
    #
    # @param md_file [String] the file (no dir) to build the anchor links database with,
    #                         will be joined to {doc_dir}
    #
    # @see AnchorLinks#<<
    # @see AnchorLinks#merge_anchor_ids!
    def build_anchor_links_db(md_file)
      filename = File.join(@doc_dir,md_file)

      return unless File.exist?(filename)

      File.open(filename,'r') do |file|
        file.each_line do |line|
          # +<h3 id="..."+ or +<h3...+
          # - +yard_id+ was added for YARD v0.9.25+.
          match = line.match(/<\s*h\d+.*?id\s*=\s*["'](?<yard_id>[^"']+)["']|<\s*h\d+[\s>]/ui)

          next unless match

          yard_id = nil
          caps = match.named_captures

          if caps.key?('yard_id')
            yard_id = caps['yard_id'].to_s.strip
            yard_id = nil if yard_id.empty?
          end

          line.gsub!(/<[^>]+>/,'') # Remove tags: <...>
          line.strip!

          next if line.empty?

          @anchor_links.add_anchor(line,yard_id: yard_id)
        end
      end

      @anchor_links.merge_anchor_ids!(@anchor_db)
    end

    # Fix (find & replace) text in +md_file+. Calls all +add_*+ & +gsub_*+ methods.
    #
    # @param md_file [String] the file (no dir) to fix, will be joined to {doc_dir}
    def fix_md_file(md_file)
      filename = File.join(@doc_dir,md_file)

      puts "[#{filename}]:"

      if !File.exist?(filename)
        puts '! File does not exist'

        return
      end

      changes = 0
      lines = []

      File.open(filename,'r') do |file|
        file.each_line do |line|
          if line.strip.empty?
            lines << line

            next
          end

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

    # Add {CSS_COMMENT} & {css_styles} to +line+ if it is +</head>+,
    # unless {CSS_COMMENT} has already been found or {has_css_comment}.
    #
    # @param line [String] the line from the file to check if +</head>+
    def add_css_styles!(line)
      return false if @has_css_comment || @css_styles.empty?

      if line.strip == CSS_COMMENT
        @has_css_comment = true

        return false
      end

      return false unless line =~ %r{^\s*</head>\s*$}i

      line.slice!(0,line.length)
      line << "    #{CSS_COMMENT}"

      @css_styles.each do |css_style|
        line << "\n    #{css_style}"
      end

      line << "\n\n  </head>"

      @has_css_comment = true

      return true
    end

    # Add {JS_COMMENT} & {js_scripts} to +line+ if it is +</body>+,
    # unless {JS_COMMENT} has already been found or {has_js_comment}.
    #
    # @param line [String] the line from the file to check if +</body>+
    def add_js_scripts!(line)
      return false if @has_js_comment || @js_scripts.empty?

      if line.strip == JS_COMMENT
        @has_js_comment = true

        return false
      end

      return false unless line =~ %r{^\s*</body>\s*$}i

      line.slice!(0,line.length)
      line << "\n    #{JS_COMMENT}"

      @js_scripts.each do |js_script|
        line << "\n    #{js_script}"
      end

      line << "\n\n  </body>"

      @has_js_comment = true

      return true
    end

    # Replace GFM anchor links with their equivalent YARDoc anchor links,
    # using {build_anchor_links_db} & {anchor_db}, if {fix_anchor_links}.
    #
    # @param line [String] the line from the file to fix
    def gsub_anchor_links!(line)
      return false unless @fix_anchor_links

      has_change = false

      # +href="#..."+ or +href='#...'+
      line.gsub!(/href\s*=\s*["']\s*#\s*(?<link>[^"']+)["']/ui) do |href|
        link = Regexp.last_match[:link].to_s.strip # Same as +$~[:link]+.

        if link.empty? || @anchor_links.yard_anchor_id?(link)
          href
        else
          yard_link = @anchor_links[link]

          if yard_link.nil?
            # Either the GFM link is wrong [check with @anchor_links.to_github_anchor_id()]
            #   or the internal code is broken [check with @anchor_links.to_s()]
            puts "! YARDoc anchor link for GFM anchor link [#{link}] does not exist"

            if !@has_verbose_anchor_links
              if @verbose
                puts '  GFM anchor link in the Markdown file is wrong?'
                puts '  Please check the generated links:'
                puts %Q(  #{@anchor_links.to_s.strip.gsub("\n","\n  ")})
              else
                puts "  Turn on #{self.class}.verbose for more info"
              end

              @has_verbose_anchor_links = true
            end

            href
          else
            has_change = true

            %Q(href="##{yard_link}")
          end
        end
      end

      return has_change
    end

    # Add +language-+ to code class languages and down case them,
    # if {fix_code_langs} and the language is not in {exclude_code_langs}.
    #
    # @param line [String] the line from the file to fix
    def gsub_code_langs!(line)
      return false unless @fix_code_langs

      has_change = false
      tag = 'code class="'

      line.gsub!(Regexp.new(Regexp.quote(tag) + '[^"]*"')) do |code_class|
        lang = code_class[tag.length..-2].strip

        if lang.empty? || lang =~ /^language\-/ || @exclude_code_langs.include?(lang)
          code_class
        else
          has_change = true

          %Q(#{tag}language-#{lang.downcase}")
        end
      end

      return has_change
    end

    # Call the custom Proc {custom_gsub} (if it responds to +:call+) on +line+,
    #
    # @param line [String] the line from the file to fix
    def gsub_custom!(line)
      return false unless @custom_gsub.respond_to?(:call)
      return @custom_gsub.call(line)
    end

    # Call +gsub!()+ on +line+ with each {custom_gsubs},
    # which is an Array of pairs of arguments:
    #   task.custom_gsubs = [
    #     ['dev','prod'],
    #     [/href="#[^"]*"/,'href="#contents"']
    #   ]
    #
    # @param line [String] the line from the file to fix
    def gsub_customs!(line)
      return false if @custom_gsubs.empty?

      has_change = false

      @custom_gsubs.each do |custom_gsub|
        has_change = !line.gsub!(custom_gsub[0],custom_gsub[1]).nil? || has_change
      end

      return has_change
    end

    # Replace local file links (that exist) to be +file.{filename}.html+,
    # if {fix_file_links}.
    #
    # @param line [String] the line from the file to fix
    def gsub_local_file_links!(line)
      return false unless @fix_file_links

      has_change = false
      tag = 'href="'

      line.gsub!(Regexp.new(Regexp.quote(tag) + '[^#][^"]*"')) do |href|
        link = href[tag.length..-2].strip

        if link.empty? || !File.exist?(link)
          href
        else
          link = File.basename(link,'.*')
          has_change = true

          %Q(#{tag}file.#{link}.html")
        end
      end

      return has_change
    end
  end
end

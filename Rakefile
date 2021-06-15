# encoding: UTF-8
# frozen_string_literal: true


require 'bundler/gem_tasks'

require 'rake/clean'

require 'yard'
require 'yard_ghurt'


task default: [:doc]

CLEAN.exclude('.git/','stock/')
CLOBBER.include('doc/')


desc 'Generate documentation (YARDoc)'
task :doc,%i[] => %i[ yard yard_gfm_fix ] do |task|
  # pass
end

YARD::Rake::YardocTask.new do |task|
  task.files = [File.join('lib','**','*.rb')]

  task.options += ['--files','CHANGELOG.md,LICENSE.txt,TODO.md']
  task.options += ['--readme','README.md']

  task.options << '--protected' # Show protected methods
  task.options += ['--template-path',File.join('yard','templates')]
  task.options += ['--title',"YardGhurt v#{YardGhurt::VERSION} Doc"]
end

YardGhurt::GFMFixTask.new do |task|
  task.arg_names = %i[ dev ]
  task.dry_run = false
  task.fix_code_langs = true

  task.before = proc do |t2,args|
    # Do not delete 'file.README.html', as we need it for testing.

    # Root dir of my GitHub Page for CSS/JS
    ghp_root_dir = YardGhurt.to_bool(args.dev) ? '../../esotericpig.github.io' : '../../..'

    t2.css_styles << %Q(<link rel="stylesheet" type="text/css" href="#{ghp_root_dir}/css/prism.css" />)
    t2.js_scripts << %Q(<script src="#{ghp_root_dir}/js/prism.js"></script>)
  end
end

# Probably not useful for others.
YardGhurt::GHPSyncTask.new do |task|
  task.ghp_dir = '../esotericpig.github.io/docs/yard_ghurt/yardoc'
  task.sync_args << '--delete-after'
end

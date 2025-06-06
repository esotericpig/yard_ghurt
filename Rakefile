# encoding: UTF-8
# frozen_string_literal: true

require 'bundler/gem_tasks'

require 'rake/clean'
require 'yard'
require 'yard_ghurt'

task default: %i[doc]

CLEAN.exclude('.git/','.github/','.idea/','stock/')
CLOBBER.include('doc/')

# TEST: To test using different Gem versions:
#         GST=1 bundle update && bundle exec rake doc
desc 'Generate doc'
task doc: %i[yard yard_gfm_fix]

YARD::Rake::YardocTask.new do |task|
  task.files = ['lib/**/*.rb']
  task.options.push('--title',"YardGhurt v#{YardGhurt::VERSION}")
end

YardGhurt::GFMFixTask.new do |task|
  task.arg_names = %i[dev]
  task.dry_run = false
  task.fix_code_langs = true

  task.before = proc do |t2,args|
    # NOTE: Do not delete `file.README.html`, as we need it for testing.

    # Root dir of my GitHub Page for CSS/JS.
    ghp_root_dir = YardGhurt.to_bool(args.dev) ? '../../esotericpig.github.io' : '../../..'

    t2.css_styles << %(<link rel="stylesheet" type="text/css" href="#{ghp_root_dir}/css/prism.css" />)
    t2.js_scripts << %(<script src="#{ghp_root_dir}/js/prism.js"></script>)
  end
end

# Probably not useful for others.
YardGhurt::GHPSyncTask.new do |task|
  task.ghp_dir = '../esotericpig.github.io/docs/yard_ghurt/yardoc'
  task.sync_args << '--delete-after'
end

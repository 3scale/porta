require 'capistrano/ext/multistage'

require 'bundler/capistrano'

require 'airbrake/capistrano'
require 'new_relic/recipes'

load 'deploy' if respond_to?(:namespace) # cap2 differentiator

Dir['vendor/plugins/*/recipes/*.rb'].each { |file| load(file) }
Dir['config/deploy/recipes/**/*.rb'].each { |file| load(file) }

load 'config/deploy' # remove this line to skip loading any of the default tasks
load 'deploy/assets'

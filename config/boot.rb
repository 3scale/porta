require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# just safeguard
ENV['RAILS_ENV'] = 'production' if ENV['RAILS_ENV'] == 'enterprise'

require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])

begin
  require 'bootsnap/setup'
rescue LoadError
  # no bootsnap for you
end

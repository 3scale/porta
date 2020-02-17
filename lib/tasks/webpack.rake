# frozen_string_literal: true
namespace :webpack do
  desc 'Run development server'
  task :dev do
    exec('./bin/webpack-dev-server')
  end
end

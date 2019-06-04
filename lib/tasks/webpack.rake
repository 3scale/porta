# frozen_string_literal: true
namespace :webpack do
  desc 'Run development server'
  task :dev do
    exec('./bin/webpack-dev-server')
  end

  desc 'Compile assets'
  task :compile do
    env = { 'WEBPACKER_NODE_MODULES_BIN_PATH' => `npm bin`.chomp }
    exec(env, './bin/webpack')
  end

  desc 'Compile assets for production'
  task :production do
    puts 'Deleting stale assets...'
    Rake::Task['webpacker:clobber'].invoke

    puts 'Compiling new bundle...'
    ENV['NODE_ENV'] = 'production'
    Rake::Task['webpack:compile'].invoke

    puts "DONE. Don't forget to commit the changes"
  end
end
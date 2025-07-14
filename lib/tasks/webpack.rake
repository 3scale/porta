# frozen_string_literal: true

namespace :webpack do
  desc 'Run development server'
  task :dev do
    exec('yarn dev')
  end

  desc "Compile everything under app/javascript into public/packs and generates production assets manifest"
  task :compile do
    exec('yarn build')
  end
end

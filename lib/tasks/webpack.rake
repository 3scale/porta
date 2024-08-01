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

  task :check_asset_host do
    if Rails.configuration.three_scale.asset_host.present?
      STDERR.puts "*** Asset host must be null during compilation time. See https://github.com/3scale/porta/pull/3072 ***"
      return false
    end
  end

  Rake::Task['webpack:compile'].enhance [:check_asset_host]
end

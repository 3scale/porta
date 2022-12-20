# frozen_string_literal: true

namespace :webpacker do

  task :check_asset_host do
    if Rails.configuration.three_scale.asset_host.present?
      STDERR.puts "*** Asset host must be null during compilation time. See https://github.com/3scale/porta/pull/3072 ***"
      return false
    end
  end

  Rake::Task['webpacker:compile'].enhance [:check_asset_host]
end

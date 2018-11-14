# frozen_string_literal: true

# Credits @oldp https://github.com/rails/webpacker/issues/1330#issuecomment-380418406

# Redefining task so we don't remove the dev dependencies when running on CI
Rake::Task['webpacker:yarn_install'].clear

namespace :webpacker do
  desc 'Support for older Rails versions. Install all JavaScript dependencies as specified via Yarn'
  task :yarn_install do
    if ENV['RAILS_ENV'] == 'production'
      system 'yarn install --no-progress --frozen-lockfile --production'
    else
      system 'yarn install --no-progress'
    end
  end
end

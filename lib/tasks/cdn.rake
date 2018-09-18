# frozen_string_literal: true
CDN_REPO = 'https://github.com/3scale/cdn.git'

namespace :cdn do
  desc 'Adds the CDN repo as a subtree in cdn directory'
  task :add do
    run "git subtree add --prefix cdn #{CDN_REPO} master --squash"
  end

  desc 'Updates the CDN subtree'
  task :update do
    run "git subtree pull --prefix cdn #{CDN_REPO} master --squash"
  end
end

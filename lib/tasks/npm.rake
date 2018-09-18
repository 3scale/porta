
namespace :npm do
  desc 'run npm install'
  task :install do
    run 'yarn install --frozen-lockfile --link-duplicates'
  end
end

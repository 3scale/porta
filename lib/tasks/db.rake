namespace :db do
  desc 'setup database from scratch or just run migrations'
  task :deploy => :environment do
    if ActiveRecord::Migrator.current_version.zero?
      Rake::Task['db:deploy:setup'].invoke
    else
      Rake::Task['db:migrate'].invoke
    end
  end

  namespace :deploy do
    task setup: %w(db:setup countries:import countries:disable_t5)
  end
end

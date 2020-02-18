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
    task setup: %i[environment db:load_config] do
      begin
        ActiveRecord::Tasks::DatabaseTasks.create_current
      rescue ActiveRecord::StatementInvalid => exception
        raise unless exception.message =~ /PG::InsufficientPrivilege/
      end

      Rake::Task['db:schema:load'].invoke
      Rake::Task['db:seed'].invoke

      Rake::Task['countries:import'].invoke
      Rake::Task['countries:disable_t5'].invoke
    end
  end
end

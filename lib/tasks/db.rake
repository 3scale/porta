# frozen_string_literal: true

# On MySQL, DROP TABLE ignores the CASCADE keyword, so dropping a table that is
# referenced by a FK in another table raises "Cannot drop table … referenced by a
# foreign key constraint". schema.rb drops tables in definition order, not
# FK-dependency order, so db:schema:load fails on a non-empty database.
#
# Fix: wrap db:schema:load with SET FOREIGN_KEY_CHECKS=0/1 on MySQL only.
# PostgreSQL is not affected: its DROP TABLE … CASCADE actually removes dependent
# FK constraints, so the schema load already works on a non-empty database.
Rake::Task['db:schema:load'].tap do |t|
  original_actions = t.actions.dup
  t.actions.clear
  t.enhance do
    ActiveRecord::Base.connection_pool.with_connection do |conn|
      if conn.adapter_name == 'Mysql2'
        conn.disable_referential_integrity { original_actions.each { |a| t.instance_exec(t, &a) } }
      else
        original_actions.each { |a| t.instance_exec(t, &a) }
      end
    end
  end
end

namespace :db do
  desc 'setup database from scratch or just run migrations'
  task :deploy => :environment do
    if ActiveRecord::Migrator.current_version.zero?
      Rake::Task['db:deploy:setup'].invoke
    elsif !Account.master?
      Rake::Task['db:deploy:seed'].invoke
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
      Rake::Task['db:deploy:seed'].invoke
    end

    task seed: :environment do
      Rake::Task['db:seed'].invoke

      Rake::Task['countries:import'].invoke
      Rake::Task['countries:disable_t5'].invoke
    end
  end
end

# frozen_string_literal: true

require 'system/database'

namespace :db do
  task :test => :environment do
    ActiveRecord::Base.establish_connection(:test)
  end

  desc "Loads functions and stored procedures to test database"
  task 'test:procedures' => ['db:test', 'db:procedures']

  namespace :procedures do
    task :create => %I[environment] do
      System::Database.procedures.each do |t|
        ActiveRecord::Base.connection.execute(t.create)
      end
    end

    task :drop => %I[environment] do
      System::Database.procedures.each do |t|
        ActiveRecord::Base.connection.execute(t.drop)
      end
    end
  end

  desc 'Recreates the DB procedures (delete+create)'
  task :procedures => %I[environment] do
    puts "Recreating procedures, see log/#{Rails.env}.log"
    procedures = System::Database.procedures
    procedures.each do |procedure|
      procedure.recreate.each do |command|
        ActiveRecord::Base.connection.execute(command)
      end
    end
    puts "Recreated #{procedures.size} procedures"
  end
end

Rake::Task['db:seed'].enhance(['db:procedures'])

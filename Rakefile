require File.expand_path('../config/application', __FILE__)

# Workaround for https://github.com/ruby/rake/issues/116
# until we upgrade rspec
Rake::TaskManager.module_eval do
  alias_method :last_comment, :last_description
end

System::Application.load_tasks

require 'rails/test_unit/runner'
class Rails::TestUnit::Runner
  class << self
    prepend(Module.new do

      # This is a private method, expect this to be broken in the future
      def extract_filters(argv)
        multitests = argv.flat_map { |patterns| patterns.strip.split(/\s+/) }.compact
        puts "TEST='"
        multitests.each do |file|
          print "\t", file, "\n"
        end
        puts "'"
        super(multitests)
      end
    end)
  end
end

namespace :test do
  test_groups = {
    integration: FileList["test/{integration}/**/*_test.rb"],
    functional: FileList["test/{functional}/**/*_test.rb"],
  }

  test_groups[:unit] = FileList['test/**/*_test.rb'].exclude(*test_groups.values).exclude('test/{performance,remote,support}/**/*')

  namespace :files do
    test_groups.each do |name,file_list|
      desc "Print test files for #{name} test group"
      task name do
        puts file_list
      end
    end
  end
end

Rake::Task['db:test:load'].enhance do
  Rake::Task['multitenant:test:triggers'].invoke
  Rake::Task['db:test:procedures'].invoke
end

# In Rails 5.2 the `load_config` task was made dependent on `environment`
# to enable credentials reading, see https://github.com/rails/rails/pull/31135
# This causes the whole app to initialize before `db:create` and that
# causes a database connection for observers, sphinx and maybe others.
# For MySQL where database name is part of connection URL, this causes a
# connection failure and thus failure to create the database.
# Since we don't use credentials, we can remove that dependency.
# And then a whole mess to fix other use cases especally db:reset
warn "Removing :environment prerequisite from db:load_config"
Rake::Task['db:load_config'].prerequisites.delete("environment")
Rake::Task.tasks.select { |task|
  next if task.name == "db:create"
  task.name.start_with?("db:") && task.prerequisites.include?("load_config")
}.each { |task|
  task.prerequisites.insert(task.prerequisites.index("load_config"), "environment")
}
Rake::Task.tasks.select { |task|
    task.prerequisites.include?("db:load_config")
}.each { |task|
  task.prerequisites.insert(task.prerequisites.index("db:load_config"), "environment")
}

namespace :hack do
  desc "Checks whether we need db:drop when running db:reset"
  task reset_needs_drop: "db:load_config" do
    begin
      ActiveRecord::Base.establish_connection(Rails.env.to_sym).connection.table_exists?("accounts")
    rescue ActiveRecord::NoDatabaseError
      warn "db:drop not needed because database does not exist"
      Rake::Task["db:drop"].clear
    end
  end

  # As we remove :environment from db:load_config, the database_configuration might be nil.
  # Since Rails 6.1, the database configuration must be present at db:load_config.
  # As a workaround, we can load the configurations directly from Rails.application.
  desc "Sets ActiveRecord's database configuration in case it's still not present"
  task :set_db_config do
    ActiveRecord::Tasks::DatabaseTasks.database_configuration ||= Rails.application.config.database_configuration || {}
  end
end

Rake::Task["db:reset"].prerequisites.prepend "hack:reset_needs_drop"
Rake::Task["db:load_config"].prerequisites.prepend "hack:set_db_config"

# frozen_string_literal: true

require_relative "config/application"

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

Rake::Task['db:test:load_schema'].enhance do
  Rake::Task['multitenant:test:triggers'].invoke
  Rake::Task['db:test:procedures'].invoke
end

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
end

Rake::Task["db:reset"].prerequisites.prepend "hack:reset_needs_drop"

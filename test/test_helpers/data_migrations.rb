# frozen_string_literal: true

# Test your data migrations as follows.
#
# require 'test_helper'
#
# module DataMigrations
#   class MyDataMigrationTest < DataMigrationTest
#     test 'does something' do
#       migration = MyDataMigration.new
#       assert_something do
#         migration.up
#       end
#     end
#   end
# end

module DataMigrations
  class DataMigrationTest < ActiveSupport::TestCase ; end
end

RailsDataMigrations::LogEntry.create_table unless ActiveRecord::Base.connection.table_exists? RailsDataMigrations::LogEntry.table_name

Dir[Rails.root.join *%w[db data_migrations *.rb]].each { |file| require file }

# frozen_string_literal: true

require 'test_helper'

class SeedsTest < ActiveSupport::TestCase
  class SeedDatabaseConnection < ActiveRecord::Base
    def self.abstract_class?
      true
    end
  end

  disable_transactional_fixtures!

  setup do
    @config = ActiveRecord::Base.configurations['test_seed']
    adapter = ActiveRecord::Tasks::DatabaseTasks.send(:class_for_adapter, config['adapter']).new(config)
    creation_options = adapter.send(:creation_options)
    ActiveRecord::Base.connection.create_database config['database'], creation_options
    ActiveRecord::Tasks::DatabaseTasks.load_schema_for(config)
    SeedDatabaseConnection.establish_connection(:test_seed)
  end

  attr_reader :config

  def after_teardown
    super
    SeedDatabaseConnection.connection.drop_database config['database']
  end

  test 'the seeds do not fail' do
    SeedDatabaseConnection.transaction(requires_new: true) do
      assert Rails.application.load_seed
    end
  end
end

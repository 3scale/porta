require 'test_helper'

class ResetTenantIdTest < ActiveSupport::TestCase
  class QueryTest < ActiveSupport::TestCase

    attr_reader :klass, :record
    def setup
      @klass = mock('Klass')
      @record = mock('instance')
    end

    test 'initialize without updater' do
      assert_raises(ArgumentError) do
        ResetTenantId::Query.new(mock, 'buyers')
      end
    end

    test 'updates `:with` option as Symbol' do
      record.expects(:id).returns('my-id')
      record.expects(:update_column).with(:tenant_id, 'my-id')
      query = ResetTenantId::Query.new(klass,  'buyers', with: :id)
      query.update.call(record)
    end

    test 'updates `:with` option responding to `call`' do
      record.expects(:id).returns('my-id')
      record.expects(:update_database).with(:column, 'my-id')
      query = ResetTenantId::Query.new(klass, 'buyers', with: ->(r){ r.update_database :column, r.id})
      query.update.call(record)
    end

    test 'updates with block' do
      record.expects(:id).returns('my-id')
      record.expects(:update_database).with(:column, 'my-id')
      query = ResetTenantId::Query.new(klass, 'buyers') do |record|
        record.update_database :column, record.id
      end
      query.update.call(record)
    end

    test 'uses the `name` as collection' do
      klass.expects(:buyers)
      query = ResetTenantId::Query.new(klass, 'buyers', with: :id)
      query.collection.call
    end

    test 'uses the `:collection` option as Enumerable' do
      array = [1, 5, 9]
      query = ResetTenantId::Query.new(klass, 'buyers', with: :id, collection: array)
      assert_equal array, query.collection.call
    end

    test 'uses the `:collection` as Proc' do
      klass.expects(:my_collection).returns(%w(a d g))
      query = ResetTenantId::Query.new(klass, 'buyers', with: :id, collection: proc { my_collection })
      assert_equal %w{a d g}, query.collection.call
    end
  end

  class RunnerTest < ActiveSupport::TestCase
    test 'execute' do
      klass = mock('Klass')
      record = OpenStruct.new id: 1
      record.expects(:update_column).with(:tenant_id, 1)
      klass.expects(:buyers).returns([record])
      query = ResetTenantId::Query.new(klass,  'buyers', with: :id)
      definitions = {
        buyers: query
      }

      runner = ResetTenantId::Runner.new(definitions)
      runner.execute(:buyers)
    end
  end
end

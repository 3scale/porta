# frozen_string_literal: true

require 'test_helper'

class OracleStatementCleanupTest < ActiveSupport::TestCase
  # Transactional fixtures pin the connection, making pool.checkin a no-op.
  # This test only reads data and needs real check-in callbacks to run.
  self.use_transactional_tests = false

  setup do
    skip 'Only run on Oracle database' unless System::Database.oracle?
  end

  test 'returning an Oracle connection clears prepared statements and permits reuse after an error' do
    pool = ActiveRecord::Base.connection_pool
    connection = pool.checkout
    bind = ActiveRecord::Relation::QueryAttribute.new('value', 42, ActiveRecord::Type::Integer.new)
    query = 'SELECT :1 FROM dual'

    begin
      assert_equal 42, connection.exec_query(query, 'prepared statement', [bind], prepare: true).rows.first.first
      statements = connection.instance_variable_get(:@statements)
      assert statements.key?(query), 'Expected the query to have a cached cursor'
      pool.checkin(connection)
      assert_equal 0, statements.length

      connection = pool.checkout
      assert_same statements, connection.instance_variable_get(:@statements)
      assert_equal 42, connection.exec_query(query, 'reused statement', [bind], prepare: true).rows.first.first
      assert statements.key?(query), 'Expected the query to be cached again after check-in'
      assert_raises(ActiveRecord::StatementInvalid) do
        connection.exec_query('SELECT :1 FROM porta_nonexistent_table', 'invalid statement', [bind], prepare: true)
      end
      pool.checkin(connection)
      assert_equal 0, statements.length

      connection = pool.checkout
      assert_same statements, connection.instance_variable_get(:@statements)
      assert_equal 42, connection.exec_query(query, 'statement after error', [bind], prepare: true).rows.first.first
      assert statements.key?(query), 'Expected the query to be cached again after the SQL error'
    ensure
      pool.checkin(connection) if connection&.in_use?
    end
  end
end

# frozen_string_literal: true

module ThreeScale
  module TestHelpers
    # Runs the block once and returns the SQL strings of every query executed.
    # Use Array#grep to filter by pattern, e.g.:
    #
    #   queries = capture_sql_queries { relation.to_a }
    #   assert_equal 1, queries.grep(/\bWITH\b/i).size
    #
    def capture_sql_queries
      queries = []
      callback = ->(_name, _start, _finish, _id, values) { queries << values[:sql] unless %w[CACHE SCHEMA].include?(values[:name]) }
      ActiveSupport::Notifications.subscribed(callback, "sql.active_record") { yield }
      queries
    end
  end
end

ActiveSupport::TestCase.include ThreeScale::TestHelpers

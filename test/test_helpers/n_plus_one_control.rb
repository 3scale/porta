require "n_plus_one_control/minitest"

# see https://github.com/palkan/n_plus_one_control/pull/57
# and https://github.com/palkan/n_plus_one_control/issues/61
NPlusOneControl::MinitestHelper.prepend(Module.new do
  class NonTransactionalExecutor < NPlusOneControl::Executor
    SOURCE_LOCATION_SEPARATOR = "\n    ↳ ".freeze

    self.transaction_begin = -> {}
    self.transaction_rollback = -> {}
  end

  # Runs the block once and checks how many SQL queries match.
  # Pass a count to check one query count, or [count, pattern] pairs to check several.
  # A nil pattern uses `matching:` or the default query filter.
  def assert_number_of_queries(expectations, matching: nil, &block)
    raise ArgumentError, "Block is required" unless block_given?

    expectations = query_expectations(expectations, matching)
    queries = captured_queries(&block)
    expectations.each do |expected_count, pattern|
      assert_query_count(expected_count, matching_query_count(queries, pattern))
    end
  end

  private

  def captured_queries(&block)
    @executor = NonTransactionalExecutor.new(population: ->(*) {}, scale_factors: [1])
    @executor.call(&block).first.last.map { |query| query_sql(query) }
  end

  def query_expectations(expectations, matching)
    expectations = [[expectations, matching]] unless expectations.is_a?(Array)
    expectations.map { |expected_count, pattern| [expected_count, pattern || matching || NPlusOneControl.default_matching] }
  end

  def matching_query_count(queries, pattern)
    pattern ? queries.count { |query| query.match?(pattern) } : queries.size
  end

  def assert_query_count(expected_count, actual_count)
    assert_equal expected_count, actual_count, "expected #{expected_count} queries but performed were #{actual_count}"
  end

  def query_sql(query)
    # Verbose collection appends source locations; match only the SQL itself.
    query.partition(NonTransactionalExecutor::SOURCE_LOCATION_SEPARATOR).first
  end
end)

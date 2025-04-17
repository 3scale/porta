require "n_plus_one_control/minitest"

# see https://github.com/palkan/n_plus_one_control/pull/57
# and https://github.com/palkan/n_plus_one_control/issues/61
NPlusOneControl::MinitestHelper.prepend(Module.new do
  class NonTransactionalExecutor < NPlusOneControl::Executor
    self.transaction_begin = -> {}
    self.transaction_rollback = -> {}
  end

  def assert_number_of_queries(number, matching: nil)
    raise ArgumentError, "Block is required" unless block_given?

    @executor = NonTransactionalExecutor.new(matching: (matching || NPlusOneControl.default_matching), population: ->(*){}, scale_factors: [1])
    queries = @executor.call { yield }
    counts = queries.map(&:last).map(&:size)
    assert_equal number, counts.max, "expected #{number} queries but performed were #{counts.max}"
  end
end)

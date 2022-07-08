require "n_plus_one_control/minitest"

# see https://github.com/palkan/n_plus_one_control/pull/57
NPlusOneControl::MinitestHelper.prepend(Module.new do
  def assert_number_of_queries(number, matching: nil)
    raise ArgumentError, "Block is required" unless block_given?

    @executor = NPlusOneControl::Executor.new(matching: (matching || NPlusOneControl.default_matching), population: ->(*){}, scale_factors: [1])
    queries = @executor.call { yield }
    counts = queries.map(&:last).map(&:size)
    assert_equal number, counts.max, "expected #{number} queries but performed were #{counts.max}"
  end
end)

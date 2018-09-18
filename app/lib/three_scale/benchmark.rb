module ThreeScale
  module Benchmark

    def logger
      Rails.logger
    end

    # Copy from rails
    def benchmark(title)
      if logger
        result = nil
        ms = ::Benchmark.ms { result = yield }
        logger.debug { '%s (%.1fms)' % [title, ms] }
        result
      else
        yield
      end
    end

  end
end

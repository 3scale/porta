module ThreeScale
  module Analytics
    class SidekiqMiddleware
      def call(*)
        yield
      ensure
        UserTracking.flush
      end
    end
  end
end

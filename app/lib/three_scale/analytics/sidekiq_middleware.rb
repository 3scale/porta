module ThreeScale
  module Analytics
    class SidekiqMiddleware
      def call(*)
        yield
      ensure
        ::ThreeScale::Analytics::UserTracking.flush
      end
    end
  end
end

module TestHelpers
  module FakeTraffic

    # @param cinstance [Integer, Cinstance]
    # @param range [Range, Date]
    # @return [Cinstance]
    def fake_traffic!(cinstance, range, value: 1)
      dates      = [range.first.to_date, range.last.to_date].sort
      date_range = Range.new(*dates, range.exclude_end?)
      metric     = @provider.default_service.metrics.hits

      date_range.map do |date|
        ::Backend::RandomDataGenerator.hit(cinstance, date.to_time, metric, value)
      end
    end
  end
end

ActiveSupport::TestCase.send(:include, TestHelpers::FakeTraffic)

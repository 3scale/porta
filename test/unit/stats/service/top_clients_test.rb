require File.expand_path(File.dirname(__FILE__) + '/../../../test_helper')

class Stats::Service::ServiceTest < ActiveSupport::TestCase
  def setup
    # TestHelpers::Time::set_format("%a, %e %B %Y %k:%M")
    @provider_account = FactoryBot.create(:provider_account)
    @service = @provider_account.first_service!
    @metric = @service.metrics.hits!

    @storage = Stats::Base.storage
    @storage.flushdb
    Time.zone = "Hawaii"
    @zone = Time.zone
  end

  test "argument error thrown if metric parameter is missing" do
      assert_raise(Stats::InvalidParameterError) do
        data = Stats::Service.new(@service).top_clients( :period => :month,
                                                         :timezone => @zone.name,
                                                         :since => @zone.local(2009, 10).to_s)

      end
  end

  test "argument error thrown if metric is nil" do
      assert_raise(Stats::InvalidParameterError) do
        data = Stats::Service.new(@service).top_clients( :period => :month,
                                                         :timezone => @zone.name,
                                                         :since => @zone.local(2009, 10).to_s,
                                                         :metric => nil)

      end
  end


  test "argument error thrown if period parameter is missing" do
      assert_raise(Stats::InvalidParameterError) do
        data = Stats::Service.new(@service).top_clients( :metric => @metric,
                                                         :timezone => @zone.name,
                                                         :since => @zone.local(2009, 10).to_s)

      end
  end

  test "argument error thrown if since parameter is missing" do
      assert_raise(Stats::InvalidParameterError) do
        data = Stats::Service.new(@service).top_clients( :metric => @metric,
                                                         :timezone => @zone.name )

      end
  end
end

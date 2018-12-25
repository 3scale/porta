require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class UtilizationTest < ActionDispatch::IntegrationTest

  include TestHelpers::BackendClientStubs

  context :no_metrics_on_applications do

    setup do

      @provider = FactoryBot.create :provider_account
      @plan1 = FactoryBot.create :application_plan, :issuer => @provider.default_service

      @service1 = FactoryBot.create :service, :account => @provider, :name => "API1"

      @plan1 = FactoryBot.create :application_plan, :issuer => @service1

      @buyer = FactoryBot.create :buyer_account, :provider_account => @provider

      @application1 = @plan1.create_contract_with(@buyer)

      host! @provider.admin_domain
      provider_login_with @provider.admins.first.username, 'supersecret'

      metrics = FactoryBot.create_list(:metric, 4, service: @service1)

      @data_empty = []

      @data_full = [
        { period: 'day', metric: metrics[0], max_value: 5000, current_value: 6000 },
        { period: 'year', metric: metrics[1], max_value: 10000, current_value: 9000 },
        { period: 'minute', metric: metrics[2], max_value: 666, current_value: 0},
        { period: 'minute', metric: metrics[3], max_value: 0, current_value: 0},
      ].map { |attr| UtilizationRecord.new(attr) }

      @data_infinity = [
        { period: 'day', metric: metrics[0], max_value: 5000, current_value: 4010 },
        { period: 'year', metric: metrics[1], max_value: 10000, current_value: 4000 },
        { period: 'minute', metric: metrics[2], max_value: 666, current_value: 0},
        { period: 'minute', metric: metrics[3], max_value: 0, current_value: 6},
      ].map { |attr| UtilizationRecord.new(attr) }

    end

    should 'application is unmetered' do
      stub_backend_utilization(@data_empty)
      stub_backend_get_keys

      get admin_service_application_path(@application1.service, @application1)
      assert_response :success

      doc = Nokogiri::XML.parse(body)
      assert_equal doc.search("div[@id='application-utilization']").size, 1
      assert_equal doc.search("div[@id='application-utilization']").search("table").size, 0
      assert_equal doc.search("div[@id='application-utilization']").children.first.class, Nokogiri::XML::Text
    end

    should 'application has metrics' do
      stub_backend_utilization(@data_full)
      stub_backend_get_keys

      get admin_service_application_path(@application1.service, @application1)
      assert_response :success

      doc = Nokogiri::XML.parse(body)
      assert_equal doc.search("div[@id='application-utilization']").size, 1
      table = doc.search("div[@id='application-utilization']").search("table[@class='data']")
      assert_equal table.size, 1

      assert_equal table.search("td[@class='above-100']").size, 1*2
      assert_equal table.search("td[@class='above-80']").size, 1*2
      assert_equal table.search("td[@class='above-0']").size, 2*2
      assert_equal table.search("td[@class='infinity']").size, 0*2
    end

    should 'application has metrics with one disabled over the limit' do
      stub_backend_utilization(@data_infinity)
      stub_backend_get_keys

      get admin_service_application_path(@application1.service, @application1)
      assert_response :success

      doc = Nokogiri::XML.parse(body)
      assert_equal doc.search("div[@id='application-utilization']").size, 1
      table = doc.search("div[@id='application-utilization']").search("table[@class='data']")
      assert_equal table.size, 1


      assert_equal table.search("td[@class='above-100']").size, 0*2
      assert_equal table.search("td[@class='above-80']").size, 1*2
      assert_equal table.search("td[@class='above-0']").size, 2*2
      assert_equal table.search("td[@class='infinity']").size, 1*2
    end

  end

end

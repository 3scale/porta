# frozen_string_literal: true

require 'test_helper'
class Provider::Admin::Dashboard::Service::TopTrafficControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryGirl.create(:provider_account)
    @service = @provider.default_service
    FactoryGirl.create_list(:cinstance, 2, service: @service)
    @cinstances = @service.cinstances
    login! @provider
  end

  attr_reader :cinstances

  test 'it renders the applications show links' do
    stats_client  = ::Stats::Service.new(@service)
    current_items = ::Dashboard::TopTrafficPresenter.new(stats_client, cinstances)
                      .cinstances_for(cinstances.pluck(:id))
                      .map.with_index(1) do |cinstance, position|
      app = Dashboard::TopTrafficPresenter::Application.new(cinstance)
      Dashboard::TopTraffic::TopAppPresenter.new(app, position, nil)
    end
    Dashboard::TopTrafficPresenter.any_instance.stubs(current_items: current_items)

    get provider_admin_dashboard_service_top_traffic_path(@service)
    page = Nokogiri::HTML::Document.parse(response.body)
    application_show_paths_displayed = page.xpath("//a[@class='DashboardWidgetList-link']").map { |node| node['href'] }
    assert_same_elements cinstances.map { |cinstance| admin_service_application_path(@service.id, cinstance) }, application_show_paths_displayed
  end
end

# frozen_string_literal: true

require 'test_helper'

class Api::AlertsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @provider = FactoryBot.create(:provider_account)
    login! @provider
  end

  attr_reader :provider

  test 'get index contains the proper urls of the cinstances' do
    alert_limit_collection = FactoryBot.create_list(:limit_alert, 2, account: provider)
    get admin_alerts_path
    assert_response :ok
    alert_limit_collection.each do |alert_limit|
      cinstance = alert_limit.cinstance
      assert_xpath("//a[contains(@href, '#{admin_service_application_path(cinstance.service, cinstance)}')]", cinstance.name)
    end
  end
end

# frozen_string_literal: true

require 'test_helper'

class DeveloperPortal::Admin::Applications::ReferrerFiltersControllerTest < ActionDispatch::IntegrationTest
  include System::UrlHelpers.cms_url_helpers

  def setup
    @provider  = FactoryBot.create(:provider_account)
    buyer      = FactoryBot.create(:buyer_account, provider_account: provider)
    service    = provider.default_service
    app_plan   = FactoryBot.create(:simple_application_plan, issuer: service)
    @cinstance = buyer.buy! app_plan

    service.update!(backend_version: '2')
    service.update_attribute(:referrer_filters_required, true)
    provider.settings.allow_multiple_applications!
    provider.settings.show_multiple_applications!
    service.update_attribute(:default_application_plan_id, app_plan.id)

    login_buyer buyer
  end

  attr_reader :cinstance, :provider

  test 'Attempt to create more referrer filters than the limit fails' do
    cinstance.filters_limit.times do |i|
      cinstance.referrer_filters.add("#{i}.example.org")
    end

    assert_no_difference(ReferrerFilter.method(:count)) do
      post admin_application_referrer_filters_path(cinstance), params: { referrer_filter: "#{cinstance.filters_limit + 1}.example.org" }
    end

    assert_equal 'Limit reached', flash[:error]
  end

  class NotLoggedInTest < ActionDispatch::IntegrationTest
    include System::UrlHelpers.cms_url_helpers

    def setup
      @provider  = FactoryBot.create(:simple_provider)
      service = FactoryBot.create(:simple_service, account: provider)
      plan = FactoryBot.create(:simple_application_plan, issuer: service)
      @cinstance = FactoryBot.create(:simple_cinstance, plan: plan)

      host! provider.domain
    end

    attr_reader :cinstance, :provider

    test 'Creating referrer filter is forbidden if not logged in' do
      assert_no_difference(ReferrerFilter.method(:count)) do
        post admin_application_referrer_filters_path(cinstance), params: { referrer_filter: 'only.my.example.com' }
      end

      assert_redirected_to login_path
    end

    test 'Deleting referrer filter is forbidden if not logged in' do
      referrer_filter = FactoryBot.create(:referrer_filter, application: cinstance)

      assert_no_difference(ReferrerFilter.method(:count)) do
        delete admin_application_referrer_filter_path(cinstance, referrer_filter.id)
      end

      assert_redirected_to login_path
    end
  end

  test 'Creating referrer filter is forbidden if not buyer of the application' do
    another_buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    login_buyer another_buyer

    assert_no_difference(ReferrerFilter.method(:count)) do
      post admin_application_referrer_filters_path(cinstance), params: { referrer_filter: 'only.my.example.com' }
    end

    assert_response :not_found
  end

  test 'Deleting referrer filter is forbidden if not buyer of the application' do
    another_buyer = FactoryBot.create(:buyer_account, provider_account: provider)
    login_buyer another_buyer

    referrer_filter = FactoryBot.create(:referrer_filter, application: cinstance)

    assert_no_difference(ReferrerFilter.method(:count)) do
      delete admin_application_referrer_filter_path(cinstance, referrer_filter.id)
    end

    assert_response :not_found
  end

  test 'xhr create' do
    xhr :post, admin_application_referrer_filters_path(application_id: cinstance.id, referrer_filter: 'only.my.example.com', format: :js)

    assert_response :success
  end

  test 'for buyers in multiple applications mode, create redirects to buyer side application page' do
    post admin_application_referrer_filters_path(application_id: cinstance.id, referrer_filter: 'only.my.example.com')

    assert_redirected_to admin_application_path(cinstance)
  end

  test 'for buyers in single applications mode, create redirects to buyer side access details page' do
    provider.settings.deny_multiple_applications!

    post admin_application_referrer_filters_path(application_id: cinstance.id, referrer_filter: 'only.my.example.com')

    assert_redirected_to admin_applications_access_details_path
  end
end

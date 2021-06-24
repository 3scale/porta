# frozen_string_literal: true

require 'test_helper'

class Buyers::ApplicationsTest < ActionDispatch::IntegrationTest
  def setup
    @provider = FactoryBot.create(:provider_account)

    login! provider

    #TODO: dry with @ignore-backend tag on cucumber
    stub_backend_get_keys
    stub_backend_referrer_filters
    stub_backend_utilization
  end

  attr_reader :provider

  test 'member cannot create an application when lacking access to a service' do
    forbidden_service = FactoryBot.create(:service, account: provider)
    forbidden_plan = FactoryBot.create(:application_plan, issuer: forbidden_service)
    forbidden_service_plan = FactoryBot.create(:service_plan, issuer: forbidden_service)

    authorized_service = FactoryBot.create(:service, account: provider)
    authorized_plan = FactoryBot.create(:application_plan, issuer: authorized_service)
    authorized_service_plan = FactoryBot.create(:service_plan, issuer: authorized_service)

    buyer = FactoryBot.create(:buyer_account, provider_account: provider)

    member = FactoryBot.create(:member, account: provider, member_permission_ids: [:partners])
    member.activate!
    FactoryBot.create(:member_permission, user: member, admin_section: :services, service_ids: [authorized_service.id])

    login_provider provider, user: member

    post admin_buyers_account_applications_path(account_id: buyer.id), cinstance: {
      plan_id: forbidden_plan.id,
      name: 'Not Allowed!',
      service_plan_id: forbidden_service_plan.id
    }

    assert_response :not_found

    post admin_buyers_account_applications_path(account_id: buyer.id), cinstance: {
      plan_id: authorized_plan.id,
      name: 'Allowed',
      service_plan_id: authorized_service_plan.id
    }

    assert_response :found
  end
end

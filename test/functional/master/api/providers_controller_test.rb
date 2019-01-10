require 'test_helper'

class Master::Api::ProvidersControllerTest < ActionController::TestCase

  def setup
    @request.host = master_account.domain
  end

  test 'required master api_key' do
    post :change_partner, api_key: 'invalid-api-key', id: 'foo'
    assert_response 401
  end

 test "without application_plan" do
    provider = FactoryBot.create(:provider_account)
    post :change_partner, id: provider.id, api_key: master_account.api_key
    assert_response 404
 end

  test "application_plan invalid" do
    provider = FactoryBot.create(:provider_account)
    post :change_partner, id: provider.id, api_key: master_account.api_key, application_plan: "lala"
    assert_response 404
  end

  test "valid application_plan for master" do
    provider = FactoryBot.create(:provider_account)
    application_plan = master_account.default_service.application_plans.create(name: "last plan")

    post :change_partner, id: provider.id, api_key: master_account.api_key, application_plan: application_plan.system_name
    assert_response 200
    provider.reload
    assert_equal application_plan, provider.bought_cinstance.application_plan
    assert_nil provider.partner

  end

  test 'valid partner application_plan without specify the partner' do
    provider = FactoryBot.create(:provider_account)

    partner_application_plan = create_partner_application_plan
    post :change_partner, id: provider.id, api_key: master_account.api_key, application_plan: partner_application_plan.system_name

    assert_response 404
  end

  test 'valid partner application_plan for a valid partner' do
    provider = FactoryBot.create(:provider_account)
    partner_application_plan = create_partner_application_plan
    post :change_partner, id: provider.id, api_key: master_account.api_key, application_plan: partner_application_plan.system_name, partner: partner_application_plan.partner.system_name

    assert_response 200
    provider.reload
    assert_equal partner_application_plan.partner, provider.partner
  end

  test 'valid partner application_plan for a invalid partner' do
    provider = FactoryBot.create(:provider_account)

    partner_application_plan = create_partner_application_plan
    partner2 = FactoryBot.create(:partner)
    post :change_partner, id: provider.id, api_key: master_account.api_key, application_plan: partner_application_plan.system_name, partner: partner2.system_name

    assert_response 404
  end


  def create_partner_application_plan
    partner = FactoryBot.create(:partner)
    master_account.default_service.application_plans.create(name: "partner application plan", partner: partner)
  end
end

require 'test_helper'

class Buyers::ServiceContractsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @provider         = FactoryBot.create(:provider_account, provider_account: master_account)
    @service          = FactoryBot.create(:service, account: @provider)
    @service_plan     = FactoryBot.create(:service_plan, issuer: @service)
    @application_plan = FactoryBot.create(:application_plan, issuer: @service)

    @buyer1           = FactoryBot.create(:buyer_account, provider_account: @provider)
    @buyer2           = FactoryBot.create(:buyer_account, provider_account: @provider)
    @service_contract = FactoryBot.create(:simple_service_contract, plan: @service_plan, user_account: @buyer1)

    @buyer1.buy! @application_plan
    @buyer2.buy! @application_plan

    host! @provider.admin_domain
    provider_login_with @provider.admins.first.username, 'supersecret'
  end

  def test_can_unsubscribe_from_service_contract
    get admin_buyers_account_service_contracts_path(account_id: @buyer1.id)

    assert_response :success

    page = Nokogiri::HTML::Document.parse(response.body)

    assert page.xpath("//a[@class='button-to action edit fancybox change_plan']").text =~ /Change\ Plan/
    assert page.xpath("//a[@data-method='delete']").text =~ /Unsubscribe/
  end

  def test_unsubscribe_developers_from_service_with_suspended_application
    apps = @buyer1.bought_cinstances.by_service_id(@service_contract.service_id)
    apps.update_all state: 'suspended'

    delete admin_buyers_account_service_contract_path(@service_contract.id,
                                                      account_id: @buyer1.id),
                                                      {},
                                                      {'HTTP_REFERER' => admin_buyers_service_contracts_path}

    assert_response :redirect
    assert_equal 0, apps.size
    assert_raise(ActiveRecord::RecordNotFound) do
      @service_contract.reload
    end
    assert_equal 1, @buyer2.bought_cinstances.by_service_id(@service_contract.service_id).count
  end

  def test_unsubscribe_developers_from_service_with_one_not_suspended_application
    apps = @buyer1.bought_cinstances.by_service_id(@service_contract.service_id)

    assert_no_difference(-> {apps.count})  do
      delete admin_buyers_account_service_contract_path(account_id: @buyer1.id,
                                                        id: @service_contract.id),
                                                        {},
                                                        {'HTTP_REFERER' => admin_buyers_service_contracts_path}

      assert_response :redirect
      assert_match I18n.t('service_contracts.unsubscribe_failure'), flash[:error]
    end
  end

  def test_unsubscribe_developers_from_service_with_two_no_suspended_applications
    application_plan2 = FactoryBot.create(:application_plan, issuer: @service)

    @buyer1.buy! application_plan2
    delete admin_buyers_account_service_contract_path(account_id: @buyer1.id,
                                                      id: @service_contract.id),
                                                      {},
                                                      {'HTTP_REFERER' => admin_buyers_service_contracts_path}

    assert_response :redirect
    assert_match I18n.t('service_contracts.unsubscribe_failure'), flash[:error]
  end

  def test_unauthorized_access_master_on_premises
    login! master_account
    ThreeScale.stubs(master_on_premises?: true)
    get admin_buyers_account_service_contracts_path(account_id: @provider.id)
    assert_response :forbidden
  end
end

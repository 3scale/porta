require 'test_helper'

class Abilities::ProviderAdminTest < ActiveSupport::TestCase

  def setup
    @account = FactoryBot.create(:provider_account)
    @admin   = @account.users.where(role: 'admin').first
    ThreeScale.config.stubs(onpremises: false)
  end

  def test_forum
    Account.any_instance.expects(:provider_can_use?).returns(true).at_least_once
    assert_can ability, :manage, :forum

    Account.any_instance.expects(:provider_can_use?).returns(false).at_least_once
    assert_cannot ability, :manage, :forum
  end

  def test_web_hooks
    Settings::Switch.any_instance.stubs(:allowed?).returns(false)
    assert_can ability, :admin, :web_hooks
    assert_cannot ability, :manage, :web_hooks

    # ability :manage depends on :admin ability and the switch
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)
    assert_can ability, :admin, :web_hooks
    assert_can ability, :manage, :web_hooks
  end

  def test_plans
    [:account_plans, :service_plans].each do |name|
      #SaaS
      ThreeScale.config.stubs(onpremises: false)

      Settings::Switch.any_instance.stubs(:allowed?).returns(false)
      assert_can ability, :admin, name
      assert_cannot ability, :manage, name

      # ability :manage depends on :admin ability and the switch
      Settings::Switch.any_instance.stubs(:allowed?).returns(true)
      assert_can ability, :admin, name
      assert_can ability, :manage, name

      # On premises
      ThreeScale.config.stubs(onpremises: true)

      Settings::Switch.any_instance.stubs(:allowed?).returns(false)
      assert_cannot ability, :see, name
      assert_cannot ability, :manage, name

      # ability :manage depends on :admin ability and the switch
      Settings::Switch.any_instance.stubs(:allowed?).returns(true)
      assert_can ability, :see, name
      assert_can ability, :manage, name
    end
  end

  def test_multiple_services
    # SaaS & On premises
    [true, false].each do |onprem|
      ThreeScale.config.stubs(onpremises: onprem)

      Settings::Switch.any_instance.stubs(:allowed?).returns(false)
      assert_can ability, :admin, :multiple_services
      assert_cannot ability, :manage, :multiple_services

      # ability :manage depends on :admin ability and the switch
      Settings::Switch.any_instance.stubs(:allowed?).returns(true)
      assert_can ability, :admin, :multiple_services
      assert_can ability, :manage, :multiple_services
    end
  end

  def test_services
    service_1 = FactoryBot.build_stubbed(:service, id: 1)
    service_2 = FactoryBot.build_stubbed(:service, id: 2, account: @account)
    service_3 = FactoryBot.build_stubbed(:service, id: 3, account: @account)

    assert_cannot ability, :show, service_1
    assert_can ability, :show, service_2
    assert_can ability, :show, service_3
  end

  def test_destroy_services
    service_1 = FactoryBot.create(:simple_service)
    account = service_1.account
    Settings::Switch.any_instance.stubs(:allowed?).returns(true)

    @admin = FactoryBot.create(:admin, account: account)
    service_2 = FactoryBot.create(:simple_service, account: account)

    assert_can ability, :destroy, service_1
    assert_can ability, :destroy, service_2

    service_2.destroy!
    assert_cannot ability, :destroy, service_1
  end

  def test_csv_data_export_event
    admin_1 = @admin
    admin_2 = FactoryBot.build_stubbed(:admin, account: @account)
    admin_1_ability = Ability.new(admin_1)
    admin_2_ability = Ability.new(admin_2)

    event_for_admin_1 = Reports::CsvDataExportEvent.create(@account, admin_1, 'users', 'week')
    event_for_admin_2 = Reports::CsvDataExportEvent.create(@account, admin_2, 'users', 'week')

    assert_can admin_1_ability, :show, event_for_admin_1
    assert_cannot admin_2_ability, :show, event_for_admin_1

    assert_cannot admin_1_ability, :show, event_for_admin_2
    assert_can admin_2_ability, :show, event_for_admin_2

    assert_can ability, :export, :data
  end

  def test_partner_can_manage_user_and_multiple_users?
    partner = FactoryBot.build_stubbed(:partner)
    provider = FactoryBot.build_stubbed(:simple_provider, partner: partner)
    @admin = FactoryBot.build_stubbed(:admin, account: provider)

    partner.system_name = 'appdirect'
    assert_cannot ability, :manage, User
    assert_cannot ability, :manage, Invitation
    assert_cannot ability, :manage, :multiple_users

    partner.system_name = 'heroku'
    assert_cannot ability, :manage, User
    assert_cannot ability, :manage, Invitation
    assert_cannot ability, :manage, :multiple_users

    partner.system_name = 'redhat'
    assert_can ability, :manage, User
    assert_can ability, :manage, Invitation
    assert_cannot ability, :manage, :multiple_users
  end

  def test_manage_account
    assert_can ability, :manage, @account
  end

  def test_manage_user
    assert_can ability, :manage, @admin
  end

  def test_cinstances
    assert_can ability, :show, Cinstance
  end

  def test_billing
    invoice = FactoryBot.build_stubbed(:invoice, provider_account_id: @account.id)
    ThreeScale.config.stubs(onpremises: false)
    finance = mock
    finance.stubs(allowed?: true)
    @account.settings.stubs(finance: finance)

    assert_can ability, :manage, :credit_card
    assert_can ability, :manage, invoice

    # master test
    ThreeScale.config.stubs(onpremises: true)
    @account.stubs(master?: true)

    assert_cannot ability, :manage, :credit_card
    assert_cannot ability, :manage, invoice

    ThreeScale.config.stubs(onpremises: false)
    finance = mock
    finance.stubs(allowed?: true)
    @account.settings.stubs(finance: finance)

    assert_can ability, :manage, :credit_card
    assert_can ability, :manage, invoice
  end

  def test_upgrade
    @account.stubs(:has_bought_cinstance?).returns(true)
    @account.stubs(:has_best_plan?).returns(false)

    # On premises
    ThreeScale.config.stubs(onpremises: true)
    assert_cannot ability, :upgrade, @account

    # Saas
    ThreeScale.config.stubs(onpremises: false)
    assert_can ability, :upgrade, @account
  end

  def test_portal
    assert_can ability, :manage, :portal
  end

  def ability
    Ability.new(@admin)
  end
end

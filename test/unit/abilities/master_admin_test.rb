require 'test_helper'

class Abilities::MasterAdminTest < ActiveSupport::TestCase

  def setup
    @account = FactoryGirl.build_stubbed(:simple_master)
    @admin  = FactoryGirl.build_stubbed(:simple_admin, account: @account)
  end

  def test_tenant_users
    tenant      = FactoryGirl.build_stubbed(:simple_buyer, provider_account: @account)
    tenant_user = FactoryGirl.build_stubbed(:simple_user, account: tenant)

    assert_can ability, :activate, tenant_user
  end

  def test_account
    assert_can ability, :manage, @account
  end

  def test_provider_management
    provider = FactoryGirl.build_stubbed(:simple_provider, provider_account: @account)
    assert_cannot ability, :resume, provider

    assert_can ability, :update, provider
    assert_cannot ability, :impersonate, provider

    provider.state = 'scheduled_for_deletion'
    assert_cannot ability, :update, provider
    assert_can ability, :resume, provider
  end

  def test_user
    assert_can ability, :manage, @admin

    assert_cannot ability, :destroy, @admin
    assert_cannot ability, :update_role, @admin
  end

  def test_provider_plans
    ThreeScale.config.stubs(onpremises: false)
    assert_can ability, :manage, :provider_plans

    ThreeScale.config.stubs(onpremises: true)
    assert_cannot ability, :manage, :provider_plans
  end

  def test_multiple_services
    ThreeScale.config.stubs(onpremises: false)
    assert_can ability, :manage, :multiple_services

    ThreeScale.config.stubs(onpremises: true)
    assert_cannot ability, :manage, :multiple_services
  end

  def test_service_plans
    ThreeScale.config.stubs(onpremises: false)
    assert_cannot ability, :manage, :service_plans

    ThreeScale.config.stubs(onpremises: true)
    assert_cannot ability, :manage, :service_plans
  end


  def test_plans
    ThreeScale.config.stubs(onpremises: false)
    assert_can ability, :manage, :plans

    ThreeScale.config.stubs(onpremises: true)
    assert_cannot ability, :manage, :plans
    assert_cannot ability, :create, :plans
    assert_can ability, :admin, :plans
  end

  def test_finance_on_saas
    invoice = FactoryGirl.build_stubbed(:invoice, provider_account_id: @account.id)

    ThreeScale.config.stubs(onpremises: false)
    assert_can ability, :manage, :finance
    assert_can ability, :manage, invoice

    ThreeScale.config.stubs(onpremises: true)
    assert_cannot ability, :manage, :finance

    assert_cannot ability, :manage, invoice
  end

  def test_portal
    [true, false].each do |onpremises|
      ThreeScale.config.stubs(onpremises: onpremises)
      assert_cannot ability, :manage, :portal
    end
  end

  private

  def ability
    Ability.new(@admin)
  end
end
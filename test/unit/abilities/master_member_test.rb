require 'test_helper'

class Abilities::MasterMemberTest < ActiveSupport::TestCase

  def setup
    @provider = FactoryBot.build_stubbed(:simple_provider)
    @member   = FactoryBot.build_stubbed(:member, account: @provider)

    @provider.stubs(:master?).returns(true)
  end

  def test_finance_on_saas
    ThreeScale.config.stubs(onpremises: false)
    assert_cannot ability, :admin, :finance

    @member.admin_sections = [:finance]
    assert_can ability, :admin, :finance
  end


  def test_finance_on_premises
    ThreeScale.config.stubs(onpremises: true)
    assert_cannot ability, :admin, :finance

    @member.admin_sections = [:finance]
    assert_cannot ability, :admin, :finance
  end

  def test_portal
    [true, false].each do |onpremises|
      ThreeScale.config.stubs(onpremises: onpremises)
      assert_cannot ability, :manage, :portal
    end
  end

  def test_provider_management
    provider = FactoryBot.build_stubbed(:simple_provider, provider_account: @account)
    assert_cannot ability, :resume, provider

    assert_cannot ability, :update, provider
    assert_cannot ability, :impersonate, provider

    @member.admin_sections = [:partners]
    assert_can ability, :update, provider
    assert_cannot ability, :impersonate, provider

    provider.state = 'scheduled_for_deletion'
    assert_cannot ability, :update, provider
    assert_can ability, :resume, provider
  end

  def test_account
    assert_can ability, :create, Account
  end

  def test_provider_plans
    @member.stubs(:has_permission?)

    @member.expects(:has_permission?).with(:partners).returns(true)
    assert_can ability, :manage, :provider_plans

    @member.expects(:has_permission?).with(:partners).returns(false)
    assert_cannot ability, :manage, :provider_plans
  end

  private

  def ability
    Ability.new(@member)
  end
end

require 'test_helper'

module Abilities
  class MasterMemberTest < ActiveSupport::TestCase

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

    %w[suspended scheduled_for_deletion].each do |state|
      test "can resume a #{state} provider with partners permission" do
        @member.admin_sections = [:partners]
        @provider.stubs(:provider_can_use?).with(:service_permissions).returns(true)
        provider = FactoryBot.build_stubbed(:simple_provider, provider_account: @provider, state: state)

        assert_can ability, :resume, provider
      end

      test "cannot resume a #{state} provider without partners permission" do
        @provider.stubs(:provider_can_use?).with(:service_permissions).returns(true)
        provider = FactoryBot.build_stubbed(:simple_provider, provider_account: @provider, state: state)

        assert_cannot ability, :resume, provider
      end

      test "cannot resume a #{state} provider without service permissions feature" do
        @member.admin_sections = [:partners]
        @provider.stubs(:provider_can_use?).with(:service_permissions).returns(false)
        provider = FactoryBot.build_stubbed(:simple_provider, provider_account: @provider, state: state)

        assert_cannot ability, :resume, provider
      end
    end

    def test_provider_plans
      @member.stubs(:has_permission?)

      ThreeScale.config.stubs(onpremises: false)

      @member.expects(:has_permission?).with(:partners).returns(true)
      assert_can ability, :manage, :provider_plans

      @member.expects(:has_permission?).with(:partners).returns(false)
      assert_cannot ability, :manage, :provider_plans

      ThreeScale.config.stubs(onpremises: true)
      @member.expects(:has_permission?).with(:partners).returns(true)
      assert_cannot ability, :manage, :provider_plans
    end

    private

    def ability
      Ability.new(@member)
    end
  end
end

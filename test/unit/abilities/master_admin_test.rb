# frozen_string_literal: true

require 'test_helper'

module Abilities
  class MasterAdminTest < ActiveSupport::TestCase

    def setup
      @account = FactoryBot.build_stubbed(:simple_master)
      @admin  = FactoryBot.build_stubbed(:simple_admin, account: @account)
    end

    def test_tenant_users
      tenant      = FactoryBot.build_stubbed(:simple_buyer, provider_account: @account)
      tenant_user = FactoryBot.build_stubbed(:simple_user, account: tenant)

      assert_can ability, :activate, tenant_user
    end

    def test_account
      assert_can ability, :manage, @account

      assert_can ability, :create, Account
    end

    def test_provider_management
      provider = FactoryBot.build_stubbed(:simple_provider, provider_account: @account)
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
      assert_can ability, :create, :plans
      assert_can ability, :create, Service
      assert_can ability, :destroy, Service

      ThreeScale.config.stubs(onpremises: true)
      assert_can ability, :manage, :plans
      assert_cannot ability, :create, :plans
      assert_cannot ability, :create, Service
      assert_cannot ability, :destroy, Service
    end

    def test_finance_on_saas
      invoice = FactoryBot.build_stubbed(:invoice, provider_account_id: @account.id)

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

    test 'backend apis and backend api components' do
      %i[show edit update create destroy].each do |action|
        assert_can ability, action, BackendApi, "Expected user to be able to #{action} BackendApi, but it's not"
      end
    end

    test 'backend api configs' do
      assert_can ability, :manage, BackendApiConfig
    end

    private

    def ability
      Ability.new(@admin)
    end
  end
end

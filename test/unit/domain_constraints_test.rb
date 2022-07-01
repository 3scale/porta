require 'test_helper'

class DomainConstraintsTest < ActiveSupport::TestCase

  class BuyerDomainConstraintsTest < DomainConstraintsTest
    setup do
      ThreeScale.config.stubs(tenant_mode: 'multitenant')
      @domain = 'domain.example.com'

      @request = ActionDispatch::TestRequest.create
      @request.host = @domain
    end

    attr_reader :domain, :request

    test 'master domain is not a buyer domain' do
      request.stubs(:host).returns(master_account.internal_domain)
      refute BuyerDomainConstraint.matches?(request)
    end

    test 'multitenant accepting buyer domain' do
      FactoryBot.create(:simple_provider, domain: domain)

      assert Account.exists?(domain: domain)
      assert BuyerDomainConstraint.matches?(request)
    end

    test 'multitenant not recognizing a non-existent buyer domain' do
      refute Account.exists?(domain: domain)
      refute BuyerDomainConstraint.matches?(request)
    end

    test 'multitenant not recognizing a buyer domain of a provider scheduled for deletion' do
      provider = FactoryBot.create(:simple_provider, domain: domain)
      provider.schedule_for_deletion!

      assert Account.exists?(domain: domain)
      refute BuyerDomainConstraint.matches?(request)
    end
  end

  class ProviderDomainConstraintTest < DomainConstraintsTest
    setup do
      ThreeScale.config.stubs(tenant_mode: 'multitenant')
      @self_domain = 'admin.example.com'

      @request = ActionDispatch::TestRequest.create
      @request.host = @self_domain
      AuthenticatedSystem::Request.any_instance.stubs(:zync?).returns(false)
    end

    attr_reader :self_domain, :request

    test 'multitenant accepting provider domain' do
      FactoryBot.create(:simple_provider, self_domain: self_domain)

      assert Account.exists?(self_domain: self_domain)
      assert ProviderDomainConstraint.matches?(request)
    end

    test 'multitenant not recognizing a non-existent provider domain' do
      refute Account.exists?(self_domain: self_domain)
      refute ProviderDomainConstraint.matches?(request)
    end

    test 'multitenant not recognizing a domain of a provider scheduled for deletion' do
      provider = FactoryBot.create(:simple_provider, self_domain: self_domain)
      provider.schedule_for_deletion!

      assert Account.exists?(self_domain: self_domain)
      refute ProviderDomainConstraint.matches?(request)
    end

    test 'multitenant recognizing a domain of a provider scheduled for deletion if the request comes from Zync' do
      provider = FactoryBot.create(:simple_provider, self_domain: self_domain)
      provider.schedule_for_deletion!
      AuthenticatedSystem::Request.any_instance.stubs(:zync?).returns(true)

      assert Account.exists?(self_domain: self_domain)
      assert ProviderDomainConstraint.matches?(request)
    end

    test 'master domain' do
      master = master_account
      request = ActionDispatch::TestRequest.create
      request.host = master.internal_domain

      refute ProviderDomainConstraint.matches?(request)
    end
  end

  class MasterDomainConstraintTest < DomainConstraintsTest
    test 'master domain' do
      master = master_account
      request = ActionDispatch::TestRequest.create
      request.host = master.internal_domain
      assert MasterDomainConstraint.matches?(request)
    end

    test 'accepts any domain on premises' do
      ThreeScale.config.stubs(onpremises: true)
      ThreeScale.config.stubs(tenant_mode: 'master')

      master = master_account
      request = ActionDispatch::TestRequest.create
      request.host = master.internal_domain

      assert MasterDomainConstraint.matches?(request)

      request.stubs(:host).returns('different' + master.internal_domain)
      assert MasterDomainConstraint.matches?(request)
    end
  end

  class PortConstraintTest < ActiveSupport::TestCase
    def setup
      @constraint = PortConstraint.new(9090)
    end

    test 'accepts with correct port' do
      request = ActionDispatch::TestRequest.create
      request.host = 'domain.example.com:9090'
      assert @constraint.matches?(request)
    end

    test 'rejects with incorrect port' do
      request = ActionDispatch::TestRequest.create
      request.host = 'domain.example.com:9395'
      refute @constraint.matches?(request)
    end
  end
end

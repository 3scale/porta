require 'test_helper'

class DomainConstraintsTest < ActiveSupport::TestCase

  def setup
    ThreeScale::DevDomain.stubs(enabled?: false)
  end

  class BuyerDomainConstraintsTest < DomainConstraintsTest
    setup do
      ThreeScale.config.stubs(tenant_mode: 'multitenant')
      @domain = 'domain.example.com'

      @request = mock
      @request.stubs(:host).returns(@domain)
    end

    attr_reader :domain, :request

    test 'master domain is not a buyer domain' do
      request.stubs(:host).returns(master_account.domain)
      refute BuyerDomainConstraint.matches?(request)
    end

    test 'multitenant accepting buyer domain' do
      FactoryGirl.create(:simple_provider, domain: domain)

      assert Account.exists?(domain: domain)
      assert BuyerDomainConstraint.matches?(request)
    end

    test 'multitenant not recognizing a non-existent buyer domain' do
      refute Account.exists?(domain: domain)
      refute BuyerDomainConstraint.matches?(request)
    end

    test 'multitenant not recognizing a buyer domain of a provider scheduled for deletion' do
      provider = FactoryGirl.create(:simple_provider, domain: domain)
      provider.schedule_for_deletion!

      assert Account.exists?(domain: domain)
      refute BuyerDomainConstraint.matches?(request)
    end
  end

  class ProviderDomainConstraintTest < DomainConstraintsTest
    setup do
      ThreeScale.config.stubs(tenant_mode: 'multitenant')
      @self_domain = 'admin.example.com'

      @request = mock
      @request.stubs(:host).returns(@self_domain)
      AuthenticatedSystem::Request.any_instance.stubs(:zync?).returns(false)
    end

    attr_reader :self_domain, :request

    test 'multitenant accepting provider domain' do
      FactoryGirl.create(:simple_provider, self_domain: self_domain)

      assert Account.exists?(self_domain: self_domain)
      assert ProviderDomainConstraint.matches?(request)
    end

    test 'multitenant not recognizing a non-existent provider domain' do
      refute Account.exists?(self_domain: self_domain)
      refute ProviderDomainConstraint.matches?(request)
    end

    test 'multitenant not recognizing a domain of a provider scheduled for deletion' do
      provider = FactoryGirl.create(:simple_provider, self_domain: self_domain)
      provider.schedule_for_deletion!

      assert Account.exists?(self_domain: self_domain)
      refute ProviderDomainConstraint.matches?(request)
    end

    test 'multitenant recognizing a domain of a provider scheduled for deletion if the request comes from Zync' do
      provider = FactoryGirl.create(:simple_provider, self_domain: self_domain)
      provider.schedule_for_deletion!
      AuthenticatedSystem::Request.any_instance.stubs(:zync?).returns(true)

      assert Account.exists?(self_domain: self_domain)
      assert ProviderDomainConstraint.matches?(request)
    end
  end

  class MasterDomainConstraintTest < DomainConstraintsTest
    test 'master domain' do
      master = master_account
      request = mock
      request.expects(:host).returns(master.domain)
      assert MasterDomainConstraint.matches?(request)
    end

    test 'accepts any domain on premises' do
      ThreeScale.config.stubs(onpremises: true)
      ThreeScale.config.stubs(tenant_mode: 'master')
      master = master_account
      request = mock

      request.stubs(:host).returns(master.domain)
      assert MasterDomainConstraint.matches?(request)

      request.stubs(:host).returns('different' + master.domain)
      assert MasterDomainConstraint.matches?(request)
    end
  end
end


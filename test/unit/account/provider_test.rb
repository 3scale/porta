# frozen_string_literal: true

require 'test_helper'

class Account::ProviderTest < ActiveSupport::TestCase
  test 'destroy dependent' do
    account = FactoryBot.create(:simple_provider)
    FactoryBot.create(:authentication_provider, account: account)
    FactoryBot.create(:self_authentication_provider, account: account)
    assert_difference('AuthenticationProvider.count', -2) { account.destroy! }
  end

  test 'authentication_providers build_kind' do
    account = FactoryBot.create(:simple_provider)
    (AuthenticationProvider.available(AuthenticationProvider.account_types[:developer]) + [AuthenticationProvider::Custom]).each do |authentication_provider_class|
      kind_name = authentication_provider_class.to_s.demodulize
      authentication_provider = account.authentication_providers.build_kind(kind: kind_name, client_id: 'id', client_secret: 'secret', site: 'http://example.com')
      assert_equal authentication_provider_class, authentication_provider.class
      assert_equal kind_name.downcase, authentication_provider.kind
      assert_equal account, authentication_provider.account
      authentication_provider.valid? && puts(authentication_provider.errors.map(&:full_messages))
      assert authentication_provider.valid?
    end
  end

  test 'self_authentication_providers build_kind valid kinds' do
    account = FactoryBot.create(:simple_provider)
    AuthenticationProvider.available(AuthenticationProvider.account_types[:provider]).each do |authentication_provider_class|
      kind_name = authentication_provider_class.to_s.demodulize
      authentication_provider = account.self_authentication_providers.build_kind(kind: kind_name, client_id: 'id', client_secret: 'secret', site: 'http://example.com')
      assert_equal authentication_provider_class, authentication_provider.class
      assert_equal kind_name.downcase, authentication_provider.kind
      assert_equal account, authentication_provider.account
      authentication_provider.valid? && puts(authentication_provider.errors.map(&:full_messages))
      assert authentication_provider.valid?
    end
  end

  test 'self_authentication_providers build_kind invalid kinds' do
    account = FactoryBot.create(:simple_provider)
    available_only_for_developers = (AuthenticationProvider.available(AuthenticationProvider.account_types[:developer]) - AuthenticationProvider.available(AuthenticationProvider.account_types[:provider])).map { |ap_class| ap_class.to_s.demodulize }
    available_only_for_developers += ['CustomKind-123456']
    available_only_for_developers.each do |authentication_provider_class|
      authentication_provider = account.self_authentication_providers.build_kind(kind: authentication_provider_class, client_id: 'id', client_secret: 'secret', site: 'http://example.com')
      assert_equal account, authentication_provider.account
      assert_not authentication_provider.valid?
    end
  end

  test '#api_key?' do
    provider = FactoryBot.create(:simple_provider)
    assert_not provider.api_key?

    FactoryBot.create(:cinstance, user_account: provider)
    assert provider.api_key?
  end

  test '#missing_api_key?' do
    provider = FactoryBot.create(:simple_provider)
    assert provider.missing_api_key?

    FactoryBot.create(:cinstance, user_account: provider)
    assert_not provider.missing_api_key?
  end

  test 'provider?' do
    account = Account.new
    assert_not account.partner?
    account.expects(:partner_id).returns(42)
    assert account.partner?
  end

  test 'viral footer should not be applied on plan upgrade' do
    provider = FactoryBot.create :provider_account
    assert provider.should_apply_email_engagement_footer?, 'Expected to have a viral footer'

    plan = FactoryBot.create :published_plan, :system_name => 'enterprise', issuer: master_account.services.first

    provider.force_upgrade_to_provider_plan! plan
    assert_not provider.should_apply_email_engagement_footer?, 'Expected to skip the viral footer'
  end

  test '#require_billing_information! and #require_billing_information? and validations' do
    account = Account.new
    assert_not account.require_billing_information?
    account.require_billing_information!
    assert account.require_billing_information?

    assert_not account.valid?

    assert account.errors.messages[:org_legaladdress].present?
    assert account.errors.messages[:country].present?
    assert account.errors.messages[:state_region].present?
    assert account.errors.messages[:city].present?
    assert account.errors.messages[:zip].present?
  end

  test '#customer' do
    account = Account.new

    account.billing_address_first_name = 'foo'
    account.billing_address_last_name = 'bar'
    account.billing_address_phone = '42'

    customer = account.customer
    assert_equal 'foo', customer.first_name
    assert_equal 'bar', customer.last_name
    assert_equal '42', customer.phone
  end

  test '#billing_address_data' do
    account = Account.new
    account.billing_address_name = 'foo'
    account.billing_address_address1 = 'bar'
    account.billing_address_city = 'qwe'
    account.billing_address_country = 'asd'
    account.billing_address_state = 'rty'
    account.billing_address_zip = 'poi'

    billing_address_data = account.billing_address_data

    assert_equal 'foo', billing_address_data.company
    assert_equal 'bar', billing_address_data.street_address
    assert_equal 'qwe', billing_address_data.locality
    assert_equal 'asd', billing_address_data.country_name
    assert_equal 'rty', billing_address_data.region
    assert_equal 'poi', billing_address_data.postal_code
  end

  subject { @account || Account.new }

  should belong_to(:provider_account)
  should have_one(:go_live_state)
  should have_many(:buyer_users).through(:buyer_accounts)
  should have_one(:billing_strategy)
  should have_many(:buyer_invoices)
  should have_many(:buyer_line_items)
  should have_many(:redirects)
  should have_many(:templates)
  should have_many(:groups)
  should have_many(:provided_sections)

  test '#show_xss_protection_options? should' do
    account = FactoryBot.build_stubbed(:provider_account)
    settings = account.settings

    settings.cms_escape_published_html = true
    settings.cms_escape_draft_html = true
    assert_not account.show_xss_protection_options?

    settings.cms_escape_published_html = true
    settings.cms_escape_draft_html = false
    assert account.show_xss_protection_options?

    settings.cms_escape_published_html = false
    settings.cms_escape_draft_html = true
    assert account.show_xss_protection_options?

    settings.cms_escape_published_html = false
    settings.cms_escape_draft_html = true
    assert account.show_xss_protection_options?
  end

  class AfterCreatedTest < ActiveSupport::TestCase
    setup do
      @subject = Account.new(org_name: "prov", provider_account: master_account, subdomain: 'prov', self_subdomain: 'prov-admin')
    end

    attr_reader :subject

    test 'should have an sso_key' do
      subject.provider = true
      subject.save!
      assert_not_nil subject.settings.sso_key
    end

    test 'should not have a default service anymore' do
      prov = subject
      prov.provider = true
      prov.save!

      assert prov.provider?
      assert prov.default_service_id.blank?
    end

    test 'should have a s3_prefix' do
      prov = subject
      prov.provider = true
      prov.save!

      assert prov.provider?
      assert_equal 'prov', prov.s3_prefix
    end

    test 'should have a go_live_state' do
      prov = subject
      prov.provider = true
      prov.save
      assert prov.go_live_state.present?
    end
  end

  class ForTheProviderTest < ActiveSupport::TestCase
    setup do
      @provider =  FactoryBot.create(:provider_account)
      @buyers = FactoryBot.create_list(:simple_buyer, 2, provider_account: @provider)
    end

    class WithoutPlansTest < ForTheProviderTest
      test 'Account#from_email should have default' do
        assert_equal Rails.configuration.three_scale.noreply_email, @provider.from_email
      end

      test 'Account#from_email should return correct if customized' do
        mail = 'foo@example.net'
        @provider.from_email = mail
        assert_equal mail, @provider.from_email
      end
    end

    class WithPlansTest < ForTheProviderTest
      def setup
        super
        services = FactoryBot.create_list(:simple_service, 2, account: @provider)
        @service_one, @service_two = services

        service_one_application_plans = FactoryBot.create_list(:simple_application_plan, 2, issuer: @service_one)
        @service_two_application_plans = FactoryBot.create_list(:simple_application_plan, 2, issuer: @service_two)

        service_plans = services.map { |service| FactoryBot.create(:service_plan, issuer: service) }
        service_plans.map { |plan| @buyers.first.buy!(plan) }

        @service_one_cinstances = service_one_application_plans.map { |plan| @buyers.first.buy!(plan) }
        @service_two_application_plans.map { |plan| @buyers.second.buy!(plan) }
      end

      test 'Account#account_plans should have #default' do
        assert_not_nil @provider.account_plans.default
      end

      test 'Account#application_plans should return all application plans provided by one of the service of the account' do
        assert_same_elements ApplicationPlan.provided_by(@provider), @provider.application_plans
      end

      test 'Account#application_plans should return only issued by issuer if called with issued_by scope' do
        assert_same_elements @service_two_application_plans, @provider.application_plans.issued_by(@service_two)
      end

      test 'Account#provided_cinstances should return all provided cinstances' do
        assert_same_elements Cinstance.provided_by(@provider), @provider.provided_cinstances
      end

      test 'Account#provided_cinstances should return only cinstances for issuer if called with issued_by scope' do
        assert_same_elements @service_one_cinstances, @provider.provided_cinstances.by_service(@service_one)
      end
    end
  end
end

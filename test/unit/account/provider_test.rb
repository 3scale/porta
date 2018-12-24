require 'test_helper'

class Account::ProviderTest < ActiveSupport::TestCase

  context 'authentication_providers' do
    setup do
      @account = FactoryBot.create(:simple_provider)
    end

    should 'destroy dependent' do
      FactoryBot.create(:authentication_provider, account: @account)
      FactoryBot.create(:self_authentication_provider, account: @account)
      assert_difference('AuthenticationProvider.count', -2) { @account.destroy! }
    end

    should 'authentication_providers build_kind' do
      (AuthenticationProvider.available(AuthenticationProvider.account_types[:developer]) + [AuthenticationProvider::Custom]).each do |authentication_provider_class|
        kind_name = authentication_provider_class.to_s.demodulize
        authentication_provider = @account.authentication_providers.build_kind(kind: kind_name, client_id: 'id', client_secret: 'secret', site: 'http://example.com')
        assert_equal authentication_provider_class, authentication_provider.class
        assert_equal kind_name.downcase, authentication_provider.kind
        assert_equal @account, authentication_provider.account
        authentication_provider.valid? && puts(authentication_provider.errors.full_messages)
        assert authentication_provider.valid?
      end
    end

    should 'self_authentication_providers build_kind valid kinds' do
      AuthenticationProvider.available(AuthenticationProvider.account_types[:provider]).each do |authentication_provider_class|
        kind_name = authentication_provider_class.to_s.demodulize
        authentication_provider = @account.self_authentication_providers.build_kind(kind: kind_name, client_id: 'id', client_secret: 'secret', site: 'http://example.com')
        assert_equal authentication_provider_class, authentication_provider.class
        assert_equal kind_name.downcase, authentication_provider.kind
        assert_equal @account, authentication_provider.account
        authentication_provider.valid? && puts(authentication_provider.errors.full_messages)
        assert authentication_provider.valid?
      end
    end

    should 'self_authentication_providers build_kind invalid kinds' do
      available_only_for_developers = (AuthenticationProvider.available(AuthenticationProvider.account_types[:developer]) - AuthenticationProvider.available(AuthenticationProvider.account_types[:provider])).map { |ap_class| ap_class.to_s.demodulize }
      available_only_for_developers += ['CustomKind-123456']
      available_only_for_developers.each do |authentication_provider_class|
        authentication_provider = @account.self_authentication_providers.build_kind(kind: authentication_provider_class, client_id: 'id', client_secret: 'secret', site: 'http://example.com')
        assert_equal @account, authentication_provider.account
        refute authentication_provider.valid?
      end
    end
  end

  test 'provider?'do
    account = Account.new
    refute account.partner?
    account.expects(:partner_id).returns(42)
    assert account.partner?
  end

  test 'viral footer should not be applied on plan upgrade' do
    provider = FactoryBot.create :provider_account
    assert provider.should_apply_email_engagement_footer?, 'Expected to have a viral footer'

    plan = FactoryBot.create :published_plan, :system_name => 'enterprise', :issuer => master_account.services.first

    provider.force_upgrade_to_provider_plan! plan
    refute provider.should_apply_email_engagement_footer?, 'Expected to skip the viral footer'
  end

  test '#require_billing_information! and #require_billing_information? and validations' do
    account = Account.new
    refute account.require_billing_information?
    account.require_billing_information!
    assert account.require_billing_information?

    refute account.valid?

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

  should '#show_xss_protection_options?' do
    account = FactoryBot.build_stubbed(:provider_account)
    settings = account.settings

    settings.cms_escape_published_html = true
    settings.cms_escape_draft_html =  true
    refute account.show_xss_protection_options?

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

  context 'after created' do

    subject { Account.new :org_name => "prov", :provider_account => master_account, :subdomain => 'prov', :self_subdomain => 'prov-admin' }

    should 'have an sso_key' do
      subject.provider= true
      subject.save!
      assert_not_nil subject.settings.sso_key
    end

    should 'not have a default service anymore' do
      prov = subject
      prov.provider = true
      prov.save!

      assert prov.provider?
      assert prov.default_service_id.blank?
    end

    should 'have a s3_prefix' do
      prov = subject
      prov.provider = true
      prov.save!

      assert prov.provider?
      assert_equal 'prov', prov.s3_prefix
    end

    should 'have a go_live_state' do
      prov = subject
      prov.provider = true
      prov.save
      assert prov.go_live_state.present?
    end
  end

  context "for the provider" do

    setup do
      @provider =  FactoryBot.create(:provider_account)
      @acc_plan = FactoryBot.create(:account_plan, :issuer => @provider)
      @buyers = []
      @buyers << FactoryBot.create(:simple_buyer, :provider_account => @provider)
      @buyers << FactoryBot.create(:simple_buyer, :provider_account => @provider)
    end

    context 'Account#from_email' do
      should 'have default' do
        assert_equal Rails.configuration.three_scale.noreply_email, @provider.from_email
      end

      should 'return correct if customized' do
        mail = 'foo@example.net'
        @provider.from_email = mail
        assert_equal mail, @provider.from_email
      end
    end

    context 'with provided plans' do
      setup do

        @service_one = FactoryBot.create(:simple_service, :account => @provider)
        @service_two = FactoryBot.create(:simple_service, :account => @provider)
        @service_three = FactoryBot.create(:simple_service, :account => @provider)

        @plans = {
            :service => [
              FactoryBot.create(:service_plan, :issuer => @service_one),
              FactoryBot.create(:service_plan, :issuer => @service_two)
            ],
            :application => [
              FactoryBot.create(:simple_application_plan, :issuer => @service_one),
              FactoryBot.create(:simple_application_plan, :issuer => @service_one),

              FactoryBot.create(:simple_application_plan, :issuer => @service_two),
              FactoryBot.create(:simple_application_plan, :issuer => @service_two)
            ]
        }

        assert_equal 2, ApplicationPlan.issued_by(@service_one).count

        @contracts = {:service => [], :cinstance => []}

        @contracts[:service] << @buyers.first.buy!(@plans[:service].first)
        @contracts[:cinstance] << @buyers.first.buy!(@plans[:application].first)
        @contracts[:cinstance] << @buyers.first.buy!(@plans[:application].second)


        @contracts[:service] << @buyers.last.buy!(@plans[:service].last)
        @contracts[:cinstance] << @buyers.last.buy!(@plans[:application].third)
        @contracts[:cinstance] << @buyers.last.buy!(@plans[:application].last)

        @provider.reload

        @plans[:account] = @acc_plan
      end


      context 'Account#account_plans' do
        should 'have  #default' do
          assert_not_nil @provider.account_plans.default
        end
      end

      context 'Account#application_plans' do
        should 'return all application plans provided by one of the service of the account' do
          assert_same_elements ApplicationPlan.provided_by(@provider), @provider.application_plans
        end

        should 'return only issued by issuer if called with issued_by scope' do
          assert_same_elements @plans[:application][2..3], @provider.application_plans.issued_by(@service_two)
        end
      end

      context 'Account#provided_cinstances' do
        should 'return all provided cinstances' do
          assert_same_elements Cinstance.provided_by(@provider), @provider.provided_cinstances
        end

        should 'return only cinstances for issuer if called with issued_by scope' do
          assert_same_elements @contracts[:cinstance][0..1], @provider.provided_cinstances.by_service(@service_one)
        end
      end

    end

  end
end

# frozen_string_literal: true

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  fixtures :countries

  def setup
    @account = FactoryBot.build(:simple_account, org_name: 'Panda Research Base')
  end

  subject { @account || Account.new }

  should have_one(:profile).dependent(:delete)
  should belong_to :country

  should have_many :invitations
  should have_many :users
  should belong_to :partner
  should have_many :buyer_accounts
  should have_many(:buyer_users).through(:buyer_accounts)
  should belong_to :provider_account
  should have_many :builtin_legal_terms

  # Billing
  should have_one :billing_strategy
  should have_many :invoices
  should have_many :payment_transactions

  test 'removed columns' do
    %w[payment_gateway_type payment_gateway_options deleted_at].each do |column|
      assert_not_includes Account.column_names, column
    end
  end

  test 'class method free' do
    recent_date = 4.days.ago
    old_date = 6.days.ago

    paid_tenant = FactoryBot.create(:simple_provider)
    FactoryBot.create(:application, user_account: paid_tenant, paid_until: recent_date)

    paid_tenant = FactoryBot.create(:simple_provider)
    FactoryBot.create(:application, user_account: paid_tenant, variable_cost_paid_until: recent_date)

    free_tenant = FactoryBot.create(:simple_provider)
    FactoryBot.create(:application, user_account: free_tenant, paid_until: old_date, variable_cost_paid_until: old_date)

    another_free_tenant = FactoryBot.create(:simple_provider)

    free_tenant_ids = Account.free(5.days.ago).pluck(:id)
    assert_includes free_tenant_ids, free_tenant.id
    assert_includes free_tenant_ids, another_free_tenant.id
    assert_not_includes free_tenant_ids, paid_tenant.id
  end

  test 'class method lacks cinstance with plan system_name' do
    enterprise_tenant = FactoryBot.create(:simple_provider)
    FactoryBot.create(:cinstance, user_account: enterprise_tenant, plan: FactoryBot.create(:application_plan, system_name: '2014_enterprise_3M', issuer: master_account.default_service))

    non_enterprise_tenant = FactoryBot.create(:simple_provider)
    FactoryBot.create(:cinstance, user_account: non_enterprise_tenant, plan: FactoryBot.create(:application_plan, system_name: '2017-pro-500k', issuer: master_account.default_service))

    another_non_enterprise_tenant = FactoryBot.create(:simple_provider)

    assert_includes Account.lacks_cinstance_with_plan_system_name(['2014_enterprise_3M']).pluck(:id), non_enterprise_tenant.id
    assert_includes Account.lacks_cinstance_with_plan_system_name('2014_enterprise_3M').pluck(:id), another_non_enterprise_tenant.id
    assert_not_includes Account.lacks_cinstance_with_plan_system_name(['2014_enterprise_3M']).pluck(:id), enterprise_tenant.id
  end

  test 'not master' do
    master = master_account
    buyer = FactoryBot.create(:simple_buyer, provider_account: master)

    assert_includes master.buyer_account_ids, buyer.id
    assert_includes master.buyer_account_ids, master.id

    assert_includes master.buyer_accounts.not_master.ids, buyer.id
    assert_not_includes master.buyer_accounts.not_master.ids, master.id
  end

  test 'provider but not master' do
    account = FactoryBot.build_stubbed(:simple_account, provider: false, master: false)
    assert_not account.tenant?

    account.provider = true
    assert account.tenant?

    account.master = true
    assert_not account.tenant?
  end

  test 'destroy association' do
    account = FactoryBot.create(:simple_account)
    service = FactoryBot.create(:simple_service, account: account)
    account.update_column(:default_service_id, service.id) # rubocop:disable Rails/SkipsModelValidations
    metric  = service.metrics.hits

    assert service.default?
    assert metric

    account.destroy

    assert_raise(ActiveRecord::RecordNotFound) { service.reload }
    assert_raise(ActiveRecord::RecordNotFound) { metric.reload }
  end

  test '#trashed_messages' do
    account = FactoryBot.build_stubbed(:simple_account)
    other = FactoryBot.build_stubbed(:simple_account)
    message1 = FactoryBot.create(:message, sender: account, to: other, state: 'sent')
    message2 = FactoryBot.create(:message, sender: other, to: account, state: 'sent')

    assert_equal 0, account.trashed_messages.count

    message1.hide!
    assert_equal 1, account.trashed_messages.count

    message2.recipients[0].hide!
    assert_equal 2, account.trashed_messages.count
  end

  test 'avoid deletion of master account' do
    assert_not master_account.destroy, "Should not destroy master account"

    provider = FactoryBot.create(:simple_provider)
    buyer = FactoryBot.create(:simple_buyer)

    assert provider.destroy, "Should destroy provider account"
    assert buyer.destroy, "Should destroy buyer account"
  end

  # regression test: https://github.com/3scale/system/pull/3406
  test 'update_attributes with nil as param should not raise error' do
    buyer = FactoryBot.create(:simple_buyer)
    buyer.update(nil)
  end

  test 'should validate self_domain uniqueness' do
    account = FactoryBot.build_stubbed(:simple_provider)
    other = FactoryBot.build_stubbed(:simple_provider)

    assert account.valid?
    assert other.valid?

    other.self_domain = account.self_domain.upcase

    assert_not other.valid?
    assert other.errors[:self_domain]
  end

  test 'should respond to current and tax_rate' do
    account = Account.new

    assert account.respond_to? :currency
    assert account.respond_to? :tax_rate
  end

  test 'account has friendly human attribute names' do
    assert_equal 'Organization/Group Name', Account.human_attribute_name('org_name')
    assert_equal 'Country of Residence', Account.human_attribute_name('country_id')
  end

  test 'emails should not contain nils' do
    account = FactoryBot.build_stubbed(:simple_provider)
    # Users should always have an email, but old/test ones might not
    # Return a properly empty list instead of a "list with nils"
    FactoryBot.build(:admin, email: nil, account_id: account.id).save(validate: false)

    assert_equal([], account.emails)
  end

  test 'has messages' do
    account = FactoryBot.build_stubbed(:simple_provider)

    assert_equal [], account.hidden_messages
    assert_equal [], account.received_messages
  end

  test 'providers named_scope return non-readonly objects' do
    provider = FactoryBot.create(:simple_provider)
    @named_scoped_provider = provider

    @named_scoped_provider.update(org_name: 'account is not readonly')
  end

  test 'deleted buyer account have working #to_xml' do
    buyer = FactoryBot.create(:simple_buyer)

    buyer.destroy

    assert buyer.to_xml
  end

  test 'Account#admins returns users with admin role' do
    account = FactoryBot.create(:account_without_users)
    FactoryBot.create(:simple_user, account: account)
    admin = FactoryBot.create(:admin, account: account)

    assert_equal [admin], account.admins
  end

  test 'have nil VAT rate' do
    assert_nil @account.vat_rate

    @account.update_attribute(:vat_rate, 0) # rubocop:disable Rails/SkipsModelValidations
    assert_equal 0.0, @account.reload.vat_rate

    @account.update_attribute(:vat_rate, 2.34) # rubocop:disable Rails/SkipsModelValidations
    assert_equal 2.34, @account.reload.vat_rate
  end

  test 'without :timezone set return UTC as default :timezone' do
    assert_equal 'UTC', @account.timezone
  end

  ['Chennai', 'Kolkata', 'Mumbai', 'New Delhi', 'Sri Jayawardenepura',
   'Adelaide', 'Darwin', 'Rangoon', 'Kathmandu','Kabul', 'Tehran'].each do |shift|
    should_not allow_value(shift).for(:timezone)
  end
  should_not allow_value("XXX").for(:timezone)
  should_not allow_value("").for(:timezone)
  should allow_value("Prague").for(:timezone)
  should allow_value("Jerusalem").for(:timezone)
  should allow_value("Madrid").for(:timezone)

  test 'without country return EUR on :currency' do
    @account.country = nil
    assert_equal 'EUR', @account.currency
  end

  test 'without country return zero on :tax_tate' do
    @account.country = nil
    assert_equal 0.0, @account.tax_rate
  end

  test 'with country that has no currency return EUR on :currency' do
    @account.country = FactoryBot.create(:country, currency: nil)
    assert_equal 'EUR', @account.currency
  end

  test 'with country return currency of country on :currency' do
    @account.country = countries(:es)
    assert_equal 'EUR', @account.currency
  end

  test 'with country return tax_rate of country on :tax_rate' do
    @account.country = countries(:es)
    assert_equal 16, @account.tax_rate
  end

  test 'Account.buyer_users returns all users of all buyer accounts' do
    provider_account  = FactoryBot.build_stubbed(:simple_provider)
    buyer_account_one = FactoryBot.build(:simple_buyer, provider_account: provider_account)

    buyer_account_one.users << FactoryBot.build(:simple_user)
    buyer_account_one.users << FactoryBot.build(:simple_user)
    buyer_account_one.save!

    buyer_account_two = FactoryBot.build(:simple_buyer, provider_account: provider_account)
    buyer_account_two.users << FactoryBot.build(:simple_user)
    buyer_account_two.save!

    assert_same_elements buyer_account_one.users + buyer_account_two.users,
                         provider_account.buyer_users
  end

  test "Account.managed_users returns users of the account and users of it's buyer accounts" do
    provider_account = FactoryBot.create(:simple_provider)
    provider_user = FactoryBot.create(:simple_user, account: provider_account)

    buyer_account = FactoryBot.create(:simple_buyer, provider_account: provider_account)
    buyer_user = FactoryBot.create(:simple_user, account: buyer_account)

    other_provider_account = FactoryBot.create(:simple_provider)
    other_provider_user = FactoryBot.create(:simple_user, account: other_provider_account)

    other_buyer_account = FactoryBot.create(:simple_buyer, provider_account: other_provider_account)
    other_buyer_user = FactoryBot.create(:simple_user, account: other_buyer_account)

    assert_contains provider_account.managed_users, provider_user
    assert_contains provider_account.managed_users, buyer_user

    assert_does_not_contain provider_account.managed_users, other_provider_user
    assert_does_not_contain provider_account.managed_users, other_buyer_user
  end

  test 'Account.managed_users returns read-write records' do
    provider_account = FactoryBot.create(:simple_provider)

    FactoryBot.create(:simple_user, account: provider_account)

    assert_not provider_account.managed_users.first.readonly?
  end

  test 'settings be created lazily for existing account' do
    assert_no_difference 'Settings.count' do
      @account = Account.create!(org_name: 'Organization')
    end

    assert_difference 'Settings.count', 1 do
      @account.settings
    end
  end

  test 'settings be build lazily for new account' do
    account = Account.new

    assert_not_nil account.settings
    assert account.settings.new_record?
  end

  test 'profile is lazily created' do
    account = Account.new
    assert_not_nil account.profile
  end

  test 'forum is lazily created for providers' do
    account = nil

    assert_no_change :of => -> { Forum.count } do
      account = FactoryBot.create(:simple_provider)
    end

    assert_not_nil account.forum
  end

  test 'forum is created with default name' do
    account = FactoryBot.build_stubbed(:simple_provider)

    assert_equal 'Forum', account.forum.name
  end

  test '#forum! returns the forum when called on a provider account' do
    account = FactoryBot.build_stubbed(:simple_provider)

    assert_instance_of Forum, account.forum!
  end

  test '#forum! raises an exception when called on a buyer account' do
    account = FactoryBot.build_stubbed(:simple_buyer)

    assert_raise ActiveRecord::RecordNotFound do
      account.forum!
    end
  end

  test 'generates site_access_code if the account is a provider' do
    account = Account.new(org_name: 'Foo', subdomain: 'foo', self_subdomain: 'foo-admin')
    account.provider = true
    account.provider_account = master_account
    account.save!
    assert_not_nil account.site_access_code
  end

  test 'generate domains for provider' do
    account = Account.new(org_name: 'AmAzinG   name 123')
    account.provider = true
    account.provider_account = master_account
    account.save!

    assert_equal "amazing-name-123.#{ThreeScale.config.superdomain}", account.domain
    assert_equal "amazing-name-123-admin.#{ThreeScale.config.superdomain}", account.self_domain

    account = Account.new(org_name: '')
    account.save
    assert_equal false, account.valid?
    assert_nil account.domain
  end

  test 'does not generate site_access_code if the account is not a provider' do
    account = Account.create!(org_name: 'Bar')
    assert_nil account.site_access_code
  end

  test 'Account.first_by_provider_key! raises an exception if the key is invalid' do
    assert_raise Backend::ProviderKeyInvalid do
      Account.first_by_provider_key!('boo')
    end
  end

  test "Account.first_by_provider_key! finds account by bought cinstance's user_key" do
    account = FactoryBot.create(:simple_account, provider_account: master_account)
    cinstance = account.buy!(master_account.default_service.published_plans.first)

    assert_equal account, Account.first_by_provider_key!(cinstance.user_key)
  end

  test 'Account.master raises and exception if there is no master account' do
    Account.delete_all

    assert_raise ActiveRecord::RecordNotFound do
      Account.master
    end
  end

  test 'Account.master returns master account' do
    Account.delete_all
    FactoryBot.build_stubbed(:simple_account) # create one normal account, so I don't get false positives

    master_account = Account.new(org_name: 'master')
    master_account.master = true
    master_account.save!

    assert_equal master_account, Account.master
  end

  test 'only one master account can be created' do
    Account.delete_all

    account = Account.new(org_name: 'master')
    account.master = true
    account.save!

    account = Account.new(org_name: 'more master, yeah!')
    account.master = true

    assert_not account.valid?, 'other master should be invalid'
    assert_not_nil account.errors[:master]
  end

  test 'Account.master_id reads data from cache on cache hit' do
    Rails.cache.stubs(:fetch).with("master_account_id", any_parameters).returns(42)
    Account.expects(:find).never
    Account.expects(:find_by_sql).never

    assert_equal 42, Account.master_id
  end

  test 'Account.master_id loads data from database and writes to cache on cache miss' do
    master_id = master_account.id
    Rails.cache.stubs(:read).with('master_account_id', any_parameters).returns(nil)
    Rails.cache.expects(:write).with('master_account_id', master_id, any_parameters)

    assert_equal master_id, Account.master_id
  end

  test 'Account#master_on_premises?' do
    account = Account.new
    account.master = true

    # account is master but it's not onprem
    ThreeScale.config.stubs(onpremises: false)
    assert_not account.master_on_premises?

    # account is master and it's onprem
    ThreeScale.config.stubs(onpremises: true)
    assert account.master_on_premises?

    # it's onpprem but account is not master
    account.master = false
    ThreeScale.config.stubs(onpremises: true)
    assert_not account.master_on_premises?
  end

  test "Account#feature_allowed? returns true only if it's plan includes that feature" do
    feature_one = master_account.default_service.features.create!(name: 'free t-shirt')

    plan = master_account.default_service.plans.published.first
    plan.enable_feature!(feature_one.system_name)

    account = FactoryBot.create(:provider_account, provider_account: master_account)

    assert account.feature_allowed?(:free_t_shirt)  # works with symbols
    assert account.feature_allowed?('free_t_shirt') # and strings

    assert_not account.feature_allowed?(:free_pizza)
    assert_not account.feature_allowed?(:instant_success)
  end

  test "Account#feature_allowed? returns true by default for master account" do
    assert master_account.feature_allowed?(:prepaid_billing)
    assert master_account.feature_allowed?(:postpaid_billing)
    assert master_account.feature_allowed?(:domination_over_universe)

    # returns false for some features for master account
    assert_not master_account.feature_allowed?(:anonymous_clients)
  end

  test "deleted billing strategy on destroy" do
    provider = FactoryBot.create(:simple_provider)
    id = provider.create_billing_strategy.id
    provider.destroy
    assert_nil Finance::BillingStrategy.find_by(id: id), 'BillingStrategy not deleted'
  end

  test 'Account.id_from_api_key reads data from cache on cache hit' do
    Rails.cache.expects(:fetch).with("account_ids/foobar", any_parameters).returns(42)
    Account.expects(:find).never
    Account.expects(:find_by_sql).never

    assert_equal 42, Account.id_from_api_key('foobar')
  end

  test 'Account.id_from_api_key loads data from database and writes to cache on cache miss' do
    account = FactoryBot.create(:provider_account)

    Rails.cache.stubs(:read).with("account_ids/#{account.api_key}", any_parameters).returns(nil)
    Rails.cache.expects(:write).with("account_ids/#{account.api_key}", account.id, any_parameters)

    assert_equal account.id, Account.id_from_api_key(account.api_key)
  end

  test 'Account#provider? returns true also for master account' do
    assert master_account.provider?
  end

  test "destroying account destroys it's services" do
    account = FactoryBot.create(:provider_account)
    service = FactoryBot.create(:simple_service, account: account)

    account.destroy

    assert_nil Service.find_by(id: service.id)
  end

  test "destroying account destroys the default service firing services destroy callbacks" do
    account = FactoryBot.create(:provider_account)
    service = account.default_service
    metric = FactoryBot.create(:metric, service: service)
    feature = FactoryBot.create(:feature, featurable: service)

    account.destroy

    assert_nil Service.find_by(id: service.id)
    assert_nil Metric.find_by(id: metric.id)
    assert_nil Feature.find_by(id: feature.id)
  end

  test "destroying account will stop if features deletion fails" do
    Feature.any_instance.stubs(:destroy).returns(false)

    account = FactoryBot.create(:provider_account)
    service = account.default_service
    metric = FactoryBot.create(:metric, service: service)
    feature = FactoryBot.create(:feature, featurable: service)

    assert_not account.destroy

    assert_not_nil Service.find_by(id: service.id)
    assert_not_nil Metric.find_by(id: metric.id)
    assert_not_nil Feature.find_by(id: feature.id)
  end

  test 'destroying provider account with buyer accounts' do
    provider_account = FactoryBot.create(:provider_account)
    plan = FactoryBot.create(:simple_application_plan, service: provider_account.default_service)

    buyer_account = FactoryBot.create(:simple_buyer, provider_account: provider_account)
    buyer_account.buy!(plan)

    assert_change :of => -> { Account.providers.count }, :by => -1 do
      provider_account.destroy
    end
  end

  test '.model_name.human is account' do
    assert Account.model_name.human == "Account"
  end

  test "support email should have a valid email format for providers" do
    provider = FactoryBot.build(:simple_provider, support_email: "support-email-acc.example.net",
                                                  finance_support_email: "finance-support-acc.example.net")
    provider.valid?

    assert provider.errors[:support_email].present?
    assert provider.errors[:finance_support_email].present?
  end

  # regression test
  test "support email should not be validated for buyers" do
    buyer = FactoryBot.build(:simple_buyer, support_email: "support-email-acc.example.net",
                                            finance_support_email: "finance-support-acc.example.net")

    assert buyer.valid?
    assert buyer.errors[:support_email].empty?
    assert buyer.errors[:finance_support_email].empty?
  end

  test "support_email should fall back to first admin email" do
    provider = FactoryBot.build_stubbed(:provider_account)
    assert_equal provider.support_email, provider.admins.first.email
  end

  test "finance_support_email should fall back to support_email" do
    provider = FactoryBot.build(:simple_provider, support_email: "support-email@acc.example.net")
    assert_equal provider.finance_support_email, provider.support_email

    provider.update(finance_support_email: "finance-support@acc.example.net")
    assert_equal provider.finance_support_email, "finance-support@acc.example.net"
  end

  # regression test for https://github.com/3scale/system/issues/2767
  test 'destroy should destroy all cinstances and application_plans' do
    master_plan = master_account.default_application_plans.first!

    provider = FactoryBot.create(:simple_provider, provider_account: master_account)
    FactoryBot.create(:cinstance, plan: master_plan, user_account: provider)

    service = FactoryBot.create(:simple_service, account: provider)
    buyer = FactoryBot.create(:simple_buyer, provider_account: provider)
    tenant_plan = FactoryBot.create(:application_plan, issuer: service)
    FactoryBot.create(:cinstance, plan: tenant_plan, user_account: buyer)

    assert_not_equal 0, provider.provided_cinstances.reload.count
    assert_not_equal 0, provider.provided_plans.reload.count
    assert_not_equal 0, provider.bought_plans.reload.count

    provider.destroy!

    assert_equal 0, provider.provided_cinstances.reload.count
    assert_equal 0, provider.provided_plans.reload.count
    assert_equal 0, provider.bought_plans.reload.count
  end

  test 'onboarding builds object if not already created' do
    account = FactoryBot.build(:account)

    assert_not_nil account.onboarding
  end

  test 'to_xml' do
    account = Account.new

    # just to make the serialization work
    def account.fields_definitions_source_root!
      self
    end

    domain = 'some.example.com'
    admin_domain = "admin.#{ThreeScale.config.superdomain}"

    account.domain = domain
    account.self_domain = admin_domain

    domain_xml = "<domain>#{domain}</domain>"
    admin_domain_xml = "<admin_domain>#{admin_domain}</admin_domain>"
    base_url_xml = "<base_url>http://#{domain}</base_url>"
    admin_base_url_xml = "<admin_base_url>http://#{admin_domain}</admin_base_url>"

    xml = account.to_xml

    assert_no_match domain_xml, xml
    assert_no_match admin_domain_xml, xml
    assert_no_match base_url_xml, xml
    assert_no_match admin_base_url_xml, xml

    account.provider = true

    xml = account.to_xml

    assert_match domain_xml, xml
    assert_match admin_domain_xml, xml
    assert_match base_url_xml, xml
    assert_match admin_base_url_xml, xml
  end

  test 'settings' do
    account = Account.new
    settings = account.settings

    assert_equal account, settings.account
    # they are actually the same object
    assert_equal account.object_id, settings.account.object_id
  end

  test 'multiple_applications_allowed? does not crash when the account does not have settings (already deleted)' do
    assert_not Account.new.multiple_applications_allowed?
  end

  test 'fetch_dispatch_rule' do
    account = FactoryBot.create(:simple_account)

    user_signup = SystemOperation.for(:user_signup)
    daily_reports = SystemOperation.for(:daily_reports)

    assert account.fetch_dispatch_rule(user_signup).dispatch
    assert_not account.fetch_dispatch_rule(daily_reports).dispatch
  end

  test 'dispatch_rule_for' do
    account = FactoryBot.build_stubbed(:simple_provider)
    user_signup = SystemOperation.for(:user_signup)
    daily_reports = SystemOperation.for(:daily_reports)

    FactoryBot.create(:mail_dispatch_rule, system_operation: daily_reports, account: account)

    # When the migration is enabled, we disable the dispatch rules
    # because notifications are delivered and we don't want to deliver the info twice.
    account.expects(:provider_can_use?).with(:new_notification_system).returns(true).twice
    assert_not account.dispatch_rule_for(user_signup).dispatch
    assert_not account.dispatch_rule_for(daily_reports).dispatch

    account.expects(:provider_can_use?).with(:new_notification_system).returns(false).twice
    assert account.dispatch_rule_for(user_signup).dispatch
    assert account.dispatch_rule_for(daily_reports).dispatch
  end

  def test_accessible_services
    service = FactoryBot.create(:simple_service)
    account = FactoryBot.create(:simple_account, services: [service], default_service_id: service.id)

    assert_equal [service], account.accessible_services

    service.update(state: 'deleted')
    assert_not account.accessible_services.exists?
  end

  def test_smart_destroy_buyer
    buyer = FactoryBot.create(:buyer_account)

    buyer.smart_destroy
    assert_raise(ActiveRecord::RecordNotFound) { buyer.reload }
  end

  def test_smart_destroy_provider
    provider = FactoryBot.create(:simple_provider)

    provider.smart_destroy
    assert provider.reload.scheduled_for_deletion?
  end

  def test_smart_destroy_master
    master_account.smart_destroy
    assert master_account.reload
    assert_not master_account.reload.scheduled_for_deletion?
  end
end

#TODO: test scopes chained, and with nil params
class SearchingBetweenDatesTest < ActiveSupport::TestCase
  def setup
    @january = Date.parse '1 - Jan - 2010'
    @april = Date.parse '1 - Apr - 2010'

    @created_in_january = FactoryBot.create(:simple_provider, created_at: @january + 1)
    @created_in_april = FactoryBot.create(:simple_provider, created_at: @april + 1)
  end

  test '.created_after named_scope return accounts created after passed date' do
    assert_includes Account.created_after(@april), @created_in_april
  end

  test '.created_after named_scope not return accounts created before passed date' do
    assert_not_includes Account.created_after(@april), @created_in_january
  end

  test '.created_before named_scope return accounts created before passed date' do
    assert_includes Account.created_before(@april), @created_in_january
  end

  test '.created_before named_scope not return accounts created before passed date' do
    assert_not_includes Account.created_before(@april), @created_in_april
  end
end

class CanCreateApplicationTest < ActiveSupport::TestCase
  def setup
    provider = FactoryBot.create(:provider_account)
    @buyer = FactoryBot.create(:simple_buyer, provider_account: provider)

    @service = @buyer.provider_account.default_service
    #making the service subscribeable
    @service.publish!
    @plan = FactoryBot.create(:simple_application_plan, service: @service)
    @plan.publish!

    #another subscribeable service
    @service_denied = FactoryBot.create(:service, account: @buyer.provider_account)
    @service_denied.publish!
    @plan2 = FactoryBot.create(:simple_application_plan, service: @service_denied)
    @plan2.publish!

    #subscribing to services
    @buyer.buy! @service.service_plans.first
    @buyer.buy! @service_denied.service_plans.first

    @service.update(buyers_manage_apps: true)
    @service_denied.update(buyers_manage_apps: false)
  end

  test 'deny or allow depending of the service' do
    assert @buyer.can_create_application?(@service)
    assert_not @buyer.can_create_application?(@service_denied)
  end

  test 'any service allows buyers_manage_apps return true when no service passed' do
    assert @buyer.can_create_application?
  end

  test 'all services deny buyers_manage_apps return false' do
    @service.update(buyers_manage_apps: false)
    assert_not @buyer.can_create_application?
  end
end

class PaidTest < ActiveSupport::TestCase
  def setup
    @buyer = FactoryBot.create(:buyer_account)

    @service = @buyer.provider_account.default_service
    #making the service subscribeable
    @service.publish!

    @paid_plan = FactoryBot.create(:simple_application_plan, service: @service, cost_per_month: 10.0)
    @paid_plan.publish!

    @free_plan = FactoryBot.create(:simple_application_plan, service: @service)
    @free_plan.publish!

    #subscribing to services
    @buyer.buy! @service.service_plans.first
    @buyer.buy! @free_plan
  end

  test 'be false when account has no paid contract' do
    assert_not @buyer.paid?
  end

  test 'be true when account has at least one paid contract' do
    @buyer.buy! @paid_plan
    assert @buyer.paid?
  end
end

class OnTrialTest < ActiveSupport::TestCase
  def setup
    @buyer = FactoryBot.create(:buyer_account)
    @service = @buyer.provider_account.default_service
    #making the service subscribeable
    @service.publish!

    @paid_15days = @service.service_plans.first
    @paid_15days.update(cost_per_month: 10.0, trial_period_days: 15, state: 'published')

    @paid_notrial = FactoryBot.create(:simple_application_plan, service: @service, cost_per_month: 10.0, state: 'published')

    @buyer.buy! @paid_15days
  end

  test 'be true when account has all contracts on trial' do
    @buyer.reload
    assert @buyer.on_trial?
  end

  test 'be false when account has at least a contract is not on trial' do
    @buyer.buy! @paid_notrial
    assert_not @buyer.on_trial?
  end
end

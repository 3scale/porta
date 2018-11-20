require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  fixtures :countries

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

  def test_not_master
    master = master_account
    buyer = FactoryGirl.create(:simple_buyer, provider_account: master)

    assert master.buyer_account_ids.include?(buyer.id)
    assert master.buyer_account_ids.include?(master.id)

    assert master.buyer_accounts.not_master.ids.include?(buyer.id)
    refute master.buyer_accounts.not_master.ids.include?(master.id)
  end

  def test_provider_but_not_master
    account = FactoryGirl.build_stubbed(:simple_account, provider: false, master: false)
    refute account.tenant?
    
    account.provider = true
    assert account.tenant?
    
    account.master = true
    refute account.tenant?
  end

  def test_destroy_association
    account = FactoryGirl.create(:simple_account)
    service = FactoryGirl.create(:simple_service, account: account)
    account.update_column(:default_service_id, service.id)
    metric  = service.metrics.hits

    assert service.default?
    assert metric

    account.destroy

    assert_raise(ActiveRecord::RecordNotFound) { service.reload }
    assert_raise(ActiveRecord::RecordNotFound) { metric.reload }
  end

  def test_default_service_id
    service = FactoryGirl.create(:simple_service)
    account = FactoryGirl.create(:simple_account, services: [service], default_service_id: service.id)

    assert service.default?
    assert_equal service.id, account.default_service_id

    service.destroy_default

    account.reload

    assert_raises(ActiveRecord::RecordNotFound) { service.reload }
    assert_nil account.default_service_id
  end

  test '#trashed_messages' do
    account  = FactoryGirl.build_stubbed(:simple_account)
    other    = FactoryGirl.build_stubbed(:simple_account)
    message1 = FactoryGirl.create(:message, sender: account, to: other, state: 'sent')
    message2 = FactoryGirl.create(:message, sender: other, to: account, state: 'sent')

    assert_equal 0, account.trashed_messages.count

    message1.hide!
    assert_equal 1, account.trashed_messages.count

    message2.recipients[0].hide!
    assert_equal 2, account.trashed_messages.count
  end

  test 'avoid deletion of master account' do
    refute master_account.destroy, "Should not destroy master account"

    provider = FactoryGirl.create(:simple_provider)
    buyer    = FactoryGirl.create(:simple_buyer)

    assert provider.destroy, "Should destroy provider account"
    assert buyer.destroy, "Should destroy buyer account"
  end

  # regression test: https://github.com/3scale/system/pull/3406
  test 'update_attributes with nil as param should not raise error' do
    buyer = FactoryGirl.create(:simple_buyer)
    buyer.update_attributes(nil)
  end

  test 'should validate self_domain uniqueness' do
    account = FactoryGirl.build_stubbed(:simple_provider)
    other   = FactoryGirl.build_stubbed(:simple_provider)

    assert account.valid?
    assert other.valid?

    other.self_domain = account.self_domain.upcase

    refute other.valid?
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
    account = FactoryGirl.build_stubbed(:simple_provider)
    # Users should always have an email, but old/test ones might not
    # Return a properly empty list instead of a "list with nils"
    Factory.build(:admin, email: nil, account_id: account.id).save(validate: false)

    assert_equal([], account.emails)
  end

  test 'has messages' do
    account = FactoryGirl.build_stubbed(:simple_provider)

    assert_equal [], account.hidden_messages
    assert_equal [], account.received_messages
  end

  context 'providers named_scope' do
    setup do
      provider = FactoryGirl.create(:simple_provider)

      @named_scoped_provider = provider
    end

    should 'return non-readonly objects' do
      @named_scoped_provider.update_attribute :org_name, 'account is not readonly'
    end
  end

  context 'deleted buyer account' do
    should 'have working #to_xml' do
      buyer = FactoryGirl.create(:simple_buyer)

      buyer.destroy

      assert buyer.to_xml
    end
  end

  #TODO: test scopes chained, and with nil params
  context 'searching between dates' do
    setup do
      @january = Date.parse '1 - Jan - 2010'
      @april   = Date.parse '1 - Apr - 2010'

      @created_in_january = FactoryGirl.create(:simple_provider, created_at: @january + 1)
      @created_in_april   = FactoryGirl.create(:simple_provider, created_at: @april + 1)
    end

    context '.created_after named_scope' do
      should 'return accounts created after passed date' do
        assert Account.created_after(@april).include?(@created_in_april)
      end

      should 'not return accounts created before passed date' do
        assert_equal false, Account.created_after(@april).include?(@created_in_january)
      end
    end

    context '.created_before named_scope' do
      should 'return accounts created before passed date' do
        assert Account.created_before(@april).include?(@created_in_january)
      end

      should 'not return accounts created before passed date' do
        assert_equal false, Account.created_before(@april).include?(@created_in_april)
      end
    end
  end

  test 'Account#admins returns users with admin role' do
    account = FactoryGirl.build_stubbed(:account_without_users)
    FactoryGirl.create(:simple_user, account: account)
    admin = FactoryGirl.create(:admin, account: account)

    assert_equal [admin], account.admins
  end

  context 'An Account' do
    setup do
      @account = FactoryGirl.build(:simple_account, org_name: 'Panda Research Base')
    end

    should 'have nil VAT rate' do
      assert_nil @account.vat_rate

      @account.update_attribute(:vat_rate, 0)
      assert_equal 0.0, @account.reload.vat_rate

      @account.update_attribute(:vat_rate, 2.34)
      assert_equal 2.34, @account.reload.vat_rate
    end

    context "without :timezone set" do
      should 'return UTC as default :timezone' do
        assert_equal 'UTC', @account.timezone
      end

      ['Chennai', 'Kolkata', 'Mumbai', 'New Delhi', 'Sri Jayawardenepura',
       'Adelaide', 'Darwin', 'Rangoon', 'Kathmandu','Kabul', 'Tehran' ].each do |shift|
        should_not allow_value(shift).for(:timezone)
      end
      should_not allow_value("XXX").for(:timezone)
      should_not allow_value("").for(:timezone)
      should allow_value("Prague").for(:timezone)
      should allow_value("Jerusalem").for(:timezone)
      should allow_value("Madrid").for(:timezone)
    end

    context 'without country' do
      setup do
        @account.country = nil
      end

      should 'return EUR on :currency' do
        assert_equal 'EUR', @account.currency
      end

      should 'return zero on :tax_tate' do
        assert_equal 0.0, @account.tax_rate
      end
    end

    context 'with country that has no currency' do
      setup do
        @account.country = Factory(:country, :currency => nil)
      end

      should 'return EUR on :currency' do
        assert_equal 'EUR', @account.currency
      end
    end

    context 'with country' do
      setup do
        @account.country = countries(:es)
      end

      should 'return currency of country on :currency' do
        assert_equal 'EUR', @account.currency
      end

      should 'return tax_rate of country on :tax_rate' do
        assert_equal 16, @account.tax_rate
      end
    end
  end

  test 'Account.buyer_users returns all users of all buyer accounts' do
    provider_account  = FactoryGirl.build_stubbed(:simple_provider)
    buyer_account_one = Factory.build(:simple_buyer, provider_account: provider_account)

    buyer_account_one.users << Factory.build(:simple_user)
    buyer_account_one.users << Factory.build(:simple_user)
    buyer_account_one.save!

    buyer_account_two = Factory.build(:simple_buyer, provider_account: provider_account)
    buyer_account_two.users << Factory.build(:simple_user)
    buyer_account_two.save!

    assert_same_elements buyer_account_one.users + buyer_account_two.users,
                         provider_account.buyer_users
  end

  test "Account.managed_users returns users of the account and users of it's buyer accounts" do
    provider_account = FactoryGirl.create(:simple_provider)
    provider_user    = FactoryGirl.create(:simple_user, account: provider_account)

    buyer_account = FactoryGirl.create(:simple_buyer, provider_account: provider_account)
    buyer_user    = FactoryGirl.create(:simple_user, account: buyer_account)

    other_provider_account = FactoryGirl.create(:simple_provider)
    other_provider_user    = FactoryGirl.create(:simple_user, account: other_provider_account)

    other_buyer_account = FactoryGirl.create(:simple_buyer, provider_account: other_provider_account)
    other_buyer_user    = FactoryGirl.create(:simple_user, account: other_buyer_account)

    assert_contains provider_account.managed_users, provider_user
    assert_contains provider_account.managed_users, buyer_user

    assert_does_not_contain provider_account.managed_users, other_provider_user
    assert_does_not_contain provider_account.managed_users, other_buyer_user
  end

  test 'Account.managed_users returns read-write records' do
    provider_account = FactoryGirl.create(:simple_provider)

    FactoryGirl.create(:simple_user, account: provider_account)

    assert !provider_account.managed_users.first.readonly?
  end

  context 'settings' do
    should 'be created lazily for existing account' do
      assert_no_difference 'Settings.count' do
        @account = Account.create!(org_name: 'Organization')
      end

      assert_difference 'Settings.count', 1 do
        @account.settings
      end
    end

    should 'be build lazily for new account' do
      account = Account.new

      assert_not_nil account.settings
      assert account.settings.new_record?
    end
  end

  test 'profile is lazily created' do
    account = Account.new
    assert_not_nil account.profile
  end

  test 'forum is lazily created for providers' do
    account = nil

    assert_no_change :of => lambda { Forum.count } do
      account = FactoryGirl.create(:simple_provider)
    end

    assert_not_nil account.forum
  end

  test 'forum is created with default name' do
    account = FactoryGirl.build_stubbed(:simple_provider)

    assert_equal 'Forum', account.forum.name
  end

  test '#forum! returns the forum when called on a provider account' do
    account = FactoryGirl.build_stubbed(:simple_provider)

    assert_instance_of Forum, account.forum!
  end

  test '#forum! raises an exception when called on a buyer account' do
    account = FactoryGirl.build_stubbed(:simple_buyer)

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

  test 'Account.find_by_provider_key! raises an exception if the key is invalid' do
    assert_raise Backend::ProviderKeyInvalid do
      Account.find_by_provider_key!('boo')
    end
  end

  test "Account.find_by_provider_key! finds account by bought cinstance's user_key" do
    account = FactoryGirl.create(:simple_account, provider_account: master_account)
    cinstance = account.buy!(master_account.default_service.published_plans.first)

    assert_equal account, Account.find_by_provider_key!(cinstance.user_key)
  end

  test 'Account.master raises and exception if there is no master account' do
    Account.delete_all

    assert_raise ActiveRecord::RecordNotFound do
      Account.master
    end
  end

  test 'Account.master returns master account' do
    Account.delete_all
    FactoryGirl.build_stubbed(:simple_account) # create one normal account, so I don't get false positives

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

    refute account.valid?, 'other master should be invalid'
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
    refute account.master_on_premises?

    # account is master and it's onprem
    ThreeScale.config.stubs(onpremises: true)
    assert account.master_on_premises?

    # it's onpprem but account is not master
    account.master = false
    ThreeScale.config.stubs(onpremises: true)
    refute account.master_on_premises?
  end

  test "Account#feature_allowed? returns true only if it's plan includes that feature" do
    feature_one = master_account.default_service.features.create!(name: 'free t-shirt')
    feature_two = master_account.default_service.features.create!(name: 'free pizza')

    plan = master_account.default_service.plans.published.first
    plan.enable_feature!(feature_one.system_name)

    account = FactoryGirl.create(:provider_account, provider_account: master_account)

    assert account.feature_allowed?(:free_t_shirt)  # works with symbols
    assert account.feature_allowed?('free_t_shirt') # and strings

    refute account.feature_allowed?(:free_pizza)
    refute account.feature_allowed?(:instant_success)
  end

  test "Account#feature_allowed? returns true by default for master account" do
    assert master_account.feature_allowed?(:prepaid_billing)
    assert master_account.feature_allowed?(:postpaid_billing)
    assert master_account.feature_allowed?(:domination_over_universe)

    # returns false for some features for master account
    assert !master_account.feature_allowed?(:anonymous_clients)
  end

  test "deleted billing strategy on destroy" do
    provider = FactoryGirl.create(:simple_provider)
    id = provider.create_billing_strategy.id
    provider.destroy
    assert_nil Finance::BillingStrategy.find_by_id(id), 'BillingStrategy not deleted'
  end

  test 'Account.id_from_api_key reads data from cache on cache hit' do
    Rails.cache.expects(:fetch).with("account_ids/foobar", any_parameters).returns(42)
    Account.expects(:find).never
    Account.expects(:find_by_sql).never

    assert_equal 42, Account.id_from_api_key('foobar')
  end

  test 'Account.id_from_api_key loads data from database and writes to cache on cache miss' do
    account = FactoryGirl.create(:provider_account)

    Rails.cache.stubs(:read).with("account_ids/#{account.api_key}", any_parameters).returns(nil)
    Rails.cache.expects(:write).with("account_ids/#{account.api_key}", account.id, any_parameters)

    assert_equal account.id, Account.id_from_api_key(account.api_key)
  end

  test 'Account#provider? returns true also for master account' do
    assert master_account.provider?
  end

  test "destroying account destroys it's services" do
    account = FactoryGirl.create(:provider_account)
    service = FactoryGirl.create(:simple_service, account: account)

    account.destroy

    assert_nil Service.find_by_id(service.id)
  end

  test "destroying account destroys the default service firing services destroy callbacks" do
    account = FactoryGirl.create(:provider_account)
    service = account.default_service
    metric  = FactoryGirl.create(:metric, service: service)
    feature = FactoryGirl.create(:feature, featurable: service)

    account.destroy

    assert_nil Service.find_by_id(service.id)
    assert_nil Metric.find_by_id(metric.id)
    assert_nil Feature.find_by_id(feature.id)
  end

  test 'destroying provider account with buyer accounts' do
    provider_account = FactoryGirl.create(:provider_account)
    plan = FactoryGirl.create(:simple_application_plan, service: provider_account.default_service)

    buyer_account = FactoryGirl.create(:simple_buyer, provider_account: provider_account)
    buyer_account.buy!(plan)

    assert_change :of => lambda { Account.providers.count }, :by => -1 do
      provider_account.destroy
    end
  end

  test '.model_name.human is account' do
    assert Account.model_name.human == "Account"
  end

  context '#can_create_application?' do
    setup do
      provider = FactoryGirl.create(:provider_account)
      @buyer   = FactoryGirl.create(:simple_buyer, provider_account: provider)

      @service = @buyer.provider_account.default_service
      #making the service subscribeable
      @service.publish!
      @plan = FactoryGirl.create(:simple_application_plan, service: @service)
      @plan.publish!

      #another subscribeable service
      @service_denied = FactoryGirl.create(:service, account: @buyer.provider_account)
      @service_denied.publish!
      @plan2 = FactoryGirl.create(:simple_application_plan, service: @service_denied)
      @plan2.publish!

      #subscribing to services
      @buyer.buy! @service.service_plans.first
      @buyer.buy! @service_denied.service_plans.first

      @service.update_attribute        :buyers_manage_apps, true
      @service_denied.update_attribute :buyers_manage_apps, false
    end

    should 'deny or allow depending of the service' do
      assert  @buyer.can_create_application?(@service)
      assert !@buyer.can_create_application?(@service_denied)
    end

    context 'any service allows buyers_manage_apps' do
      should 'return true when no service passed' do
        assert @buyer.can_create_application?
      end
    end # any service allows buyers_manage_apps

    context 'all services deny buyers_manage_apps' do
      setup do
        @service.update_attribute :buyers_manage_apps, false
      end

      should 'return false' do
        assert !@buyer.can_create_application?
      end
    end # all services deny buyers_manage_apps

  end # #can_create_application?

  context '#paid?' do
    setup do
      @buyer = FactoryGirl.create(:buyer_account)

      @service = @buyer.provider_account.default_service
      #making the service subscribeable
      @service.publish!

      @paid_plan = FactoryGirl.create(:simple_application_plan, service: @service, cost_per_month: 10.0)
      @paid_plan.publish!

      @free_plan = FactoryGirl.create(:simple_application_plan, service: @service)
      @free_plan.publish!

      #subscribing to services
      @buyer.buy! @service.service_plans.first
      @buyer.buy! @free_plan
    end

    should 'be false when account has no paid contract' do
      assert !@buyer.paid?
    end

    should 'be true when account has at least one paid contract' do
      @buyer.buy! @paid_plan
      assert @buyer.paid?
    end
  end #paid?

  context '#on_trial?' do
    setup do
      @buyer = FactoryGirl.create(:buyer_account)
      @service = @buyer.provider_account.default_service
      #making the service subscribeable
      @service.publish!

      @paid_15days = @service.service_plans.first
      @paid_15days.update_attributes(cost_per_month: 10.0, trial_period_days: 15, state: 'published')

      @paid_notrial = FactoryGirl.create(:simple_application_plan, service: @service, cost_per_month: 10.0, state: 'published')

      @buyer.buy! @paid_15days
    end

    should 'be true when account has all contracts on trial' do
      @buyer.reload
      assert @buyer.on_trial?
    end

    should 'be false when account has at least a contract is not on trial' do
      @buyer.buy! @paid_notrial
      assert !@buyer.on_trial?
    end
  end #on_trial?

  test "support email should have a valid email format for providers" do
    provider = FactoryGirl.build(:simple_provider, :support_email         => "support-email-acc.example.net",
                                                :finance_support_email => "finance-support-acc.example.net")
    provider.valid?

    assert provider.errors[:support_email].present?
    assert provider.errors[:finance_support_email].present?
  end

  #regression test
  test "support email should not be validated for buyers" do
    buyer = FactoryGirl.build(:simple_buyer, :support_email         => "support-email-acc.example.net",
                                          :finance_support_email => "finance-support-acc.example.net")

    assert buyer.valid?
    assert buyer.errors[:support_email].empty?
    assert buyer.errors[:finance_support_email].empty?
  end

  test "support_email should fall back to first admin email" do
    provider = FactoryGirl.build_stubbed(:provider_account)
    assert_equal provider.support_email, provider.admins.first.email
  end

  test "finance_support_email should fall back to support_email" do
    provider = FactoryGirl.build(:simple_provider, support_email: "support-email@acc.example.net")
    assert_equal provider.finance_support_email, provider.support_email

    provider.update_attribute :finance_support_email, "finance-support@acc.example.net"
    assert_equal provider.finance_support_email, "finance-support@acc.example.net"
  end

  #
  # regression test for https://github.com/3scale/system/issues/2767
  test 'destroy should destroy all cinstances and application_plans' do
    service = master_account.default_service
    master_account.account_plans.default!(master_account.account_plans.first)
    service.update_attribute(:default_service_plan, master_account.service_plans.first)

    master_account.signup_provider(master_account.application_plans.first) do |provider, user|
      @provider, @user = provider, user
      provider.subdomain = "foo"
      provider.org_name = "bar"
      provider.sample_data = false
      user.password = user.password_confirmation = "foobar"
      user.email = "foo@example.com"
    end

    @user.activate
    @provider.create_sample_data!

    cis = @provider.default_service.cinstances.map(&:id)
    aps = @provider.default_service.application_plans.map(&:id)

    @provider.expects(:destroy_all_contracts)

    @provider.destroy
    assert_equal 0, Cinstance.where(id: cis).count
    assert_equal 0, ApplicationPlan.where(id: aps).count
  end

  test 'onboarding builds object if not already created' do
    account = FactoryGirl.build(:account)

    assert_not_nil account.onboarding
  end

  test 'to_xml' do
    account = Account.new

    # just to make the serialization work
    def account.fields_definitions_source_root!; self; end

    account.domain = 'some.example.com'
    account.self_domain = 'admin.#{ThreeScale.config.superdomain}'

    domain_xml = '<domain>some.example.com</domain>'
    admin_domain_xml = '<admin_domain>admin.#{ThreeScale.config.superdomain}</admin_domain>'

    xml = account.to_xml

    refute_match domain_xml, xml
    refute_match admin_domain_xml, xml

    account.provider = true

    xml = account.to_xml

    assert_match domain_xml, xml
    assert_match admin_domain_xml, xml
  end

  test 'settings' do
    account  = Account.new
    settings = account.settings

    assert_equal account, settings.account
    # they are actually the same object
    assert_equal account.object_id, settings.account.object_id
  end

  test 'fetch_dispatch_rule' do
    account = FactoryGirl.create(:simple_account)

    user_signup = SystemOperation.for(:user_signup)
    daily_reports = SystemOperation.for(:daily_reports)

    assert account.fetch_dispatch_rule(user_signup).dispatch
    refute account.fetch_dispatch_rule(daily_reports).dispatch
  end

  test 'dispatch_rule_for' do
    account       = FactoryGirl.build_stubbed(:simple_provider)
    user_signup   = SystemOperation.for(:user_signup)
    daily_reports = SystemOperation.for(:daily_reports)

    FactoryGirl.create(:mail_dispatch_rule, system_operation: daily_reports, account: account)

    # When the migration is enabled, we disable the dispatch rules
    # because notifications are delivered and we don't want to deliver the info twice.
    account.expects(:provider_can_use?).with(:new_notification_system).returns(true).twice
    refute account.dispatch_rule_for(user_signup).dispatch
    refute account.dispatch_rule_for(daily_reports).dispatch

    account.expects(:provider_can_use?).with(:new_notification_system).returns(false).twice
    assert account.dispatch_rule_for(user_signup).dispatch
    assert account.dispatch_rule_for(daily_reports).dispatch
  end

  def test_accessible_services
    service = FactoryGirl.create(:simple_service)
    account = FactoryGirl.create(:simple_account, services: [service], default_service_id: service.id)

    assert_equal [service], account.accessible_services

    service.update_column(:state, 'deleted')
    refute account.accessible_services.exists?
  end

  def test_smart_destroy_buyer
    buyer = FactoryGirl.create(:buyer_account)

    buyer.smart_destroy
    assert_raise(ActiveRecord::RecordNotFound) { buyer.reload }
  end

  def test_smart_destroy_provider
    provider = FactoryGirl.create(:simple_provider)

    provider.smart_destroy
    assert provider.reload.scheduled_for_deletion?
  end

  def test_smart_destroy_master
    master_account.smart_destroy
    assert master_account.reload
    refute master_account.reload.scheduled_for_deletion?
  end
end

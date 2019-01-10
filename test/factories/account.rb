FactoryBot.define do
  factory(:account_without_users, :class => Account) do
    country_id do
      (Country.find_by_code('ES') ||
        Country.create!(:code => 'ES', :name => 'Spain', :currency => 'EUR')).id
    end

    sequence(:domain) { |n| "company#{n}.com" }
    sequence(:org_name) { |n| "company#{n}" }
    org_legaladdress { 'Perdido Street 123' }

    billing_address_name { 'Tim' }
    billing_address_address1 { 'Booked 2' }
    billing_address_address2 { 'Second Line of Address' }
    billing_address_city { 'Timbuktu' }
    billing_address_state { 'Mali' }
    billing_address_zip { '10100' }
    billing_address_phone { '+123 456 789' }
    billing_address_country { 'ES' }
    site_access_code { '' }
  end

  factory(:account, :parent => :account_without_users) do
    after(:create) do |account|
      if account.users.empty?
        username = account.org_name.gsub(/[^a-zA-Z0-9_\.]+/, '_')

        admin = FactoryBot.create(:admin, :username => username, :account_id => account.id)
        admin.activate!
      end
    end

    after(:stub) do |account|
      admin = FactoryBot.build_stubbed(:admin)

      account.stubs(:admins).returns([admin])
      admin.stubs(:account).returns(account)
    end
  end

  factory(:pending_account, :parent => :account) do
    after(:create) do |account|
      account.make_pending!
    end
  end

#FIXME: buyer accounts without provider accounts??? is that ok?
  factory(:buyer_account_with_pending_user, :parent => :account) do
    buyer { true }
  end

  factory(:pending_buyer_account, :parent => :buyer_account_with_pending_user) do
    after(:create) do |account|
      account.users.each do |user|
        user.activate! unless user.active? # horrible horrible factories
      end
    end
  end

  factory(:buyer_account, :parent => :pending_buyer_account) do
    association :provider_account
    after(:create) do |account|
      account.approve! if account.can_approve?
    end

    after(:build) do |account|
      if account.users.empty?
        username = account.org_name.gsub(/[^a-zA-Z0-9_\.]+/, '_')
        account.users << FactoryBot.build(:admin, :account => account, :username => username)
      end
    end
  end

  factory(:buyer_account_without_billing_address, :parent => :buyer_account) do
    association :provider_account

    after(:create) do |account|
      account.billing_address_name = nil
      account.billing_address_address1 = nil
      account.billing_address_address2 = nil
      account.billing_address_city = nil
      account.billing_address_country = nil
      account.save!
    end
  end

  factory(:buyer_account_with_provider, :parent => :buyer_account) do
    association :provider_account
  end

  factory(:pending_buyer_account_with_provider, :parent => :pending_buyer_account) do
    buyer { true }
  end

#TODO: rename this, it is actually buying plans!
  factory(:provider_account_with_pending_users_signed_up_to_no_plan, :parent => :account) do
    sequence(:self_domain) { |n| "admin-domain-company#{n}.com" }
    site_access_code { '' }
    payment_gateway_type { :bogus }
    provider { true }

    after(:build) do |account|
      account.provider_account ||= if Account.exists?(:master => true)
                                     Account.master
                                   else
                                     FactoryBot.create(:master_account)
                                   end
    end


    after(:stub) do |account|
      # [multiservices] This might not be right
      account.stubs(:service).returns(FactoryBot.build_stubbed(:service, :account => account))

      settings = FactoryBot.build_stubbed(:settings, :account => account)
      account.stubs(:settings).returns(settings)

      profile = FactoryBot.build_stubbed(:profile, :account => account)
      account.stubs(:profile).returns(profile)

      # Everything disallowed by default
      account.stubs(:feature_allowed?).returns(false)

      Account.stubs(:find_by_domain).with(account.domain).returns(account)
    end

    after(:create) do |account|
      master = Account.master

      # TODO: [multiservice] this is not needed, remove!
      master.account_plans.first!.create_contract_with(account)

      plan = FactoryBot.create :account_plan, :issuer => account
      account.default_account_plan = plan
      plan.publish!

      # assign tenant id manualy, because we cannot do it by trigger
      account.tenant_id = account.id

      account.approve!

      account.services.first.update_attribute :mandatory_app_key, false
      account.settings.update_attributes!(
        account_plans_ui_visible: true,
        service_plans_ui_visible: true,
        end_user_plans_ui_visible: true
      )
    end
  end

  factory(:provider_account_with_pending_users_signed_up_to_default_plan,
          :parent => :provider_account_with_pending_users_signed_up_to_no_plan) do

    after(:stub) do |account|
      master_account = begin
        Account.master
      rescue ActiveRecord::RecordNotFound
        FactoryBot.create(:master_account)
      end

      bought_cinstance = FactoryBot.build_stubbed(:cinstance,
                                         :plan => master_account.default_service.application_plans.published.first,
                                         :user_account => account)

      account.stubs(:bought_cinstance).returns(bought_cinstance)
      account.stubs(:provider_account).returns(master_account)
      Account.stubs(:find_by_provider_key).with(bought_cinstance.user_key).returns(account)
    end
  end

  factory(:provider_account,
          :parent => :provider_account_with_pending_users_signed_up_to_default_plan) do

    after(:create) do |account|
      if account.users.reload.empty?
        username = account.org_name.gsub(/[^a-zA-Z0-9_\.]+/, '_')
        account.users << FactoryBot.create(:admin, :account_id => account.id, :username => username, :tenant_id => account.id)
      end

      # account.admins.each(&:activate!)
    end
  end

  factory(:provider_with_billing, :parent => :provider_account) do
    after(:create) do |a|
      a.billing_strategy= FactoryBot.create(:postpaid_billing, :numbering_period => 'monthly');
      a.save
    end
  end

  factory(:master_account, :parent => :account) do
    master { true }
    org_name { 'Master account' }
    payment_gateway_type { :bogus }
    association :settings

    after(:build) do |account|
      account.billing_strategy = FactoryBot.build(:postpaid_with_charging)
      if account.users.empty?
        account.users << FactoryBot.build(:admin, :account_id => account.id, :username => "superadmin", state: 'active')
      end
      account.admins.each { |user| user.activate! if user.can_activate? }
    end

    after(:create) do |account|
      account.provider_account = account

      if account.users.empty?
        account.users << FactoryBot.create(:admin, :account_id => account.id, :username => "superadmin", state: 'active')
      end
      account.admins.each { |user| user.activate! if user.can_activate? }
      account.approve! if account.can_approve?

      #[multiservice] First service is the default
      service = FactoryBot.create(:service, :account => account)

      # Defaults
      application_plan = FactoryBot.create(:application_plan, :issuer => service, :name => 'Free')
      application_plan.publish!
      account_plan = FactoryBot.create(:account_plan, :issuer => account, :name => 'FreeAccountPlan')
      account_plan.publish!

      service.update_attribute :default_application_plan, application_plan
      service.update_attribute :default_service_plan, service.service_plans.first
      account.update_attribute :default_account_plan, account_plan

      # TODO: add more master features here, if needed
      %w[prepaid_billing postpaid_billing anonymous_clients liquid].each do |feature|
        account.default_service.features.create!(:system_name => feature, :name => feature.humanize)
      end

      FactoryBot.create(:cinstance, :plan => account.default_service.application_plans.published.first,
                        :user_account => account)

      account.reload
    end


    after(:stub) do |account|
      Account.stubs(:master).returns(account)
      Account.stubs(:find_by_domain).with(account.domain).returns(account)
    end
  end
end
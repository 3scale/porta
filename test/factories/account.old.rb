# frozen_string_literal: true

FactoryBot.define do # rubocop:disable Metrics/BlockLength
  factory(:account_without_users, class: Account) do
    country_id do
      (Country.find_by(code: 'ES') || Country.create!(code: 'ES', name: 'Spain', currency: 'EUR')).id
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

    trait :approved do
      state { :approved }
    end

    trait :rejected do
      state { :rejected }
    end

    trait :pending do
      state { :pending }
    end
  end

  factory(:provider_account, parent: :account) do # rubocop:disable Metrics/BlockLength
    sequence(:self_domain) { |n| "admin-domain-company#{n}.com" }
    site_access_code { '' }
    users { [association(:active_admin)] } # FIXME: move to :account but beware of failing tests

    payment_gateway_type { :bogus }
    provider { true }

    approved

    after(:build) do |account|
      account.provider_account ||= if Account.exists?(:master => true)
                                     Account.master
                                   else
                                     FactoryBot.create(:master_account)
                                   end
    end

    after(:stub) do |account|
      master_account = begin
        Account.master
      rescue ActiveRecord::RecordNotFound
        FactoryBot.create(:master_account)
      end

      bought_cinstance = FactoryBot.build_stubbed(:cinstance, plan: master_account.default_service.application_plans.published.first,
                                                              user_account: account)

      account.stubs(:bought_cinstance).returns(bought_cinstance)
      account.stubs(:provider_account).returns(master_account)
      Account.stubs(:first_by_provider_key).with(bought_cinstance.user_key).returns(account)

      # [multiservices] This might not be right
      account.stubs(:service).returns(FactoryBot.build_stubbed(:service, :account => account))

      settings = FactoryBot.build_stubbed(:settings, :account => account)
      account.stubs(:settings).returns(settings)

      profile = FactoryBot.build_stubbed(:profile, :account => account)
      account.stubs(:profile).returns(profile)

      # Everything disallowed by default
      account.stubs(:feature_allowed?).returns(false)

      Account.stubs(:find_by_domain).with(account.internal_domain).returns(account)
    end

    after(:create) do |account|
      master = Account.master

      # TODO: [multiservice] this is not needed, remove!
      master.account_plans.first!.create_contract_with(account)

      FactoryBot.create(:account_plan, issuer: account, default: true)
                .publish! # TODO: Move it inside factory

      # assign tenant id manualy, because we cannot do it by trigger
      account.tenant_id = account.id

      account.services.first.update_attribute :mandatory_app_key, false
      account.settings.update!(
        account_plans_ui_visible: true,
        service_plans_ui_visible: true
      )
    end

    trait :with_a_buyer do
      # TODO: buyer_accounts { [association(:buyer_account)] }
      after(:build) do |account|
        account.buyer_accounts << FactoryBot.build(:buyer_account, provider_account: account)
      end

      after(:stub) do |account|
        buyer_accounts = []
        account.stubs(:buyer_accounts).returns(buyer_accounts)
        account.buyer_accounts << FactoryBot.build_stubbed(:buyer_account, provider_account: account)
      end

      # looks nicer but doesn't work well
      # :buyer_account is generated before current factory so extra provider is created and tenant_id doesn't match
      # buyer_accounts { [association(:buyer_account)] }
    end
  end

  # TODO: transform into a trait
  factory(:provider_with_billing, :parent => :provider_account) do
    after(:create) do |a|
      a.billing_strategy= FactoryBot.create(:postpaid_billing, :numbering_period => 'monthly');
      a.save
    end
  end

  factory(:master_account, parent: :account) do # rubocop:disable Metrics/BlockLength
    master { true }
    org_name { 'Master account' }
    payment_gateway_type { :bogus }
    association :settings
    approved
    users { [association(:active_admin)] } # FIXME: move to :account but beware of failing tests

    after(:build) do |account|
      account.billing_strategy = FactoryBot.build(:postpaid_with_charging)
    end

    after(:create) do |account|
      account.provider_account = account

      #[multiservice] First service is the default
      service = FactoryBot.create(:service, account: account)

      # Defaults
      application_plan = FactoryBot.create(:application_plan, issuer: service, state: 'published')
      account_plan = FactoryBot.create(:account_plan, issuer: account, state: 'published')

      service.update_attribute :default_application_plan, application_plan
      service.update_attribute :default_service_plan, service.service_plans.first
      account.update_attribute :default_account_plan, account_plan

      # TODO: add more master features here, if needed
      %w[prepaid_billing postpaid_billing anonymous_clients liquid].each do |feature|
        account.default_service.features.create!(system_name: feature, name: feature.humanize)
      end

      FactoryBot.create(:cinstance, plan: account.default_service.application_plans.published.first,
                                    user_account: account)

      account.reload
    end

    after(:stub) do |account|
      Account.stubs(:master).returns(account)
      Account.stubs(:find_by_domain).with(account.internal_domain).returns(account)
    end
  end
end

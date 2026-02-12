FactoryBot.define do

  # Note: tenant_id discrepancies when using simple factories, not good for request testing

  factory(:simple_account, :class => Account) do
    association(:country)

    sequence(:domain) { |n| "simplecompany#{n}.com" }
    sequence(:org_name) { |n| "simplecompany#{n}" }
    org_legaladdress { 'Perdido Street 123' }
    city { 'Barcelona' }

    billing_address_name { 'Tim' }
    billing_address_address1 { 'Booked 2' }
    billing_address_address2 { 'Second Line of Address' }
    billing_address_city { 'Timbuktu' }
    billing_address_state { 'Mali' }
    billing_address_zip { '10100' }
    billing_address_phone { '+123 456 789' }
    billing_address_country { 'ES' }

    site_access_code { '' }

    state { 'approved' }
  end

  factory(:simple_buyer, :class => Account, :parent => :simple_account) do
    buyer { true }
    domain { nil }
    self_domain { nil }
  end

  factory(:simple_master, class: Account, parent: :simple_account) do
    master { true }
    domain { 'www.example.com' }
    self_domain { 'www.example.com' }

    after(:create) do |account| # not so simple, but works like normal master
      FactoryBot.create(:simple_account_plan, issuer: account)
      service = FactoryBot.create(:simple_service, account: account)
      FactoryBot.create(:simple_application_plan, issuer: service)
      account.update_columns(provider_account_id: account.id) # master is it's own provider!
    end

    after(:stub) do |account|
      Account.stubs(:master).returns(account)
      Account.stubs(:find_by_domain).with(account.internal_domain).returns(account)
    end
  end

  factory(:simple_provider, :class => Account, :parent => :simple_account) do
    sequence(:domain) { |n| "simple#{n}.example.com" }
    sequence(:self_domain) { |n| "simple#{n}-admin.example.com" }

    site_access_code { nil }
    payment_gateway_type { :bogus }
    sequence(:s3_prefix) { |n| "fake-s3-prefix-#{n}" }

    after(:stub) do |account|
      account.provider = true
      account.stubs(:provider_key).returns("stubbed-#{SecureRandom.hex(16)}")
    end

    after(:create) do |account|
      account.provider_account ||= if Account.exists?(:master => true)
                                     Account.master
                                   else
                                     FactoryBot.create(:simple_master)
                                   end
      account.provider = true
      account.tenant_id = account.id
      account.save!
    end
  end

  factory(:simple_service, :class => Service) do
    mandatory_app_key { false }
    sequence(:name) { |n| "simpleservice#{n}" }
    association(:account, :factory => :simple_provider)
    after(:create) do |record|
      record.service_tokens.first_or_create!(value: 'token')
    end

    trait :with_default_backend_api do
      after(:create) do |record|
        backend_api = FactoryBot.create(:backend_api, account: record.account, private_endpoint: 'https://echo-api.3scale.net')
        FactoryBot.create(:backend_api_config, path: '', service: record, backend_api: backend_api)
      end
    end
  end

  factory(:simple_cinstance, :class => Cinstance) do
    association(:plan, :factory => :simple_application_plan)
    association(:user_account, :factory => :simple_account)

    after(:stub) do |app|
      app.stubs(:service).returns(app.plan.issuer)
    end
  end

  factory(:simple_service_contract, :class => ServiceContract) do
    association(:plan, :factory => :simple_service_plan)
    association(:user_account, :factory => :simple_account)
  end


  factory(:simple_plan, :class => Plan) do
    sequence(:name) {|n| "simple-plan-#{n}" }
  end

  factory(:simple_user, :class => User) do
    sequence(:email) { |n| "simple#{n}@example.net" }
    sequence(:username) { |n| "simpledude#{n}" }
    password { 'superSecret1234#' }
    association(:account, :factory => :simple_provider)
    # TODO: maybe activate it?
  end

  factory(:simple_admin, parent: :simple_user) do
    role { :admin }
  end

  factory(:simple_account_plan, parent: :simple_plan, class: AccountPlan) do
    association(:issuer, :factory => :simple_provider)
  end

  factory(:simple_application_plan, :parent => :simple_plan, :class => ApplicationPlan) do
    association(:issuer, :factory => :simple_service)
  end

  factory(:simple_service_plan, :parent => :simple_plan, :class => ServicePlan) do
    association(:issuer, :factory => :simple_service)

    trait :default do
      after(:build) do |plan|
        plan.issuer.default_service_plan = plan
      end
    end
  end

  factory(:simple_proxy, class: Proxy) do
    association :service, factory: :simple_service
    api_backend { 'http://api.example.net:80' }
    secret_token { '123' }
  end
end

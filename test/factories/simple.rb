# TODO: dry up with account_without_users
Factory.define(:simple_account, :class => Account) do |factory|
  factory.association(:country)

  factory.sequence(:domain) { |n| "simplecompany#{n}.com" }
  factory.sequence(:org_name) { |n| "simplecompany#{n}" }
  factory.org_legaladdress 'Perdido Street 123'
  factory.city 'Barcelona'

  factory.billing_address_name 'Tim'
  factory.billing_address_address1 'Booked 2'
  factory.billing_address_address2 'Second Line of Address'
  factory.billing_address_city 'Timbuktu'
  factory.billing_address_state 'Mali'
  factory.billing_address_zip '10100'
  factory.billing_address_phone '+123 456 789'
  factory.billing_address_country 'ES'

  factory.site_access_code ''

  factory.state 'approved'
end

Factory.define(:simple_buyer, :class => Account, :parent => :simple_account) do |factory|
  factory.buyer true
  factory.domain nil
  factory.self_domain nil
end

Factory.define(:simple_master, class: Account, parent: :simple_account) do |factory|
  factory.master true
  factory.domain 'www.example.com'
  factory.self_domain 'www.example.com'

  factory.after_create do |account| # not so simple, but works like normal master
    FactoryBot.create(:simple_account_plan, issuer: account)
    service = FactoryBot.create(:simple_service, account: account)
    FactoryBot.create(:simple_application_plan, issuer: service)
    account.update_columns(provider_account_id: account.id) # master is it's own provider!
  end

  factory.after_stub do |account|
    Account.stubs(:master).returns(account)
    Account.stubs(:find_by_domain).with(account.domain).returns(account)
  end
end

Factory.define(:simple_provider, :class => Account, :parent => :simple_account) do |factory|
  factory.sequence(:domain) { |n| "simple#{n}.example.com" }
  factory.sequence(:self_domain) { |n| "simple#{n}-admin.example.com" }

  factory.site_access_code nil
  factory.payment_gateway_type :bogus
  factory.sequence(:s3_prefix) { |n| "fake-s3-prefix-#{n}" }

  factory.after_stub do |account|
    account.provider = true
    account.stubs(:provider_key).returns("stubbed-#{SecureRandom.hex(16)}")
  end

  factory.after_create do |account|
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

Factory.define(:simple_service, :class => Service) do |service|
  service.mandatory_app_key false
  service.sequence(:name) { |n| "service#{n}" }
  service.association(:account, :factory => :simple_provider)
  service.after_create do |record|
    record.service_tokens.first_or_create!(value: 'token')
  end
end

Factory.define(:simple_cinstance, :class => Cinstance) do |cinstance|
  cinstance.association(:plan, :factory => :simple_application_plan)
  cinstance.association(:user_account, :factory => :simple_account)

  cinstance.after_stub do |app|
    app.stubs(:service).returns(app.plan.issuer)
  end
end

Factory.define(:simple_service_contract, :class => ServiceContract) do |factory|
  factory.association(:plan, :factory => :simple_service_plan)
  factory.association(:user_account, :factory => :simple_account)
end


Factory.define(:simple_plan, :class => Plan) do |plan|
  plan.sequence(:name) {|n| "simple-plan-#{n}" }
end

Factory.define(:simple_user, :class => User) do |user|
  user.sequence(:email) { |n| "simple#{n}@example.net" }
  user.sequence(:username) { |n| "simpledude#{n}" }
  user.password 'supersecret'
  user.association(:account, :factory => :simple_provider)
  # TODO: maybe activate it?
end

Factory.define(:simple_admin, parent: :simple_user) do |user|
  user.role :admin
end

Factory.define(:simple_account_plan, parent: :simple_plan, class: AccountPlan) do |plan|
  plan.association(:issuer, :factory => :simple_provider)
end

Factory.define(:simple_application_plan, :parent => :simple_plan, :class => ApplicationPlan) do |plan|
  plan.association(:issuer, :factory => :simple_service)
end

Factory.define(:simple_service_plan, :parent => :simple_plan, :class => ServicePlan) do |plan|
  plan.association(:issuer, :factory => :simple_service)
end

Factory.define(:simple_proxy, class: Proxy) do |factory|
  factory.association :service, factory: :simple_service
  factory.api_backend 'http://api.example.net:80'
  factory.secret_token '123'
end

Factory.define(:account_without_users, :class => Account) do |factory|
  factory.country_id do
    (Country.find_by_code('ES') ||
    Country.create!(:code => 'ES', :name => 'Spain', :currency => 'EUR')).id
  end

  factory.sequence(:domain) { |n| "company#{n}.com" }
  factory.sequence(:org_name) { |n| "company#{n}" }
  factory.org_legaladdress 'Perdido Street 123'

  factory.billing_address_name 'Tim'
  factory.billing_address_address1 'Booked 2'
  factory.billing_address_address2 'Second Line of Address'
  factory.billing_address_city 'Timbuktu'
  factory.billing_address_state 'Mali'
  factory.billing_address_zip '10100'
  factory.billing_address_phone '+123 456 789'
  factory.billing_address_country 'ES'
  factory.site_access_code ''
end

Factory.define(:account, :parent => :account_without_users) do |factory|
  factory.after_create do |account|
    if account.users.empty?
      username = account.org_name.gsub(/[^a-zA-Z0-9_\.]+/, '_')

      admin = Factory(:admin, :username => username, :account_id => account.id)
      admin.activate!
    end
  end

  factory.after_stub do |account|
    admin = Factory.stub(:admin)

    account.stubs(:admins).returns([admin])
    admin.stubs(:account).returns(account)
  end
end

Factory.define(:pending_account, :parent => :account) do |factory|
  factory.after_create do |account|
    account.make_pending!
  end
end

#FIXME: buyer accounts without provider accounts??? is that ok?
Factory.define(:buyer_account_with_pending_user, :parent => :account) do |factory|
  factory.buyer true
end

Factory.define(:pending_buyer_account, :parent => :buyer_account_with_pending_user) do |factory|
  factory.after_create do |account|
    account.users.each do |user|
      user.activate! unless user.active? # horrible horrible factories
    end
  end
end

Factory.define(:buyer_account, :parent => :pending_buyer_account) do |factory|
  factory.association :provider_account
  factory.after_create do |account|
    account.approve! if account.can_approve?
  end

  factory.after_build do |account|
    if account.users.empty?
      username = account.org_name.gsub(/[^a-zA-Z0-9_\.]+/, '_')
      account.users << Factory.build(:admin, :account => account, :username => username)
    end
  end
end

Factory.define(:buyer_account_without_billing_address, :parent => :buyer_account) do |factory|
  factory.association :provider_account

  factory.after_create do |account|
    account.billing_address_name = nil
    account.billing_address_address1 = nil
    account.billing_address_address2 = nil
    account.billing_address_city = nil
    account.billing_address_country = nil
    account.save!
  end
end

Factory.define(:buyer_account_with_provider, :parent => :buyer_account) do |factory|
  factory.association :provider_account
end

Factory.define(:pending_buyer_account_with_provider, :parent => :pending_buyer_account) do |factory|
  factory.buyer true
end

#TODO: rename this, it is actually buying plans!
Factory.define(:provider_account_with_pending_users_signed_up_to_no_plan,
               :parent => :account) do |factory|
  factory.sequence(:self_domain) { |n| "admin-domain-company#{n}.com" }
  factory.site_access_code ''
  factory.payment_gateway_type :bogus
  factory.provider true

  factory.after_build do |account|
    account.provider_account ||= if Account.exists?(:master => true)
                                   Account.master
                                 else
                                   Factory(:master_account)
                                 end
  end


  factory.after_stub do |account|
    # [multiservices] This might not be right
    account.stubs(:service).returns(Factory.stub(:service, :account => account))

    settings = Factory.stub(:settings, :account => account)
    account.stubs(:settings).returns(settings)

    profile = Factory.stub(:profile, :account => account)
    account.stubs(:profile).returns(profile)

    # Everything disallowed by default
    account.stubs(:feature_allowed?).returns(false)

    Account.stubs(:find_by_domain).with(account.domain).returns(account)
  end

  factory.after_create do |account|
    master = Account.master

    # TODO: [multiservice] this is not needed, remove!
    master.account_plans.first!.create_contract_with(account)

    plan = Factory :account_plan, :issuer => account
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

Factory.define(:provider_account_with_pending_users_signed_up_to_default_plan,
               :parent => :provider_account_with_pending_users_signed_up_to_no_plan) do |factory|
  factory.after_stub do |account|
    master_account = begin
                       Account.master
                     rescue ActiveRecord::RecordNotFound
                       Factory(:master_account)
                     end

    bought_cinstance = Factory.stub(:cinstance,
                                    :plan => master_account.default_service.application_plans.published.first,
                                    :user_account => account)

    account.stubs(:bought_cinstance).returns(bought_cinstance)
    account.stubs(:provider_account).returns(master_account)
    Account.stubs(:find_by_provider_key).with(bought_cinstance.user_key).returns(account)
  end
end

Factory.define(:provider_account,
               :parent => :provider_account_with_pending_users_signed_up_to_default_plan) do |factory|

  factory.after_create do |account|
    if account.users.reload.empty?
      username = account.org_name.gsub(/[^a-zA-Z0-9_\.]+/, '_')
      account.users << Factory(:admin, :account_id => account.id, :username => username, :tenant_id => account.id)
    end

    # account.admins.each(&:activate!)
  end
end

Factory.define(:provider_with_billing, :parent => :provider_account) do |factory|
  factory.after_create do |a|
    a.billing_strategy= Factory(:postpaid_billing, :numbering_period => 'monthly');
    a.save
  end
end

Factory.define(:master_account, :parent => :account) do |factory|
  factory.master true
  factory.org_name 'Master account'
  factory.payment_gateway_type :bogus
  factory.association :settings

  factory.after_build do |account|
    account.billing_strategy = Factory.build(:postpaid_with_charging)
    if account.users.empty?
      account.users << Factory.build(:admin, :account_id => account.id, :username => "superadmin", state: 'active')
    end
    account.admins.each { |user| user.activate! if user.can_activate? }
  end

  factory.after_create do |account|
    account.provider_account = account

    if account.users.empty?
      account.users << Factory(:admin, :account_id => account.id, :username => "superadmin", state: 'active')
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

    Factory(:cinstance, :plan => account.default_service.application_plans.published.first,
                        :user_account => account)

    account.reload
  end


  factory.after_stub do |account|
    Account.stubs(:master).returns(account)
    Account.stubs(:find_by_domain).with(account.domain).returns(account)
  end
end

Factory.define(:contract) do |factory|
  factory.association :user_account, :factory => :pending_buyer_account

  factory.after_stub do |cinstance|
    cinstance.created_at = 2.months.ago
    cinstance.state = 'live'
    cinstance.user_key ||= SecureRandom.hex(16)
    cinstance.provider_public_key ||= SecureRandom.hex(32)

    cinstance.stubs(:keys).returns([])
    cinstance.stubs(:access_rules).returns([])
  end

  factory.after_build do |contract|
    if contract.plan && contract.user_account && contract.user_account.provider_account.nil?
      contract.plan.provider_account.buyer_accounts << contract.user_account
    end
  end

end

Factory.define(:cinstance, :parent => :contract, :class => Cinstance) do |factory|
  factory.association :plan, :factory => :application_plan
end

# Alias for future renaming
Factory.define(:application_contract, :parent => :cinstance) do |factory|
end

# Alias for future renaming
Factory.define(:application, :parent => :cinstance) do |factory|
end


Factory.define(:account_contract, :parent => :contract, :class => AccountContract) do |factory|
  factory.association :plan, :factory => :account_plan
end

Factory.define(:service_contract, :parent => :contract, :class => ServiceContract) do |factory|
  factory.association :plan, :factory => :service_plan
end

Factory.define(:application_key) do |factory|
  factory.association :application, :factory => :cinstance
  factory.sequence(:value) { |n| "app-key-#{n}" }
end

Factory.define(:referrer_filter) do |factory|
  factory.association :application, :factory => :cinstance
  factory.sequence(:value) { |n| "#{n}.domain.example.com" }
end

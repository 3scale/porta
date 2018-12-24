FactoryBot.define do
  factory(:profile) do
    association :account
  end

  factory(:forum) do
    name 'Forum'
    account {|a| a.association(:provider_account)}
  end

  factory(:topic_category) do
    name 'Tech'
  end

  factory(:topic) do
    title { "Title #{SecureRandom.hex}" }
    body 'body body body of the first post'
    forum { |topic| topic.association(:forum) }
    user  { |topic| topic.association(:user_with_account) }
  end

  factory(:post) do
    body "Body of post"
    user  { |post| post.association(:user_with_account) }
    topic { |post| post.association(:topic) }
  end

  factory(:service) do
    mandatory_app_key false
    #  association :proxy, :factory => :proxy
    sequence(:name) { |n| "service#{n}" }
    association(:account, :factory => :provider_account)
    after_create do |record|
      record.service_tokens.first_or_create!(value: 'token')
    end
  end

  factory(:service_token) do
    association :service
    sequence(:value) { |n| "value#{n}" }
  end

  factory(:metric) do
    association :service
    sequence(:friendly_name) { |n| "Metric #{n}" }
    sequence(:unit) { |m| "metric_#{m}" }
  end

  factory(:feature) do
    sequence(:name) { |n| "feature#{n}" }
  end

  factory(:usage_limit) do
    association(:plan, :factory => :application_plan)
    association(:metric)
    period :month
    value 10_000
  end

  factory(:pricing_rule) do
    metric { |metric| metric.association(:metric) }
    cost_per_unit 0.1
    sequence(:min) { |n| n }
    sequence(:max) { |n| n + 0.99 }
  end

  factory(:country) do
    sequence(:name) { |n| "country#{n}" }
    sequence(:code) { |n| "X#{n}" }
    currency 'EUR'
  end

  factory(:system_operation) do
    ref "plan_change"
    name "Contract type change"
    description ""
  end

  factory(:mail_dispatch_rule) do
    account {|account| account.association(:account)}
    system_operation {|operation| operation.association(:system_operation)}
    emails "email@email.example.net"
    dispatch true
  end

  factory(:settings)

  factory(:webhook, :class => WebHook) do
    account { |wh| wh.association(:provider_account) }
    url { |wh| 'http://' + wh.account.domain }
    active true
    provider_actions true
  end

  factory(:payment_gateway_setting, :class => PaymentGatewaySetting) do
    gateway_type :bogus
    gateway_settings foo: :bar
    association :account
  end

  factory(:sso_authorization) do
    sequence(:uid) { |n| "#{n}234" }
    id_token 'first-token'
    association(:authentication_provider, factory: :authentication_provider)
    association(:user, factory: :user_with_account)
  end
end

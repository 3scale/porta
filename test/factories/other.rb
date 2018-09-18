Factory.define(:profile) do |profile|
  profile.association :account
end

Factory.define(:forum) do |f|
  f.name 'Forum'
  f.account {|a| a.association(:provider_account)}
end

Factory.define(:topic_category) do |c|
  c.name 'Tech'
end

Factory.define(:topic) do |factory|
  factory.title { "Title #{SecureRandom.hex}" }
  factory.body 'body body body of the first post'
  factory.forum { |topic| topic.association(:forum) }
  factory.user  { |topic| topic.association(:user_with_account) }
end

Factory.define(:post) do |factory|
  factory.body "Body of post"
  factory.user  { |post| post.association(:user_with_account) }
  factory.topic { |post| post.association(:topic) }
end

Factory.define(:service) do |service|
  service.mandatory_app_key false
  #  service.association :proxy, :factory => :proxy
  service.sequence(:name) { |n| "service#{n}" }
  service.association(:account, :factory => :provider_account)
  service.after_create do |record|
    record.service_tokens.first_or_create!(value: 'token')
  end
end

Factory.define(:service_token) do |service_token|
  service_token.association :service
  service_token.sequence(:value) { |n| "value#{n}" }
end

Factory.define(:metric) do |metric|
  metric.association :service
  metric.sequence(:friendly_name) { |n| "Metric #{n}" }
  metric.sequence(:unit) { |m| "metric_#{m}" }
end

Factory.define(:feature) do |feature|
  feature.sequence(:name) { |n| "feature#{n}" }
end

Factory.define(:usage_limit) do |usage_limit|
  usage_limit.association(:plan, :factory => :application_plan)
  usage_limit.association(:metric)
  usage_limit.period :month
  usage_limit.value 10_000
end

Factory.define(:pricing_rule) do |pricing_rule|
  pricing_rule.metric { |metric| metric.association(:metric) }
  pricing_rule.cost_per_unit 0.1
  pricing_rule.sequence(:min) { |n| n }
  pricing_rule.sequence(:max) { |n| n + 0.99 }
end

Factory.define(:country) do |c|
  c.sequence(:name) { |n| "country#{n}" }
  c.sequence(:code) { |n| "X#{n}" }
  c.currency 'EUR'
end

Factory.define(:system_operation) do |op|
  op.ref "plan_change"
  op.name "Contract type change"
  op.description ""
end

Factory.define(:mail_dispatch_rule) do |t|
  t.account {|account| account.association(:account)}
  t.system_operation {|operation| operation.association(:system_operation)}
  t.emails "email@email.example.net"
  t.dispatch true
end

Factory.define(:settings) {}

Factory.define(:webhook, :class => WebHook) do |wh|
  wh.account { |wh| wh.association(:provider_account) }
  wh.url { |wh| 'http://' + wh.account.domain }
  wh.active true
  wh.provider_actions true
end

Factory.define(:payment_gateway_setting, :class => PaymentGatewaySetting) do |factory|
  factory.gateway_type :bogus
  factory.gateway_settings foo: :bar
  factory.association :account
end

Factory.define(:sso_authorization) do |sso|
  sso.sequence(:uid) { |n| "#{n}234" }
  sso.id_token 'first-token'
  sso.association(:authentication_provider, factory: :authentication_provider)
  sso.association(:user, factory: :user_with_account)
end

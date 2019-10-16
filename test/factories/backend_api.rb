# frozen_string_literal: true

FactoryBot.define do
  factory :backend_api do
    sequence(:name) { |n| "Backend #{n}" }
    sequence(:system_name) { |n| "backend-api-#{n}" }
    description { 'A Backend' }
    private_endpoint { 'http://api.example.net:80' }
    association(:account, factory: :simple_provider)
  end

  factory :backend_api_config do
    sequence(:path) { |n| "/path#{n}" }
    association :service
    association :backend_api
  end
end

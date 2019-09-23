# frozen_string_literal: true

FactoryBot.define do
  factory :backend_api do
    sequence(:name) { |n| "Backend API #{n}" }
    sequence(:system_name) { |n| "backend-api-#{n}" }
    description { 'A Backend API' }
    private_endpoint { 'http://api.example.net:80' }
    association(:account, factory: :simple_provider)
  end

  factory :backend_api_config do
    sequence(:path) { |n| "path#{n}" }
    association :backend_api
    service { create(:service, account: backend_api.account) }
  end
end

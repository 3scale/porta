# frozen_string_literal: true

FactoryBot.define do
  factory :backend_api do
    sequence(:name) { |n| "Backend API #{n}" }
    sequence(:system_name) { |n| "backend-api-#{n}" }
    description { 'A Backend API' }
    private_endpoint { 'http://api.example.net:80' }
    association(:account, factory: :simple_provider)
  end
end

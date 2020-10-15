# frozen_string_literal: true

FactoryBot.define do
  factory(:api_docs_service, class: ApiDocs::Service) do
    sequence(:name) { |n| "service#{n}" }
    association(:account, factory: :simple_provider)
    sequence(:body) do |n|
      {
        swagger: "2.0",
        info: { version: "1.0.0", title: "My spec #{n}", description: "This is my swagger 2,0 spec for api-#{n}" },
        host: "api-#{n}.example.com",
        schemes: ['http'],
        paths: {}
      }.to_json
    end

    before(:validation) do |api_docs_service|
      account = FactoryBot.create(:simple_provider)

      api_docs_service.account = account
      api_docs_service.owner = account
    end
  end
end


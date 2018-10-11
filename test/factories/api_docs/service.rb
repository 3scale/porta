# frozen_string_literal: true
Factory.define(:api_docs_service, class: ApiDocs::Service) do |factory|
  factory.sequence(:name) { |n| "service#{n}" }
  factory.association(:account, factory: :simple_provider)
  factory.sequence(:body) do |n|
    {
      swagger: "2.0",
      info: { version: "1.0.0", title: "My spec #{n}", description: "This is my swagger 2,0 spec for api-#{n}" },
      host: "api-#{n}.example.com",
      schemes: ['http'],
      paths: {}
    }.to_json
  end
end

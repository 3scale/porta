# frozen_string_literal: true

module Api::ApplicationsHelper
  include ::ApplicationsHelper

  def new_application_form_data(provider:, service:, cinstance: nil)
    data = {
      'create-application-path': admin_service_applications_path(service),
      product: ServiceDecorator.new(service).new_application_data.to_json,
      'most-recently-created-buyers': most_recently_created_buyers(provider).to_json,
      'buyers-count': raw_buyers.size,
    }
    data.merge super(provider, cinstance)
  end
end

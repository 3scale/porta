# frozen_string_literal: true

module Provider::Admin::ApplicationsHelper
  include ::ApplicationsHelper

  def new_application_form_data(provider:, cinstance: nil)
    data = {
      'create-application-path': provider_admin_applications_path,
      'most-recently-created-buyers': most_recently_created_buyers(provider).to_json,
      'buyers-count': raw_buyers.size,
      'most-recently-updated-products': most_recently_updated_products.to_json,
      'products-count': raw_products.size,
    }
    data.merge super(provider, cinstance)
  end
end

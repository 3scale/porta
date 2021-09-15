# frozen_string_literal: true

class Provider::Admin::ApplicationsNewPresenter
  include Applications
  include PlansHelper

  delegate :can?, to: :ability

  def initialize(provider:, user:, cinstance: nil)
    @provider = provider
    @cinstance = cinstance
    @ability = Ability.new(user)
  end

  attr_reader :provider, :cinstance, :ability

  alias current_account provider

  def new_application_form_data
    buyers_count = raw_buyers.size
    products_count = raw_products.size
    data = {
      'create-application-path': provider_admin_applications_path,
      'most-recently-created-buyers': most_recently_created_buyers.to_json,
      'buyers-count': buyers_count,
      'most-recently-updated-products': most_recently_updated_products.to_json,
      'products-count': products_count,
    }
    data['buyers-path'] = admin_buyers_accounts_path if buyers_count > 20
    data['products-path'] = admin_services_path if products_count > 20
    data.merge new_application_form_base_data(provider, cinstance)
  end

end

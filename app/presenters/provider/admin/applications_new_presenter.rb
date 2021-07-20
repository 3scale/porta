# frozen_string_literal: true

class Provider::Admin::ApplicationsNewPresenter
  include Applications
  include PlansHelper
  include System::UrlHelpers.system_url_helpers

  delegate :can?, to: :ability

  def initialize(provider:, user:, cinstance: nil)
    @provider = provider
    @cinstance = cinstance
    @ability = Ability.new(user)
  end

  attr_reader :provider, :cinstance, :ability

  alias current_account provider

  def new_application_form_data
    data = {
      'create-application-path': provider_admin_applications_path,
      'most-recently-created-buyers': most_recently_created_buyers.to_json,
      'buyers-count': raw_buyers.size,
      'most-recently-updated-products': most_recently_updated_products.to_json,
      'products-count': raw_products.size,
    }
    data.merge new_application_form_base_data(provider, cinstance)
  end

end

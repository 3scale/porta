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
    data = {
      'create-application-path': provider_admin_applications_path,
      'most-recently-created-buyers': buyers.to_json,
      'buyers-count': raw_buyers.size,
      'most-recently-updated-products': products.to_json,
      'products-count': raw_products.size,
    }
    data.merge new_application_form_base_data(provider, cinstance)
  end

end

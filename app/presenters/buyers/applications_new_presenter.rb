# frozen_string_literal: true

class Buyers::ApplicationsNewPresenter
  include Applications
  include PlansHelper

  delegate :can?, to: :ability

  def initialize(provider:, buyer:, user:, cinstance: nil)
    @provider = provider
    @buyer = buyer
    @cinstance = cinstance
    @ability = Ability.new(user)
  end

  attr_reader :provider, :buyer, :cinstance, :ability

  alias current_account provider

  def new_application_form_data
    data = {
      'create-application-path': admin_buyers_account_applications_path(buyer),
      buyer: BuyerDecorator.new(buyer).new_application_data.to_json,
      'most-recently-updated-products': most_recently_updated_products.to_json,
      'products-count': raw_products.size,
    }
    data.merge new_application_form_base_data(provider, cinstance)
  end

end

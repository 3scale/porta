# frozen_string_literal: true

class Buyers::ApplicationsNewPresenter
  include NewApplicationForm
  include PlansHelper

  delegate :can?, to: :ability

  def initialize(provider:, buyer:, user:, cinstance: nil)
    @provider = provider
    @buyer = buyer
    @user = user
    @cinstance = cinstance
    @ability = Ability.new(user)
  end

  attr_reader :provider, :buyer, :user, :cinstance, :ability

  alias current_account provider

  def new_application_form_data
    products_count = products_presenter.total_entries
    data = {
      'create-application-path': admin_buyers_account_applications_path(buyer),
      buyer: BuyerPresenter.new(buyer).new_application_data.to_json,
      'most-recently-updated-products': products.to_json,
      'products-count': products_count
    }
    data['products-path'] = admin_services_path if products_count > 20
    data.merge new_application_form_base_data(provider, cinstance)
  end

end

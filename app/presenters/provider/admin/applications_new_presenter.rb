# frozen_string_literal: true

class Provider::Admin::ApplicationsNewPresenter
  include NewApplicationForm
  include PlansHelper

  delegate :can?, to: :ability

  def initialize(provider:, user:, cinstance: nil)
    @provider = provider
    @cinstance = cinstance
    @user = user
    @ability = Ability.new(user)
  end

  attr_reader :provider, :cinstance, :user, :ability

  alias current_account provider

  def new_application_form_data
    buyers_count = accounts_presenter.total_entries
    products_count = products_presenter.total_entries
    data = {
      'create-application-path': provider_admin_applications_path,
      'most-recently-created-buyers': buyers.to_json,
      'buyers-count': buyers_count,
      'most-recently-updated-products': products.to_json,
      'products-count': products_count
    }
    data['buyers-path'] = admin_buyers_accounts_path if buyers_count > 20
    data['products-path'] = admin_services_path if products_count > 20
    data.merge new_application_form_base_data(provider, cinstance)
  end

end

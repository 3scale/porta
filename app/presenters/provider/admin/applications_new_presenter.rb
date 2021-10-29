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
    data = {
      'create-application-path': provider_admin_applications_path,
      'most-recently-created-buyers': buyers.to_json,
      'buyers-count': accounts_presenter.total_entries,
      'most-recently-updated-products': products.to_json,
      'products-count': products_presenter.total_entries
    }
    data.merge new_application_form_base_data(provider, cinstance)
  end

end

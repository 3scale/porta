# frozen_string_literal: true

class Api::ApplicationsNewPresenter
  include NewApplicationForm
  include PlansHelper

  delegate :can?, to: :ability

  def initialize(provider:, service:, user:, cinstance: nil)
    @provider = provider
    @service = service
    @user = user
    @cinstance = cinstance
    @ability = Ability.new(user)
  end

  attr_reader :provider, :service, :user, :cinstance, :ability

  alias current_account provider

  def new_application_form_data
    buyers_count = accounts_presenter.total_entries
    data = {
      'create-application-path': admin_service_applications_path(service),
      product: ServicePresenter.new(service).new_application_data.to_json,
      'most-recently-created-buyers': buyers.to_json,
      'buyers-count': buyers_count,
    }
    data['buyers-path'] = admin_buyers_accounts_path if buyers_count > 20
    data.merge new_application_form_base_data(provider, cinstance)
  end
end

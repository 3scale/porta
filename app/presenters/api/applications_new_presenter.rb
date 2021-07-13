# frozen_string_literal: true

class Api::ApplicationsNewPresenter
  include ApplicationsHelper
  include PlansHelper
  include System::UrlHelpers.system_url_helpers

  delegate :can?, to: :ability

  def initialize(provider:, service:, user:, cinstance: nil)
    @provider = provider
    @service = service
    @cinstance = cinstance
    @ability = Ability.new(user)
  end

  attr_reader :provider, :service, :cinstance, :ability

  def new_application_form_data
    data = {
      'create-application-path': admin_service_applications_path(service),
      product: ServiceDecorator.new(service).new_application_data.to_json,
      'most-recently-created-buyers': most_recently_created_buyers(provider).to_json,
      'buyers-count': raw_buyers.size,
    }
    data.merge new_application_form_base_data(provider, cinstance)
  end

  protected

  def current_account
    provider
  end
end

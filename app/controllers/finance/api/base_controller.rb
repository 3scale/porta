class Finance::Api::BaseController < Admin::Api::BaseController
  self.access_token_scopes = %i[finance account_management]

  include Finance::ControllerRequirements

  self.default_per_page = 20

  before_action :finance_module_required
  before_action :authorize_finance
  before_action :set_api_version

  after_action :report_traffic

  private

  def metric_to_report
    :billing
  end

  # TODO: Extract to rack-rest_api_versioning gem
  def set_api_version
    unless Finance::Builder::XmlMarkup.supports_version?(api_version)
      render :plain => "Unsupported Finance API version #{api_version}", status: :unsupported_media_type
    end
  end

  def api_version
    '1.0'.freeze
  end
end

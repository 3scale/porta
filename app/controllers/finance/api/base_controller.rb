class Finance::Api::BaseController < Admin::Api::BaseController
  self.access_token_scopes = %i[finance account_management]

  include Finance::ControllerRequirements

  self.default_per_page = 20

  before_action :finance_module_required
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

  # This should be defined in Admin::Api::BaseController, but for some reason swagger does not reach it there, so leaving it here
  ##~ @parameter_account_id_by_id_name = {:name => "account_id", :description => "ID of the account.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "account_ids"}
end

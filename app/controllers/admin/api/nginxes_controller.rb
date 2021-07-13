class Admin::Api::NginxesController < Admin::Api::BaseController

  before_action :disable_on_premises

  def spec
    spec = apicast_source.attributes_for_proxy

    respond_to do |format|
      format.json { render json: spec }
    end
  end

  protected

  def disable_on_premises
    raise ActiveRecord::RecordNotFound if current_account.provider_can_use?(:apicast_v2) && ThreeScale.config.apicast_custom_url
  end

  def apicast_source
    Apicast::ProviderSource.new(current_account)
  end

end

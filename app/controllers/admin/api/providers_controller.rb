class Admin::Api::ProvidersController < Admin::Api::BaseController

  wrap_parameters Account

  representer ::Account

  # Provider Account Read
  # GET /admin/api/provider.xml
  def show
    respond_with current_account
  end

  # Provider Account Update
  # PUT /admin/api/provider.xml
  def update
    current_account.update(provider_params, without_protection: true)
    respond_with current_account
  end

  protected

  def provider_params
    params.required(:account).permit(:from_email, :support_email, :finance_support_email, :site_access_code)
  end
end

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
    current_account.update(provider_params)
    respond_with current_account
  end

  protected

  def provider_params
    permitted = %i[from_email support_email site_access_code]
    permitted << :finance_support_email if current_account.settings.finance.allowed?
    params.required(:account).permit(permitted)
  end
end

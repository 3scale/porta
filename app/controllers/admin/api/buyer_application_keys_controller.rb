class Admin::Api::BuyerApplicationKeysController < Admin::Api::BuyersBaseController

  # Application Key List
  # GET /admin/api/accounts/{account_id}/applications/{application_id}/keys.xml
  def index
    respond_with(application_keys, representer: ApplicationKeysRepresenter)
  end

  # Application Key Create
  # POST /admin/api/accounts/{account_id}/applications/{application_id}/keys.xml
  def create
    key = application_keys.add(params[:key])

    respond_with(key, serialize: application)
  end

  # Application Key Delete
  # DELETE /admin/api/accounts/{account_id}/applications/{application_id}/keys/{key}.xml
  def destroy
    key = application_keys.remove!(params[:key] || params[:id])

    respond_with(key, serialize: application)
  end

  protected

  def application
    @application ||= accessible_bought_cinstances.find(params[:application_id])
  end

  def application_keys
    @application_keys ||= application.application_keys
  end

end

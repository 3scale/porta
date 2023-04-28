class Admin::Api::BuyerApplicationReferrerFiltersController < Admin::Api::BuyersBaseController

  # Application Referrer Filter List
  # GET /admin/api/accounts/{account_id}/applications/{application_id}/referrer_filters.xml
  def index
    respond_with(referrer_filters, representer: ReferrerFiltersRepresenter)
  end

   # Application Referrer Filter Create
   # POST /admin/api/accounts/{account_id}/applications/{application_id}/referrer_filters.xml
  def create
    referrer_filter = referrer_filters.add(params[:referrer_filter])
    respond_with(referrer_filter, serialize: application)
  end

   # Application Referrer Filter Delete
   # DELETE /admin/api/accounts/{account_id}/applications/{application_id}/referrer_filters/{id}.xml
  def destroy
    referrer_filter.destroy
    respond_with(referrer_filter, serialize: application)
  end

  protected

  def application
    @application ||= accessible_bought_cinstances.find(params[:application_id])
  end

  def referrer_filters
    @referrer_filters ||= application.referrer_filters
  end

  def referrer_filter
    @referrer_filter ||= referrer_filters.find(params[:id])
  end
end

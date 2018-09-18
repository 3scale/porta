class Api::AlertsController < FrontendController
  activate_menu :monitoring, :analytics

  include SearchSupport
  include ThreeScale::Search::Helpers

  before_action :find_service

  def index
    @search = ThreeScale::Search.new(search_params)
    @account_search = ThreeScale::Search.new(@search.account)

    if @account_search.present?
      # threescale/search would remove all blank entries (including empty array)
      # so to prevent that, pass -1 as id (which never exists) to return no results
      @search.account_id = current_account.buyers.scope_search(@account_search).pluck(:id).presence || -1
    end

    @alerts = collection
        .order_by(params[:sort], params[:direction])
        .scope_search(@search).paginate(page: params[:page])
  end

  def all_read
    @alerts = collection.unread
    @alerts.update_all :state => 'read'

    respond_to do |format|
      format.html { redirect_to url_for(:action => :index) }
      format.js
    end
  end

  def purge
    @alerts = collection

    @alerts.update_all :state => 'deleted'

    respond_to do |format|
      format.html { redirect_to url_for(:action => :index) }
      format.js
    end
  end

  def read
    @alert = resource

    @alert.read!

    respond_to do |format|
      format.html { redirect_to url_for(:action => :index) }
      format.js
    end
  end

  def destroy
    @alert = resource

    @alert.delete!

    respond_to do |format|
      format.html { redirect_to url_for(:action => :index) }
      format.js
    end
  end

  def sublayout
    :stats if @service
  end

  private

  def search_params
    # default to account_id and cinstance_id params if no search hash is passed
    params.fetch(:search) { params.slice(:account_id, :cinstance_id) }
  end

  def find_service
    if params[:service_id].present?
      @service = current_user.accessible_services.find(params[:service_id])

      authorize! :show, @service
    end
  end

  def collection
    current_account.buyer_alerts
        .by_service(@service).not_deleted
        .with_associations
  end

  def resource
    collection.find(params[:id])
  end
end

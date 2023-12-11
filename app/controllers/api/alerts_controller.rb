# frozen_string_literal: true

class Api::AlertsController < FrontendController
  activate_menu :serviceadmin, :monitoring, :alerts

  include SearchSupport
  include ThreeScale::Search::Helpers

  before_action :find_service

  helper_method :presenter

  attr_reader :presenter

  def index
    activate_menu :audience, :applications, :alerts unless @service

    @presenter = Api::AlertsIndexPresenter.new(raw_alerts: collection,
                                               params: params,
                                               service: @service,
                                               current_account: current_account)
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

  private

  def find_service
    if params[:service_id].present?
      @service = current_user.accessible_services.find(params[:service_id])

      authorize! :show, @service
    end
  end

  def collection
    current_account.buyer_alerts
                   .by_service(@service)
                   .not_deleted
                   .with_associations
  end

  def resource
    collection.find(params[:id])
  end
end

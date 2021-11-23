# frozen_string_literal: true

class Stats::Api::ServicesController < Stats::Api::BaseController
  before_action :set_source

  def top_applications
    options = permit_and_use_defaults(params, :metric_name, :period, :since, :timezone)

    begin
      @data = @source.top_clients(options)
    rescue Stats::InvalidParameterError => e
      render_error e.to_s, :status => :bad_request
    else

      respond_to do |format|
        format.json {render :json => @data}
        format.xml { render :layout => false}
        format.csv  do
          send_data(*Stats::Views::Csv::TopApplications.new(@data).to_send_data)
        end
      end
    end
  end

  def summary
    super
  end

  private

  def set_source
    begin
      services = (current_user || current_account).accessible_services
      @service = services.find(params.require(:service_id))
      @source  = Stats::Service.new(@service)

      authorize!(:show, @service) if current_user

    rescue ActiveRecord::RecordNotFound
      render_error "Service not found", :status => :not_found
    end
  end
end

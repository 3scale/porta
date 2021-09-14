# frozen_string_literal: true

class Stats::Api::BaseController < ApplicationController
  include SiteAccountSupport
  include ErrorHandling::Handlers


  before_action :login_required

  after_action :report_traffic, :if => :api_request?

  def usage
    #TODO: metrics can be hidden for buyers, this can be exploited
    render_usage(:metric_name)
  end

  def usage_response_code
    render_usage(:response_code)
  end

  def summary
    methods = @service.metrics.where(system_name: 'hits').first.children
    if current_account.buyer?
      plan    = @source.source.last.plan
      methods = methods.select do |method|
        method.enabled_for_plan?(plan) && method.visible_in_plan?(plan)
      end
    end

    respond_to do |format|
      format.json { render json: methods.to_json }
      format.xml { render xml: methods.to_xml }
    end
  end

  private

  def render_usage(parameter)
    options = slice_and_use_defaults(usage_params(parameter), parameter,
                                     :period, :since, :timezone, :granularity, :until, :skip_change)
    @data = @source.usage(options)

    respond_to do |format|
      format.json { render :json => @data.to_json }
      format.xml  { render :layout => false, :file => '/stats/data/usage/usage' }
      format.csv  do
        send_data(*Stats::Views::Csv::Usage.new(@data).to_send_data)
      end
    end
  rescue Stats::InvalidParameterError => e
    render_error e.to_s, :status => :bad_request
  end

  def usage_params(required_parameter)
    params.require(required_parameter)
    permitted_params = params.permit(*%i[metric_name granularity period since until skip_change timezone application_id backend_api_id service_id response_code])
    permitted_params.require([:granularity, :since]) if permitted_params[:period].blank?
    permitted_params
  end

  # Slices supplied params to allowed set, using defaults
  # when some neccessary are missing (like timezone)
  #
  def slice_and_use_defaults(params, *allowed)
    options = params.slice(*allowed)

    options[:skip_change] = (options[:skip_change] == 'false') ? false : true

    unless options[:timezone]
      options[:timezone] = current_account ? current_account.timezone : 'UTC'
    end

    options
  end

  def api_request?
    params[:provider_key].present?
  end

  def metric_to_report
    :analytics
  end

end

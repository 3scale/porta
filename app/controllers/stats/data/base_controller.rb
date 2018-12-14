class Stats::Data::BaseController < ApplicationController
  include SiteAccountSupport
  include ApiAuthentication::SuspendedAccount
  include ApiAuthentication::ByAccessToken
  include ApiAuthentication::ByProviderKey
  include ErrorHandling::Handlers
  include ApiSupport::PrepareResponseRepresenter

  self.access_token_scopes = :stats

  before_action :login_required

  after_action :report_traffic, :if => :api_request?
  ##~ sapi = source2swagger.namespace("Analytics API")
  #
  ##~ @base_path = ""
  #
  ##~ sapi.basePath     = @base_path
  ##~ sapi.swaggerVersion = "0.1a"
  ##~ sapi.apiVersion   = "1.0"
  ##
  ##~ @parameter_format = { :description => "Response format.", "name" => "format", :dataType => "string", :defaultValue => "json", :required => true, :paramType => "path", :allowableValues => { :values => ["json", "xml"], :valueType => "LIST" }}
  ##
  ##~ @parameter_access_token = { :name => "access_token", :description => "A personal Access Token", :dataType => "string", :required => true, :paramType => "query", :threescale_name => "access_token" }
  ##
  ##~ @parameter_service_id = {:name => "service_id", :description => "ID of the service.", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "service_ids"}
  ##
  ##~ @parameter_application_id = { :name => "application_id", :description => "ID of the application", :dataType => "int", :required => true, :paramType => "path", :threescale_name => "application_ids"}
  ##
  ##~ @parameter_since = {:name => "since", :description => "Time range start. Format YYYY-MM-DD HH:MM:SS, '2012-02-22', '2012-02-22 23:49:00'.", :dataType => "string", :required => true, :paramType => "query" }
  ##
  ##~ @parameter_until = {:name => "until", :description => "Time range end. Format YYYY-MM-DD HH:MM:SS", :dataType => "string", :required => false, :paramType => "query" }
  ##
  ##~ @parameter_period = {:name => "period", :description => "Period combined with since time gives stats for the time range [since .. since + period]. It is required if until time is not passed.", :dataType => "string", :required => false, :paramType => "query", :defaultValue => "", :allowableValues => {:values => ["year", "month","week","day"], :valueType => "LIST" }}
  ##
  ##~ @parameter_granularity = {:name => "granularity", :description => "Granularity of results, each period has an associated granularity.", :dataType => "string", :required => true, :paramType => "query",  :defaultValue => "month", :allowableValues => {:values => ["month","day","hour"], :valueType => "LIST" }}
  ##
  ##~ @parameter_metric_name = {:description => "System name of metric to get data for.", :name => "metric_name", :dataType => "string", :defaultValue => "hits", :required => true, :paramType => "query", :threescale_name => "metric_names" }
  ##
  ##~ @parameter_timezone = {:description => "Time zone for calculations.", :name => "timezone", :dataType => "string", :defaultValue => "UTC", :required => false, :paramType => "query", :allowableValues => {:values => ["International Date Line West", "Midway Island", "American Samoa", "Hawaii", "Alaska", "Pacific Time (US & Canada)", "Tijuana", "Mountain Time (US & Canada)", "Arizona", "Chihuahua", "Mazatlan", "Central Time (US & Canada)", "Saskatchewan", "Guadalajara", "Mexico City", "Monterrey", "Central America", "Eastern Time (US & Canada)", "Indiana (East)", "Bogota", "Lima", "Quito", "Atlantic Time (Canada)", "Caracas", "La Paz", "Santiago", "Newfoundland", "Brasilia", "Buenos Aires", "Georgetown", "Greenland", "Mid-Atlantic", "Azores", "Cape Verde Is.", "Dublin", "Edinburgh", "Lisbon", "London", "Casablanca", "Monrovia", "UTC", "Belgrade", "Bratislava", "Budapest", "Ljubljana", "Prague", "Sarajevo", "Skopje", "Warsaw", "Zagreb", "Brussels", "Copenhagen", "Madrid", "Paris", "Amsterdam", "Berlin", "Bern", "Rome", "Stockholm", "Vienna", "West Central Africa", "Bucharest", "Cairo", "Helsinki", "Kyiv", "Riga", "Sofia", "Tallinn", "Vilnius", "Athens", "Istanbul", "Minsk", "Jerusalem", "Harare", "Pretoria", "Moscow", "St. Petersburg", "Volgograd", "Kuwait", "Riyadh", "Nairobi", "Baghdad", "Tehran", "Abu Dhabi", "Muscat", "Baku", "Tbilisi", "Yerevan", "Kabul", "Ekaterinburg", "Islamabad", "Karachi", "Tashkent", "Chennai", "Kolkata", "Mumbai", "New Delhi", "Kathmandu", "Astana", "Dhaka", "Sri Jayawardenepura", "Almaty", "Novosibirsk", "Rangoon", "Bangkok", "Hanoi", "Jakarta", "Krasnoyarsk", "Beijing", "Chongqing", "Hong Kong", "Urumqi", "Kuala Lumpur", "Singapore", "Taipei", "Perth", "Irkutsk", "Ulaan Bataar", "Seoul", "Osaka", "Sapporo", "Tokyo", "Yakutsk", "Darwin", "Adelaide", "Canberra", "Melbourne", "Sydney", "Brisbane", "Hobart", "Vladivostok", "Guam", "Port Moresby", "Magadan", "Solomon Is.", "New Caledonia", "Fiji", "Kamchatka", "Marshall Is.", "Auckland", "Wellington", "Nuku'alofa", "Tokelau Is.", "Samoa"], :valueType => "LIST"}}
  ##
  ##~ @parameter_skip_change = {:description => "Skip period over period calculations (defaults to true).", :name => "skip_change", :dataType => "boolean", :allowMultiple => "false", :defaultValue => "true", :required => false, :paramType => "query"}

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
    options = slice_and_use_defaults(params, parameter,
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

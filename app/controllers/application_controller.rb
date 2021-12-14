class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  include AccessControl
  include InheritedResources::DSL
  include LayoutlessAjaxRendering
  # include DomainSupport
  include ErrorHandling

  include ThreeScale::Analytics::SessionStoredAnalytics::Helper
  include ThreeScale::OnPremises
  include ProxyConfigAffectingChanges::ControllerExtension

  _helpers.module_eval { prepend DecoratorAdditions }

  protect_from_forgery with: :reset_session # See ActionController::RequestForgeryProtection for details

  # Disable CSRF protection for requests to REST API.
  skip_before_action :verify_authenticity_token, if: -> do
    api_controller? && (params.key?(:provider_key) || params.key?(:access_token))
  end

  before_action :set_timezone

  before_action :enable_analytics
  before_action :check_browser

  def status
    begin
      redis = System.redis.ping == 'PONG'
    rescue ::Redis::BaseError => e
      redis_error = e.class.to_s + ': ' + e.message
      redis = false
    end
    database = ActiveRecord::Base.connection.active?
    status = database && redis
    render json: {status: status, redis_connection: redis, redis_error: redis_error, mysql_connection: database}.as_json

  end

  helper :all
  public :render_to_string

  # Respond with 404 also to these exceptions.
  # TODO: RAILS 3 - uncomment this and put it somewhere else (but :with expects method)
  #
  # rescue_from ActionController::MethodNotAllowed, :with => :not_found
  # rescue_from WillPaginate::InvalidPage, :with => :not_found
  # rescue_from ArgumentError, :with => :bad_request

  rescue_from Backend::ProviderKeyInvalid do
    render_error 'provider_key is invalid', :status => :forbidden
  end

  rescue_from(ActionController::ParameterMissing) do |parameter_missing_exception|
    render :plain => "Required parameter missing: #{parameter_missing_exception.param}", status: :bad_request
  end

  rescue_from ActionController::UnknownFormat do
    render_error translate(:unknown_format, scope: :'action_controller.errors', request_format: request.params[:format]),
                 status: :not_acceptable
  end


  # Returns sublayout or nil - see the class level setter.
  #
  helper_method :sublayout

  def redirect_back_or_to(fallback_location)
    redirect_back(fallback_location: fallback_location)
  end

  def sublayout
    sublayout = self.class._sublayout

    if sublayout.is_a?(Hash)
      action = action_name.to_sym
      sublayout[action]
    else
      sublayout
    end
  end

  protected

  def check_browser
    request_format = request.format
    return if request_format.xml? || request_format.json?

    if current_user && browser_not_modern?
      logout_killing_session!

      flash.now[:error] = "The browser you are using doesn't seem to support the X-Frame-Options header. That means we can't protect you against Cross Frame Scripting and thus not guarantee the security of your session. Please upgrade your browser and sign in again."
      redirect_to provider_admin_path
    end
  end

  def browser_not_modern?
    browser = Browser.new(request.env['HTTP_USER_AGENT'])
    browser.known? && !modern_browser?(browser)
  end

  def cors
    headers['Access-Control-Allow-Origin'.freeze] =
        request.headers['3scale-Origin'] || request.headers['origin'] || ''
    headers['Access-Control-Allow-Methods'.freeze] = 'GET, POST'.freeze
    headers['Access-Control-Allow-Headers'.freeze] =
        %w{Origin Accept Cookie Content-Type X-Requested-With
           X-CSRF-Token 3scale-Origin}.join(', ')
    headers['Access-Control-Allow-Credentials'] = 'true'
    head(:ok) if (request.method == 'OPTIONS')
  end

  # This before filter enables AnalyticsJsHelper#analytics block to yield
  # which is then used in provider/_analytics.html.erb to load Analytics.js

  def enable_analytics
    @_analytics_enabled = true
  end

  def set_timezone
    if current_account && (current_account.provider? || current_account.master?)
      Time.zone = current_account.timezone if current_account
    elsif current_account
      Time.zone = current_account.provider_account.timezone
    else
      Time.zone = Time.zone_default
    end
  end

  def report_traffic
    ReportTrafficWorker.enqueue(current_account, metric_to_report, request, response)
  end

  def api_controller?
    false
  end

  private

  delegate :notify_about, :silent_about, :to => :NotificationCenter

  # This causes the view to be wrapped yet into one more layout.
  # Used only in 'provider' layout.
  #
  #  _ Layout ______________
  # |                       |
  # |   _ Sublayout __      |
  # |  |              |     |
  # |  |     View     |     |
  # |  |______________|     |
  # |                       |
  # |_______________________|
  #
  # Example
  #
  #   sublayout 'api/service', :only => [ :edit ]
  #
  class_attribute :_sublayout, :instance_writer => false, :instance_reader => false

  def self.sublayout(name, opts = {})
    if opts[:only]
      sublayout = {}
      opts[:only].each { |action| sublayout[action] = name }

      self._sublayout = sublayout
    else
      self._sublayout = name
    end
  end

  def semi_verify_authenticity_token
    verify_authenticity_token unless params[:provider_key]
  end

  # Render error in whatever* format requested.
  #
  # == Arguments
  #
  # +error+::   error description string
  # +options+:: additional options to +render+ method (especially the :status)
  #
  # *) Currently TEXT, JSON and XML.
  def render_error(error, options = {})
    options = options.dup

    respond_to do |format|
      format.text { options[:plain] = error }
      format.json { options[:json] = {:error => error} }

      format.xml do
        options[:layout] = false
        options[:xml] = ThreeScale::XML::Builder.new{ |xml| xml.error error }.to_xml
      end

      format.any do
        headers['Content-Type'] = 'text/plain'
        options[:plain] = error
      end
    end

    render options

    # to cut the action processing if this is used as a last
    # call of a before_action
    false
  end

  def safe_return_to(url)
    unless url.blank?
      parsed = URI.parse(url)
      res = parsed.path
      if parsed.query
        res << "?#{parsed.query}"
      end
      res
    end
  end

  def modern_browser?(browser)
    mainstream_modern_browsers?(browser) || other_modern_browsers?(browser)
  end

  def mainstream_modern_browsers?(browser)
    browser.webkit? ||
      browser.firefox?('>= 18') ||
      browser.opera?('>= 12')
  end

  def other_modern_browsers?(browser)
    (browser.firefox? && browser.device.tablet? && browser.platform.android?('>= 14')) ||
      (!browser.compatibility_view? && (browser.ie?('>= 9') || browser.edge?))
  end
end

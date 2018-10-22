class ApplicationController < ActionController::Base
  if ThreeScale::DevDomain.enabled?
    include ThreeScale::DevDomain
  end

  include AuthenticatedSystem
  include AccessControl
  include InheritedResources::DSL
  include LayoutlessAjaxRendering
  # include DomainSupport
  include ErrorHandling

  include ThreeScale::Analytics::SessionStoredAnalytics::Helper
  include ThreeScale::OnPremises

  before_action :set_newrelic_custom_params

  protect_from_forgery with: :reset_session # See ActionController::RequestForgeryProtection for details
  ensure_security_headers

  # Disable CSRF protection for non xml requests.
  skip_before_action :verify_authenticity_token, if: -> do
    (params.key?(:provider_key) || params.key?(:access_token)) && request.format.xml?
  end

  before_action :set_timezone

  before_action :report_google_experiments, if: proc { ThreeScale::Analytics::GoogleExperiments.enabled? }
  before_action :enable_analytics

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

  def redirect_back_or_to(*fallback_params)
    redirect_to :back
  rescue ActionController::RedirectBackError
    redirect_to(*fallback_params)
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

  # TODO -> move it to a concern/module
  def breadcrumb_object
  end
  helper_method :breadcrumb_object

  def breadcrumb_show_object_action
    :show
  end
  helper_method :breadcrumb_show_object_action

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

  def report_google_experiments
    analytics_session.identify(google_experiments)
    Rails.logger.debug { "Google Experiments: #{google_experiments}" }
  rescue => error
    System::ErrorReporting.report_error(error)
  end

  def google_experiments
    return unless ThreeScale::Analytics::GoogleExperiments.enabled?

    @__google_experiments ||= begin
      utmx = cookies[:__utmx] || cookies[:__utmxx]
      Rails.logger.debug {  "Google Experiment Cookie: #{utmx}" }
      ThreeScale::Analytics::GoogleExperiments.from_cookie(utmx).to_hash
    end
  end

  # This before filter enables AnalyticsJsHelper#analytics block to yield
  # which is then used in provider/_analytics.html.erb to load Analytics.js
  # it can be disabled per action like for ::Provider::SignupsController#testab.

  def enable_analytics
    @_analytics_enabled = true
  end

  def set_newrelic_custom_params
    if defined? ::NewRelic
      ::NewRelic::Agent.add_custom_attributes(:host => request.host,
                                              :user_agent => request.user_agent )

      if (user = current_user) && (account = current_account)
        ::NewRelic::Agent.add_custom_attributes(user_id: user.id, user: user.email,
                                                account: account.org_name, account_id: account.id)
      end
    end
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

  class CustomCanCanControllerResource < CanCan::ControllerResource

    def authorization_action
      action = @params[:action].to_sym

      if @controller.request.get? && !%i(index edit).include?(action)
        :show
      else
        super
      end
    end
  end

  # CanCanCan
  # [default] custom controller [GET] methods are being authorized separately
  # [custom] custom controller [GET] methods are being authorized as show method
  def self.cancan_resource_class
    if ancestors.map(&:to_s).include? 'InheritedResources::Actions'
      CanCan::InheritedResource
    else
      CustomCanCanControllerResource
    end
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
      format.text { options[:text] = error }
      format.json { options[:json] = {:error => error} }

      format.xml do
        options[:layout] = false
        options[:xml] = ThreeScale::XML::Builder.new{ |xml| xml.error error }.to_xml
      end

      format.any do
        headers['Content-Type'] = 'text/plain'
        options[:text] = error
      end
    end

    render options

    # to cut the action processing if this is used as a last
    # call of a before_action
    false
  end

  def target_host(provider)
    return target_host_preview(provider) if Rails.env.preview?

    dev_domain = ThreeScale.config.dev_gtld
    if request.host.ends_with?(".#{dev_domain}")
      "#{provider.admin_domain}.#{dev_domain}:#{request.port}"
    else
      provider.admin_domain
    end
  end

  def target_host_preview(provider)
    preview = request_target_host.match(/(preview\d+)/).try(:[], 0)
    provider.admin_domain.sub(/\.3scale\.net\z/, ".#{preview}.#{ThreeScale.config.superdomain}")
  end

  def request_target_host
    x_forwarded_for_domain = request.headers['X-Forwarded-For-Domain']
    if Rails.env.preview? && x_forwarded_for_domain
      request.host_with_port.sub(request.host, x_forwarded_for_domain)
    else
      request.host_with_port
    end
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
end

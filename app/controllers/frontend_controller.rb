# frozen_string_literal: true

class FrontendController < ApplicationController
  SecureHeaders::Configuration.override(:disable_x_frame) do |config|
    config.x_frame_options = SecureHeaders::OPT_OUT
  end

  SecureHeaders::Configuration.override(:disable_x_content_type) do |config|
    config.x_content_type_options = SecureHeaders::OPT_OUT
  end

  include SiteAccountSupport
  include AccessCodeProtection

  include MenuSystem
  include ThreeScale::Api::Controller
  extend ::Filters::ProviderRequired

  # those modules are inter-dependent
  include Liquid::TemplateSupport
  include Liquid::Assigns
  include CMS::Toolbar
  include CMS::BuiltinPagesSupport

  include ThreeScale::Warnings::ControllerExtension
  include Logic::RollingUpdates::Controller

  # TODO: this should go to Provider::BaseController when one such will exist
  activate_menu :topmenu => :dashboard

  before_action :login_required
  before_action :set_display_currency

  include RedhatCustomerPortalSupport::ControllerMethods::Banner

  before_action :protect_suspended_account, if: :provider_suspended?

  layout :pick_buyer_or_provider_layout

  private

  def disable_x_content_type
    use_secure_headers_override(:disable_x_content_type)
  end

  def disable_x_frame
    use_secure_headers_override(:disable_x_frame)
  end

  def do_nothing_if_head
    render head: :success, nothing: true if request.head?
  end

  def protect_suspended_account
    redirect_to provider_admin_account_path
  end

  def provider_suspended?
    current_account.try!(:suspended?) && current_account.try!(:provider?)
  end

  def with_password_confirmation!
    if session_is_secure?
      yield
    else
      ask_for_secure_session!
    end
  end

  def session_is_secure?
    # enabled just for master for now
    if current_account.master?
      sudo.secure?
    else
      true
    end
  end

  helper_method :sudo

  def sudo
    return_path = request.xhr? ? request.fullpath : request.headers.fetch('Referer') { request.fullpath }
    Sudo.new(return_path: return_path, user_session: user_session, xhr: request.xhr?)
  end

  def ask_for_secure_session!
    respond_to do |format|
      format.html { render 'provider/admin/sudo/show' }
    end
  end

  def done_step(step, final_step = false)
    go_live_state = current_account.go_live_state

    if go_live_state.can_advance_to?(step)
      go_live_state.advance(step, final_step=final_step)
      ThreeScale::Analytics.track(current_account.users.first, "golive:#{step}")

      if request.xhr?
        flash.now[:notice] = I18n.t(step, scope: :go_live_states)
      else
        flash[:notice] = I18n.t(step, scope: :go_live_states)
      end
      return true
    end
  end

  def cms
    @_cms ||= CMS::Settings.new(site_account.settings, session)
  end

  def analytics
    @_analytics ||= ThreeScale::Analytics.user_tracking(current_user)
  end

  # TODO: When there are no controllers that handle Buyer and Provider side
  # together, this can be removed. Those are so far:
  #
  # Forums* controllers (?)
  #
  def pick_buyer_or_provider_layout
    if site_account.master?
      current_account ? 'provider' : 'provider/login'
    else
      DEFAULT_LIQUID_LAYOUT
    end
  end

  def accessible_services
    return site_account.accessible_services unless current_account.try!(:provider?)
    current_account.accessible_services.merge(Service.permitted_for(current_user))
  end

  def find_service(id = params[:service_id])
    @service = id.present? ? accessible_services.find(id) : accessible_services.default
  end

  def ensure_provider
    return if current_account.provider?
    render_error 'Not authorized', :status => :not_authorized
    false
  end

  def ensure_provider_domain
    return if Account.is_admin_domain?(internal_host) || site_account.master?
    notify_about_wrong_domain(request.url, :provider, error_request_data)
    render_wrong_domain_error
    false
  end

  def ensure_buyer_domain
    return unless Account.is_admin_domain?(internal_host) || site_account.master?
    notify_about_wrong_domain(request.url, :buyer)
    render_wrong_domain_error
  end

  def ensure_master_domain
    return if Account.is_master_domain?(internal_host)
    notify_about_wrong_domain(request.url, :master)
    render_wrong_domain_error
    false
  end

  def render_wrong_domain_error
    render_error "The path '#{request.path}' is not accessible on domain #{request.host}", :status => :not_found
  end

  def set_display_currency
    ThreeScale::MoneyHelper.display_currency = current_account.currency if current_account
  end
end

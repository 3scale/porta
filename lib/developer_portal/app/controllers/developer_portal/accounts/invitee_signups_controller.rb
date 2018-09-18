class DeveloperPortal::Accounts::InviteeSignupsController < DeveloperPortal::BaseController
  skip_before_action :login_required

  before_action :redirect_if_logged_in
  before_action :find_invitation
  before_action :check_invitation!
  before_action :build_user

  liquify prefix: 'accounts/invitee_signups'.freeze

  def show
    build_sso_authorization

    assign_drops user: @user
  end

  def sso_create
    strategy = Authentication::Strategy.build(site_account)
    signup_user = strategy.authenticate(
      params.merge({
                     request:    request,
                     invitation: @invitation
                   }),
      procedure: Authentication::Strategy::Oauth2::CreateInvitedUser
    )

    if signup_user
      user_created_webhook(signup_user)
      self.current_user = signup_user
      create_user_session!

      flash[:notice] = 'Signed up successfully'.freeze
      redirect_to strategy.redirect_to_on_successful_login
    else
      user_data = strategy.user_data || {}
      @user.assign_attributes(user_data.to_hash.compact)
      session[:invitation_sso_uid] = user_data[:uid]
      session[:invitation_sso_system_name] = strategy.authentication_provider.system_name
      build_sso_authorization
      @user.valid?

      flash[:error] = user_data.try(:error)
      render_show
    end
  end

  def create
    build_sso_authorization

    if @user.save
      # we are activating users directly on signup so no activation email
      @user.activate!
      session.delete(:invitation_sso_uid)
      session.delete(:invitation_sso_system_name)
      user_created_webhook(@user)

      flash[:notice] = t('flash.signups.create.notice')
      redirect_to(login_url)
    else
      render_show
    end
  end

  private

  def sso_attributes_provided?
    sso_attributes.all? { |_key, value| value.present? }
  end

  def create_sso_authorization
    return unless sso_attributes_provided?
    build_sso_authorization
    @user.save
  end

  def authentication_provider
    site_account.authentication_providers
      .find_by(system_name: session[:invitation_sso_system_name])
  end

  def sso_attributes
    {
      uid: session[:invitation_sso_uid].presence,
      authentication_provider: authentication_provider
    }
  end

  def build_sso_authorization
    return unless sso_attributes_provided?

    @user.sso_authorizations.new(sso_attributes)
  end

  def render_show
    assign_drops user: @user
    render action: 'show'
  end

  def user_created_webhook(webhook_user)
    webhook_user.web_hook_event!(event: 'created'.freeze)
  end

  def redirect_if_logged_in
    redirect_to admin_dashboard_path if logged_in?
  end

  def find_invitation
    @invitation = site_account.buyer_invitations.find_by(token: invitation_token)
  end

  def check_invitation!
    if @invitation.blank? || @invitation.try(:accepted?)

      message_key   = @invitation.blank? ? 'not_found' : 'already_accepted'
      flash[:error] = t("errors.messages.invitation_#{message_key}")

      redirect_to(login_path)
    end
  end

  def build_user
    @user = @invitation.make_user(params[:user] || {})
  end

  def invitation_token
    params[:state].presence || params[:invitation_token]
  end
end

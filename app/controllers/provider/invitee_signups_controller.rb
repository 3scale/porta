class Provider::InviteeSignupsController < FrontendController
  skip_before_action :login_required

  before_action :redirect_if_logged_in
  before_action :ask_for_upgrade

  before_action :find_invitation
  before_action :build_user
  before_action :instantiate_sessions_presenter

  layout 'provider/login'

  def show
  end

  def create
    @user.admin_sections = domain_account.provider_can_use?(:service_permissions) ? [] : ['monitoring']

    if can_create? && @user.save
      # TODO: move this logic over to the model layer.
      # We are activating users directly on signup so no activation email
      @user.activate!

      redirect_to provider_login_path, success: t('.success')
    else
      errors = @user.errors.full_messages.reduce do |result, error|
        "#{result}\n#{error}"
      end

      flash.now[:danger] = t('.error', errors: errors)
      render 'show'
    end
  end

  private

  def ask_for_upgrade
    @presenter = Provider::SessionsPresenter.new(domain_account)
    render 'ask_for_upgrade' unless can_create?
  end

  def redirect_if_logged_in
    redirect_to provider_admin_dashboard_url, info: t('.already_logged_in') if logged_in?
  end

  def find_invitation
    @invitation = domain_account.invitations.pending.find_by_token!(invitation_token)
  end

  def can_create?
    account = domain_account
    account.provider_constraints.can_create_user?
  end

  def build_user
    @user = @invitation.make_user(params[:user] || {})

    # This is just a sanity guard added when splitting invitation
    # controllers. Remove when SURE.
    raise 'Developer invitation used and worked on provider side!' unless @user.account.provider?
  end

  def invitation_token
    params.require(:invitation_token).to_s
  end

  def instantiate_sessions_presenter
    @presenter = Provider::SessionsPresenter.new(domain_account)
  end
end

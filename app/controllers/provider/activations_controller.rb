class Provider::ActivationsController < FrontendController

  skip_before_action :login_required
  before_action :do_nothing_if_head, only: [:create]

  def create
    user = domain_account.users.find_by_activation_code(activation_code)

    return redirect_to provider_login_path unless user

    user.activate!

    flash[:success] = user.account.approval_required? ? t('.approval_required') : t('.signup_complete')

    logout_keeping_session!

    user.account.create_onboarding unless user.account.onboarding.persisted?

    redirect_to provider_login_path(username: user.email)
  end


  protected

  def activation_code
    params.require(:activation_code).to_s
  end
end

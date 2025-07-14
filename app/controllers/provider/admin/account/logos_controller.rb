class Provider::Admin::Account::LogosController < Provider::Admin::Account::BaseController
  activate_menu! :audience, :cms, :logo
  before_action :authorize, only: %i[destroy update]

  def edit
    @profile = profile
  end

  def update
    update_logo(logo: params.require(:profile).require(:logo))
  end

  def destroy
    update_logo(logo: nil)
  end

  private

  def update_logo(logo:)
    if profile.update({logo: logo})
      flash[:success] = t('.success')
    else
      flash[:danger] = profile.errors.full_messages.to_sentence
    end
    redirect_to edit_provider_admin_account_logo_path
  end

  def authorize
    authorize! action_name, :logo
  end

  def profile
    current_account.profile or current_account.create_profile
  end

end

class Provider::Admin::Account::LogosController < Provider::Admin::Account::BaseController
  activate_menu :account, :logo

  def edit
    @profile = profile
  end

  def update
    authorize! :update, :logo

    redirect_to edit_provider_admin_account_logo_path and return false if params[:profile].blank?

    profile.update_attribute(:logo, params[:profile][:logo])
    @notice = 'Logo was successfully created.'

    respond_to do |format|
      format.html do
        flash[:notice] = @notice
        redirect_to edit_provider_admin_account_logo_path
      end

      format.js
    end
  end

  def destroy
    authorize! :delete, :logo

    profile.update_attribute(:logo, nil)

    flash[:notice] = 'Your logo was successfully deleted.'
    redirect_to edit_provider_admin_account_logo_path
  end

  private

  def profile
    current_account.profile or current_account.create_profile
  end

end

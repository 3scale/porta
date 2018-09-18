class Admin::UserConfirmationsController < FrontendController

  def create
    cinstance = current_account.provided_cinstances.find_by_id params[:cinstance_id]
    if cinstance.user_account.admin.active?
      flash[:notice] = "User is already confirmed."
      redirect_to admin_cinstances_path
    else
      cinstance.user_account.admin.activate!
      flash[:notice] = "User successfully confirmed and can now sign in."
      redirect_to admin_cinstances_path
    end
  end


end

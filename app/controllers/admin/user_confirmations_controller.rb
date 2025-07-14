class Admin::UserConfirmationsController < FrontendController

  def create
    cinstance = current_account.provided_cinstances.find_by_id params[:cinstance_id]
    if cinstance.user_account.admin.active?
      redirect_to admin_cinstances_path, info: t('.already_active')
    else
      cinstance.user_account.admin.activate!
      redirect_to admin_cinstances_path, success: t('.activated')
    end
  end


end

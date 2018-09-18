class Provider::Admin::Account::NotificationsController < Provider::Admin::Account::BaseController
  activate_menu :account, :notifications
  layout 'provider'

  def index
    @system_operations = SystemOperation.order(:pos)
  end

  def update
    rule = current_account.mail_dispatch_rules.find(params[:id])
    rule.update_attributes(mail_dispatch_rule_params)

    @notice = 'Settings were updated.'

    respond_to do |wants|
      wants.html do
        flash[:notice] = @notice
        redirect_to provider_admin_account_notifications_path
      end

      wants.js
    end
  end

  protected

  def mail_dispatch_rule_params
    params.require(:mail_dispatch_rule).permit(:dispatch)
  end
end

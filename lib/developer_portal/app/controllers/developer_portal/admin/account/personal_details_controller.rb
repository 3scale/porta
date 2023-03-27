class DeveloperPortal::Admin::Account::PersonalDetailsController < ::DeveloperPortal::BaseController
  inherit_resources

  activate_menu :account, :personal_details

  defaults :singleton => true, :instance_name => 'user', :route_prefix => 'admin_account'
  actions :show, :update
  before_action :ensure_buyer_domain
  before_action :deny_unless_can_update, :only => [:update, :show]

  liquify prefix: 'user'

  before_action :verify_current_password, only: :update

  def show
    assign_user_drop
  end

  def update
    resource.validate_fields!
    if resource.errors.empty? && resource.update(user_params)
      resource.kill_user_sessions(user_session) if resource.just_changed_password?

      redirect_to admin_account_users_path, notice: 'User was successfully updated.'
    else
      assign_user_drop
      render :action => 'show'
    end
  end

  private

  def assign_user_drop
    drops = { user: Liquid::Drops::User.new(resource)}
    assign_drops(drops)
  end

  def resource
    @user ||= User.find(current_user.id)
  end

  def deny_unless_can_update
    unless can?(:update, current_user)
      render :plain => 'Action disabled', :status => :forbidden
    end
  end

  def user_params
    params.require(:user).permit([:current_password] +
                                   resource.special_fields +
                                   resource.defined_fields.map(&:name))
  end

  def verify_current_password
    return unless current_user.using_password?
    return if current_user.authenticated?(user_params[:current_password])

    flash.now[:error] = 'Current password is incorrect.'
    resource.errors.add(:current_password, 'Current password is incorrect.')
  end
end

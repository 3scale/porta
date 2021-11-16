# frozen_string_literal: true

class Buyers::UsersController < Buyers::BaseController
  activate_menu :audience, :accounts, :listing

  before_action :find_account, except: :index
  before_action :find_user, except: :index

  def index
    @account = current_account.buyer_accounts.find(params[:account_id])
    @users = @account.users.order(:id).paginate(page: params[:page]).decorate
  end

  def update
    # TODO: I think this controller is used only on provider side
    user.validate_fields! if current_account.buyer?

    user.attributes = user_params
    user.role = user_params.fetch(:role, user.role) if can?(:update_role, user)

    if user.save
      flash[:notice] = 'User was successfully updated.'
      redirect_to action: :show
    else
      render :edit
    end
  end

  def show; end

  def edit; end

  def destroy
    if user.destroy
      flash[:notice] = 'User was successfully deleted.'
      redirect_to action: :index
    else
      flash[:error] = 'User could not be deleted.'
      redirect_back_or_show_detail
    end
  end

  def suspend
    user.suspend!
    flash[:notice] = 'User was suspended'

    redirect_back_or_show_detail
  end

  def unsuspend
    user.unsuspend!
    flash[:notice] = 'User was unsuspended'

    redirect_back_or_show_detail
  end

  def activate
    if user.activate
      user.account.create_onboarding

      flash[:notice] = 'User was activated'
    else
      errors = user.errors
      error_message = if errors.include?(:email)
                        I18n.t('errors.messages.duplicated_user_provider_side')
                      else
                        errors.full_messages.join(',')
      end

      flash[:error] = "Failed to activate user: #{error_message}"
    end

    redirect_back_or_show_detail
  end

  private

  attr_reader :user

  def find_account
    @account = current_account.buyer_accounts.find(params[:account_id])
  end

  def find_user
    @user = @account.users.find(params[:id]).decorate
  end

  DEFAULT_PARAMS = %i[username email password password_confirmation role].freeze

  def user_params
    @user_params ||= params.require(:user).permit(DEFAULT_PARAMS | user.defined_extra_fields_names)
  end

  def redirect_back_or_show_detail
    redirect_back(fallback_location: admin_buyers_account_user_path(account_id: user.account_id, id: user.id))
  end
end

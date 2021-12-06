class Partners::UsersController < Partners::BaseController

  before_action :find_account

  def index
    @users = @account.users.page(permitted_params[:page])
    open_id_param = permitted_params[:open_id]
    @users = @users.where(open_id: open_id_param) if open_id_param
    render json: @users
  end

  def show
    @user = @account.users.find(permitted_params[:id])
    render json: @user
  end

  def destroy
    @user = @account.users.find(permitted_params[:id])
    @user.destroy
    render json: {success: true}
  end

  def create
    @user = @account.users.build
    @user.email = permitted_params[:email]
    @user.password = SecureRandom.hex
    @user.first_name = permitted_params[:first_name].presence
    @user.last_name = permitted_params[:last_name].presence
    @user.open_id = permitted_params[:open_id].presence
    @user.username = permitted_params[:username]
    @user.signup_type = :partner
    @user.role = :admin
    @user.activate!
    if @user.save
      render json: {id: @user.id, success: true}
    else
      render json: {errors: @user.errors, success: false}
    end
  end

  private

  def find_account
    @account = @partner.providers.find(permitted_params[:provider_id])
  end

  def permitted_params
    params.permit(%i[api_key email first_name last_name open_id username provider_id id])
  end
end

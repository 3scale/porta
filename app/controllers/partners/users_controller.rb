class Partners::UsersController < Partners::BaseController

  before_action :find_account

  def index
    @users = @account.users.page(params[:page])
    @users = @users.where(open_id: params[:open_id]) if params[:open_id]
    render json: @users
  end

  def show
    @user = @account.users.find(params[:id])
    render json: @user
  end

  def destroy
    @user = @account.users.find(params[:id])
    @user.destroy
    render json: {success: true}
  end

  def create
    @user = @account.users.build
    @user.email = params[:email]
    @user.password = params[:password].presence
    @user.first_name = params[:first_name].presence
    @user.last_name = params[:last_name].presence
    @user.open_id = params[:open_id].presence
    @user.username = params[:username]
    @user.signup_type = :partner
    @user.role = :admin
    @user.activate!
    @user.save!

    render json: {id: @user.id, success: true}
  rescue StandardError
    render json: {errors: @user.errors, success: false}, status: :unprocessable_entity
  end

  private

  def find_account
    @account = @partner.providers.find(params[:provider_id])
  end
end

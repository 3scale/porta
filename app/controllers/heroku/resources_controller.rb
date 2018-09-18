class Heroku::ResourcesController < Heroku::BaseController

  before_action :authenticate
  before_action :find_user_and_account, only: [:update, :destroy]

  # provision
  def create
    create_heroku_account
    render json: {id: @user.id, config: account_data}
  end

  # changeplan: id, plan
  def update
    @account.force_to_change_plan!(selected_plan)
    render json: {id: @user.id, message: "Plan changed", config: account_data}
  end

  # deprovision: id
  def destroy
    @account.destroy
    render plain: 'ok'
  end

  private

  def account_data
  {
    "THREESCALE_PROVIDER_KEY" => @account.api_key
  }
  end

  def cinstance
    @cinstance ||= @account.first_service!.cinstances[0]
  end

  def master
    @master ||= Account.master
  end

  def authenticate
    unless authenticate_with_http_basic { |user, password| password == Heroku.password  }
      render plain: 'unauthorized', status: 401
    end
  end
end

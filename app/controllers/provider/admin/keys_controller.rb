class Provider::Admin::KeysController < Provider::Admin::BaseController

  before_action :find_cinstance
  before_action :authorize_partners
  around_action :with_password_confirmation!

  def new
  end

  def edit
  end

  # user key
  def update
    @cinstance.user_key = permitted_params[:cinstance][:user_key]
    unless @cinstance.save
      flash.now[:error] = "Invalid key. Please review and try submitting again."
    end
    respond_to(:js)
  end

  def create
    @key = @cinstance.application_keys.add(permitted_params[:key])

    if @key.persisted?
      @keys = @cinstance.application_keys.pluck_values
    else
      flash.now[:error] = "Invalid key. Please review and try submitting again."
    end

    respond_to(:js)
  end

  def destroy
    @key = permitted_params.require(:id)
    @remove = @cinstance.application_keys.remove(@key)

    unless @remove
      flash.now[:error] = 'One application key minimum is required.'
    end

    respond_to(:js)
  end

  def regenerate
    @key = permitted_params.require(:id)

    @new_key = @cinstance.application_keys.regenerate(@key).value

    respond_to(:js)
  end

  private

  def authorize_partners
    authorize! :manage, :partners
  end

  def find_cinstance
    @cinstance = current_account.provided_cinstances.find(permitted_params.require(:application_id))
  end

  def permitted_params
    params.permit(:id, :application_id, :key, cinstance: %i[user_key])
  end
end

class Provider::Admin::KeysController < Provider::Admin::BaseController

  before_action :find_cinstance
  before_action :authorize_partners
  around_action :with_password_confirmation!

  layout false

  # Show a modal window for adding a custom Application Key
  def new
  end

  # Show a modal window for setting a custom User Key
  def edit
  end

  # Set a custom User Key
  def update
    user_key = params[:cinstance][:user_key]
    if user_key.blank?
      @cinstance.errors.add(:user_key, :blank)
    else
      @cinstance.user_key = user_key
      @notice = t('.update.success') if @cinstance.save
    end
    @error = @cinstance.errors.full_messages_for(:user_key).presence
    respond_to(:js)
  end

  # Create a custom Application Key
  def create
    @key = @cinstance.application_keys.add(params[:key])

    if @key.persisted?
      @keys = @cinstance.application_keys.pluck_values
      @notice = t('.create.success')
    else
      @error = @key.errors.full_messages.presence
    end

    respond_to(:js)
  end

  def destroy
    @key = params[:id]
    @remove = @cinstance.application_keys.remove(@key)

    @flash = t(".destroy.#{@remove ? 'success' : 'error'}")

    respond_to(:js)
  end

  def regenerate
    @key = params[:id]

    @new_key = @cinstance.application_keys.regenerate(@key).value

    respond_to(:js)
  end

  private

  def authorize_partners
    authorize! :manage, :partners
  end

  def find_cinstance
    @cinstance = current_account.provided_cinstances.find(params[:application_id])
  end
end

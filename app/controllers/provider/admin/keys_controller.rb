class Provider::Admin::KeysController < Provider::Admin::BaseController

  before_action :find_cinstance
  before_action :authorize_partners
  around_action :with_password_confirmation!

  layout false

  def new
  end

  def edit
  end

  def update
    user_key = params[:cinstance][:user_key]
    if user_key.blank?
      @error = t('activerecord.errors.models.cinstance.attributes.user_key.blank')
    else
      @cinstance.user_key = user_key
      if @cinstance.save
        @notice = t('.update.success')
      else
        @error = @cinstance.errors.messages[:user_key].first
      end
    end
    respond_to(:js)
  end

  def create
    @key = @cinstance.application_keys.add(params[:key])

    if @key.persisted?
      @keys = @cinstance.application_keys.pluck_values
      @notice = t('.create.success')
    else
      error_type = @key.errors.details[:value].first[:error]
      @error = t(errot_type, scope: 'activerecord.errors.models.cinstance.keys')
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

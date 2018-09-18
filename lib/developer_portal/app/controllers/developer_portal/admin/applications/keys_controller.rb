class DeveloperPortal::Admin::Applications::KeysController < DeveloperPortal::BaseController

  before_action :find_cinstance
  before_action :authorize_keys

  # TODO: error responses

  def new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def create
    @key = @cinstance.application_keys.add(params[:key])

    respond_to do |format|
      format.html do
        flash[:notice] = 'Application key was created.'
        redirect_to(return_url)
      end

      format.js do
        if @key.persisted?
          @keys = @cinstance.application_keys.pluck_values
        else
          flash.now[:error] = "Invalid key. Please review and try submitting again."
        end
      end
    end
  end

  def destroy
    @key = params[:id]
    @remove = @cinstance.application_keys.remove(@key)
    unless @remove
      flash.now[:error] = 'One application key minimum is required.'
    end

    respond_to do |format|
      format.html do
        flash[:notice] = 'Application key was deleted.'
        redirect_to(return_url)
      end

      format.js
    end
  end

  def regenerate
    @key = params[:id]

    @new_key = @cinstance.application_keys.regenerate(@key).value

    respond_to do |format|
      format.html do
        flash[:notice] = 'Application key was regenerated.'
        redirect_to(return_url)
      end

      format.js
    end
  end

  private

  def authorize_keys
    authorize! :manage_keys, @cinstance
  end

  def find_cinstance
    @cinstance = current_account.bought_cinstances.by_service(@service).find(params[:application_id])
  end

  def return_url
    if @cinstance.service.account.multiple_applications_allowed?
      admin_application_path(@cinstance)
    else
      admin_applications_access_details_path
    end
  end

end

class Provider::Admin::WebhooksController < Sites::BaseController

  before_action :find_webhook
  before_action :authorize_web_hooks

  activate_menu! :account, :integrate, :web_hooks

  def new
    if @webhook
      redirect_to :action => :edit
    else
      @webhook = current_account.build_web_hook
      render :edit
    end
  end

  def edit
    redirect_to(:action => :new) unless @webhook
  end

  def show
    respond_to do |format|
      format.js do
        if @webhook
          @ping_response = @webhook.ping
        else
          render :status => :forbidden, :text => 'Nowhere to ping'
        end
      end
    end
  end

  def create
    @webhook ||= current_account.build_web_hook(params[:web_hook])

    if @webhook.save
      flash[:notice] = 'Webhooks settings were successfully updated.'
      redirect_to :action => :edit
    else
      render :edit
    end
  end

  def update
    if @webhook.update_attributes(params[:web_hook])
      flash[:notice] = 'Webhooks settings were successfully updated.'
      redirect_to :action => :edit
    else
      flash[:error] = 'Webhooks settings could not be updated.'
      render :edit
    end
  end

  protected

  def find_webhook
    @webhook = current_account.web_hook
  end

  def authorize_web_hooks
    authorize! :manage, :web_hooks
  end
end

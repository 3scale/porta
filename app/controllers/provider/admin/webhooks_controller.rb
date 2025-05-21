# frozen_string_literal: true

class Provider::Admin::WebhooksController < Sites::BaseController

  before_action :find_webhook
  before_action :authorize_web_hooks
  before_action :disable_client_cache

  activate_menu! :account, :integrate, :webhooks

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
      format.json do
        if @webhook
          @ping_response = @webhook.ping
          if @ping_response.respond_to?(:status)
            render json: { type: :success, message: t('.success', url: @webhook.url, status: @ping_response.status) }
          else
            render json: { type: :danger, message: t('.failed', response: @ping_response.message.to_json.html_safe) }
          end
        else
          render json: { type: :danger, message: t('.error') }
        end
      end
    end
  end

  def create
    @webhook ||= current_account.build_web_hook(params[:web_hook])

    if @webhook.save
      redirect_to({ action: :edit }, success: t('.success'))
    else
      render :edit
    end
  end

  def update
    if @webhook.update(params[:web_hook])
      redirect_to({ action: :edit }, success: t('.success'))
    else
      flash.now[:danger] = t('.error')
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

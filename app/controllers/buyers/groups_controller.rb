# frozen_string_literal: true

class Buyers::GroupsController < Buyers::BaseController
  before_action :authorize_groups
  before_action :find_account
  activate_menu :audience, :accounts, :listing

  helper_method :collection

  def show; end

  def update
    flash[:success] = t('.success') if @account.update(params[:account])

    redirect_to action: :show, id: @account.id
  end

  protected

  def collection
    @collection ||= @account.provider_account.provided_groups.includes([:sections])
  end

  def authorize_groups
    authorize! :manage, :groups
  end

  def find_account
    @account = current_account.buyer_accounts.find(params[:account_id])
  end
end

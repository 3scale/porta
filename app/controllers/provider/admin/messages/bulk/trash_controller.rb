class Provider::Admin::Messages::Bulk::TrashController < FrontendController

  ALLOWED_SCOPES = %i(messages received_messages)

  respond_to :js

  before_action :check_association_scope!

  class ForbiddenAccountScope < StandardError; end

  def new
  end

  def create
    ::Messages::DeleteService.run!({
      account:           current_account,
      association_class: association_class,
      ids:               message_ids,
      delete_all:        params[:selected_total_entries].present?
    })

    @message_ids      = message_ids
    @no_more_messages = no_more_messages

    flash[:notice] = t('.success')
  end

  private

  def message_ids
    @message_ids ||= Array(params[:selected])
  end

  def no_more_messages
    current_account.public_send(scope).visible.count.zero?
  end

  def check_association_scope!
    unless ALLOWED_SCOPES.include?(scope)
      raise ForbiddenAccountScope.new("Scope #{scope} is not allowed")
    end
  end

  def scope
    @scope ||= params[:scope].try(:to_sym)
  end

  def association_class
    current_account.public_send(scope).build.class
  end
end

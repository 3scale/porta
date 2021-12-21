# frozen_string_literal: true

class Buyers::BulkBaseController < FrontendController
  before_action :authorize_bulk_operations
  before_action :initialize_errors, only: :create

  helper_method :humanized_actions

  def new; end

  def create
    raise NoMethodError, "Please define `#create` method in #{self.class}"
  end

  protected

  attr_reader :subjects

  def humanized_actions
    @humanized_actions ||= actions.map {|a| [a.humanize, a] }
  end

  def change_states
    return unless actions.include?(action)

    collection.select { |item| item.public_send("can_#{action}?") }
              .each do |item|
                @errors << item unless item.public_send(action)
              end
  end

  def send_emails
    recipients.each do |recipient|
      message = current_account.messages.build send_email_params
      message.to = recipient

      @errors << message unless message.save && message.deliver!
    end
  end

  def delete_stuff
    collection.each do |item|
      @errors << item unless items.destroy
    end
  end

  def initialize_errors
    @errors = []
  end

  def authorize_bulk_operations
    authorize! :manage, scope
  end

  def selected_ids_param
    params.require(:selected)
  end

  def send_email_params
    params.require(:send_emails).permit(:subject, :body)
  end

  def change_state_action_param
    params.require(:change_states).require(:action)
  end

  alias action change_state_action_param

  def plan_id_param
    params.require(:change_plans).require(:plan_id)
  end
end

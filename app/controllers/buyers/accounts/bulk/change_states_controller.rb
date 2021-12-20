# frozen_string_literal: true

class Buyers::Accounts::Bulk::ChangeStatesController < Buyers::Accounts::Bulk::BaseController
  ACTIONS = %w{ approve make_pending reject }

  def new
    @actions = ACTIONS.map {|a| [a.humanize, a] }
  end

  def create
    @action = ( ACTIONS & [change_state_action_param] ).first
    return unless @action.present?

    @accounts = @accounts.to_a.reject do |account|
      !account.public_send("can_#{@action}?")
    end

    @accounts.each do |account|
      @errors << account unless account.public_send(@action)
    end

    handle_errors
  end

  private

  def change_state_action_param
    params.require(:change_states).require(:action)
  end
end

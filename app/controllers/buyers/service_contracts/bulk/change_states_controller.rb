# frozen_string_literal: true

class Buyers::ServiceContracts::Bulk::ChangeStatesController < Buyers::ServiceContracts::Bulk::BaseController
  ACTIONS = %w{ accept suspend resume }

  def new
    @actions = ACTIONS.map {|a| [a.humanize, a] }
  end

  def create
    @action = ( ACTIONS & [change_state_action_param] ).first

    return unless @action.present?

    @service_contracts = @service_contracts.to_a.reject do |contract|
      !contract.public_send("can_#{@action}?")
    end

    @service_contracts.each do |application|
      @errors << application unless application.public_send(@action)
    end

    handle_errors
  end

  private

  def change_state_action_param
    params.require(:change_states).require(:action)
  end
end

# frozen_string_literal: true

class Buyers::Applications::Bulk::ChangeStatesController < Buyers::Applications::Bulk::BaseController
  ACTIONS = %w{ accept suspend resume }

  def create
    change_states
    handle_errors
    super
  end

  private

  def actions
    ACTIONS
  end
end

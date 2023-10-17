# frozen_string_literal: true

class Buyers::Accounts::Bulk::ChangeStatesController < Buyers::Accounts::Bulk::BaseController
  ACTIONS = %w{ approve make_pending reject }

  before_action :humanized_actions, only: :new

  def new; end

  def create
    change_states
    handle_errors
    super
  end

  private

  alias subjects accounts

  def actions
    ACTIONS
  end
end

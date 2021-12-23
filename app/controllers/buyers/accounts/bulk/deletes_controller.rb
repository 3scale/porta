# frozen_string_literal: true

class Buyers::Accounts::Bulk::DeletesController < Buyers::Accounts::Bulk::BaseController
  def create
    delete_stuff
    handle_errors
  end
end

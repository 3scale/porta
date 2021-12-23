# frozen_string_literal: true

class Buyers::Applications::Bulk::DeletesController < Buyers::Applications::Bulk::BaseController
  def create
    delete_stuff
    handle_errors
  end
end

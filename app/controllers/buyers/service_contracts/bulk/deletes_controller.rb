# frozen_string_literal: true

class Buyers::ServiceContracts::Bulk::DeletesController < Buyers::ServiceContracts::Bulk::BaseController
  def create
    delete_stuff
    handle_errors
  end
end

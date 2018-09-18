class Buyers::Accounts::Bulk::DeletesController < Buyers::Accounts::Bulk::BaseController

  def new
  end

  def create
    @errors = []

    @accounts.each do |account|
      @errors << account unless account.destroy
    end

    handle_errors
  end

end

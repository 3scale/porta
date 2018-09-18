class Buyers::ServiceContracts::Bulk::DeletesController < Buyers::ServiceContracts::Bulk::BaseController

  def new

  end

  def create

    @errors = @service_contracts.map do |app|
      app unless app.destroy
    end.compact

    handle_errors
  end

end

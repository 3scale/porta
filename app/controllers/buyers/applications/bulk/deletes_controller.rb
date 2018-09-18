class Buyers::Applications::Bulk::DeletesController < Buyers::Applications::Bulk::BaseController

  def new

  end

  def create

    @errors = @applications.map do |app|
      app unless app.destroy
    end.compact

    handle_errors
  end

end

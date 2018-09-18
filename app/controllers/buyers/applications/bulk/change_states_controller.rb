class Buyers::Applications::Bulk::ChangeStatesController < Buyers::Applications::Bulk::BaseController
  ACTIONS = %w{ accept suspend resume }

  def new
    @actions = ACTIONS.map {|a| [a.humanize, a] }
  end

  def create
    @action = ( ACTIONS & [params[:change_states][:action]] ).first

    return unless @action.present?

    @errors = []
    @applications = @applications.to_a.reject do |application|
      !application.public_send("can_#{@action}?")
    end

    @applications.each do |application|
      @errors << application unless application.public_send(@action)
    end

    handle_errors
  end

end

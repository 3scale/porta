class Buyers::Accounts::Bulk::ChangeStatesController < Buyers::Accounts::Bulk::BaseController
  ACTIONS = %w{ approve make_pending reject }

  def new
    @actions = ACTIONS.map {|a| [a.humanize, a] }
  end

  def create
    @action = ( ACTIONS & [params[:change_states][:action]] ).first
    return unless @action.present?

    @errors = []
    @accounts = @accounts.to_a.reject do |account|
      !account.public_send("can_#{@action}?")
    end

    @accounts.each do |account|
      @errors << account unless account.public_send(@action)
    end

    handle_errors
  end

end

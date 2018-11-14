class Finance::Provider::LogEntriesController < Finance::Provider::BaseController

  include ThreeScale::Search::Helpers
  activate_menu :audience, :finance, :log_entries

  def index
    @search = ThreeScale::Search.new(params[:search] || params)

    @log_entries = current_account.log_entries.scope_search(@search, false)
                  .order_by(params[:sort], params[:direction])
                  .paginate(pagination_params)
  end

end

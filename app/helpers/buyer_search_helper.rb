module BuyerSearchHelper
  def account_search_states
    Account.search_states
  end

  def user_search_states
    User.search_states
  end

  def search_url
    "/buyer/search/#{@presenter.nil? ? "accounts" : @presenter.scope}"
  end

  def search_scope
    @presenter.scope if @presenter
  end

  def search_query
    @presenter.query if @presenter
  end

  def search_kind
    @presenter.kind if @presenter
  end

  def search_objects
    ["accounts", "users", "tokens"]
  end

  def options_for_select_without_line_ending(collection)
    options_for_select(collection).delete("\n")
  end

  def search_result(presenter)
    "#{ presenter.total_found } #{ (presenter.kind=="all")? "" : h(presenter.kind) } #{ h(presenter.scope) }".gsub(/  /,' ')
  end
end

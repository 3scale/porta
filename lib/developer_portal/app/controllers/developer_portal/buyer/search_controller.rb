module DeveloperPortal
  class Buyer::SearchController < DeveloperPortal::BaseController

    activate_menu :partners
    before_action :set_page_title

    def accounts
      @presenter = BuyerSearchPresenters::AccountsPresenter.new params, current_account
      render :action => 'results'
    end

    def users
      @presenter = BuyerSearchPresenters::UsersPresenter.new params, current_account
      render :action => 'results'
    end

    def tokens
      @presenter = BuyerSearchPresenters::TokensPresenter.new params
      render :action => 'results'
    end

    protected

    def set_page_title
      @page_title = "Search Results"
    end
  end
end

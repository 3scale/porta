#TODO: these presenters need tests
module BuyerSearchPresenters
  class SearchAbstractPresenter
    def initialize(params)
      @params = params
      @search_options = {
        :page => params[:page] || 1, :per_page => 20,
        :retry_stale => true, :match_mode => :extended }
    end

    def query
      ThinkingSphinx::Query.escape(@params[:q].to_s)
    end

    def kind
      @params[:kind]
    end

    def search
      @search ||= search! unless query.blank?
    end

    def search!
      model.search query, search_options
    end

    def total_found
      @total_found ||= if search
                         search.results[:total_found]
                       else
                         0
                       end
    end

    def search_options
      @search_options
    end
  end

  class ScopedWithAccountPresenter < SearchAbstractPresenter
    def initialize(params, provider_account)
      super params
      @provider_account = provider_account
    end

    def provider_account
      @provider_account
    end

    def search_options
      @search_options[:with] ||= { :provider_account_id => provider_account.id }
      if model.search_states.include?(kind)
        @search_options[:with][:state] = kind.to_crc32
      end
      @search_options
    end
  end

  class AccountsPresenter < ScopedWithAccountPresenter
    def scope
      "accounts"
    end

    private

    def model
      Account
    end
  end

  class UsersPresenter < ScopedWithAccountPresenter
    def scope
      "users"
    end

    private

    def model
      User
    end
  end

  class TokensPresenter < SearchAbstractPresenter
    def scope
      "tokens"
    end

    private

    def model
      ApplicationToken
    end
  end
end

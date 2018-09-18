class Account
  module Search
    extend ActiveSupport::Concern

    included do
      include ThreeScale::Search::Scopes

      self.allowed_sort_columns = %w{org_name state countries.name created_at plans.name}
      self.default_sort_column = :created_at
      self.default_sort_direction = :desc
      self.sort_columns_joins = {'countries.name' => :country, 'plans.name' => :bought_account_plan}

      self.allowed_search_scopes = [:query, :state, :country_id, :plan_id, :created_within]

      scope :by_created_within, ->(from, to) do
        where{ date(created_at).in(from..to) }
      end

      scope :by_query, ->(query) do
        case query.strip
          # TODO: if we add more, we can extract the keywords,
          # create another instance of ThreeScale::Search and chain them
          # to automate the by_* collapse
        when /\Auser_key:\s*#{Cinstance::USER_KEY_FORMAT}\z/ then by_user_key($1)
        else by_sphinx(query)
        end
      end

      scope :by_sphinx, ->(query) do
        # This can be potential bottleneck. It fetches ids from sphinx and then behaves just like normal AR scope.
        # Especially with multitenant because this will query for all accounts
        # there is workaround in thinking-sphinx - search method on association proxy,
        # but it does not work with other scopes
        where(:id => self.search_ids(query))
      end

      scope :by_user_key, -> (user_key) do
        joins(:bought_cinstances)
          .references(:bought_cinstances)
          .merge(Cinstance.by_user_key(user_key))
      end

      scope :by_plan_id, ->(plan_id) do
        joins(:bought_account_contract)
          .references(:bought_account_contract)
          .merge(AccountContract.by_plan_id(plan_id))
      end

      scope :by_country_id, ->(country_id) do
        where(:country_id => country_id)
      end
    end

    module ClassMethods
      def search_ids(query, options = {})
        return [] if query.blank?

        options = options
                  .reverse_merge(ids_only: true, per_page: 1_000_000, star: true,
                                 ignore_scopes: true, with: { })

        if (tenant_id = User.tenant_id)
          options.deep_merge!(with: { tenant_id: tenant_id })
        end

        search(ThinkingSphinx::Query.escape(query), options)
      end
    end
  end
end

# frozen_string_literal: true

require 'test_helper'
require 'will_paginate/active_record'
require 'three_scale/will_paginate_mysql_optimized_lookup'

class ThreeScale::WillPaginateMysqlOptimizedLookupTest < ActiveSupport::TestCase
  test 'the optimized lookup is prepended only for MySQL' do
    relation_methods = WillPaginate::ActiveRecord::RelationMethods
    optimized_lookup_is_prepended = relation_methods.ancestors.include?(ThreeScale::WillPaginateMysqlOptimizedLookup)

    assert_equal System::Database.mysql?, optimized_lookup_is_prepended
  end

  test 'paginated relations stay lazy and load the requested page through a CTE' do
    skip_unless_mysql_with_cte

    prefix = "optimized-lookup-#{SecureRandom.hex(8)}"
    countries = (1..5).map do |number|
      FactoryBot.create(:country, name: "#{prefix}-#{number}")
    end
    relation = nil

    assert_number_of_queries(0) do
      relation = Country.unscoped.where(id: countries.map(&:id)).order(name: :desc).paginate(page: 2, per_page: 2)
    end

    assert_not relation.loaded?

    page = nil
    queries = capture_sql_queries { page = relation.to_a }

    assert_equal 1, queries.grep(/\bWITH.+will_paginate_page_ids.+\sLIMIT\s+2\s+OFFSET\s+2.+\sSELECT\b/i).size
    assert_equal 1, queries.grep(/\A(?![\s\S]*will_paginate_page_ids)[\s\S]*?\bCOUNT\s*\(/i).size

    assert_equal countries.sort_by(&:name).reverse.drop(2).take(2).map(&:id), page.map(&:id)
    assert relation.loaded?

    assert_kind_of WillPaginate::Collection, page
    assert_equal 2, page.current_page
    assert_equal 2, page.per_page
    assert_equal 5, page.total_entries
    assert_equal 3, page.total_pages

    assert_number_of_queries(0) { relation.to_a }
  end

  test 'preloaded associations remain loaded after optimized lookup' do
    skip_unless_mysql_with_cte

    users = FactoryBot.create_list(:user_with_account, 2)
    # Order by id so page 2 (per_page: 1) deterministically returns the second user.
    second_user = users.max_by(&:id)
    relation = User.where(id: users.map(&:id)).order(:id).includes(:account).paginate(page: 2, per_page: 1, total_entries: 2)
    page = nil

    assert_number_of_queries(1, matching: /will_paginate_page_ids/) { page = relation.to_a }

    assert relation.loaded?
    assert page.first.association(:account).loaded?
    # Verify the correct account was loaded for the user that belongs on page 2.
    assert_equal second_user.account_id, page.first.account.id
  end

  test 'eager_load associations remain loaded after optimized lookup' do
    skip_unless_mysql_with_cte

    users = FactoryBot.create_list(:user_with_account, 2)
    # Order by id so page 2 (per_page: 1) deterministically returns the second user.
    second_user = users.max_by(&:id)
    relation = User.where(id: users.map(&:id)).eager_load(:account).order(:id).paginate(page: 2, per_page: 1, total_entries: 2)
    page = nil

    assert_number_of_queries(1, matching: /will_paginate_page_ids/) { page = relation.to_a }

    assert relation.loaded?
    assert page.first.association(:account).loaded?
    # Verify the correct account was loaded for the user that belongs on page 2.
    assert_equal second_user.account_id, page.first.account.id
  end

  test 'custom select is preserved on the outer query and the optimized lookup is still used' do
    skip_unless_mysql_with_cte

    prefix = "optimized-lookup-select-#{SecureRandom.hex(8)}"
    countries = (1..3).map { |n| FactoryBot.create(:country, name: "#{prefix}-#{n}") }
    relation = Country.unscoped.where(id: countries.map(&:id)).select(:id, :name).order(:name).paginate(page: 2, per_page: 1)
    page = nil

    queries = capture_sql_queries { page = relation.to_a }

    assert_equal 1, queries.grep(/\bWITH.+will_paginate_page_ids/i).size
    assert_equal [countries.second.id], page.map(&:id)
    assert_equal [countries.second.name], page.map(&:name)
  end

  test 'the optimized lookup is not used on page 1 (zero offset)' do
    skip_unless_mysql_with_cte

    user = FactoryBot.create(:user_with_account)
    relation = User.where(id: user.id).paginate(page: 1, per_page: 1, total_entries: 1)

    queries = capture_sql_queries { relation.to_a }

    assert_equal 0, queries.grep(/will_paginate_page_ids/i).size
  end

  test 'join-paginated relations use the two-query strategy' do
    skip_unless_mysql

    prefix = "optimized-lookup-join-#{SecureRandom.hex(8)}"
    users = (1..5).map { |n| FactoryBot.create(:user_with_account, username: "#{prefix}-#{n}") }
    third_user = users.sort_by(&:username)[2]

    relation = User.joins(:account)
                   .where(id: users.map(&:id))
                   .order(:username)
                   .paginate(page: 2, per_page: 2, total_entries: 5)
    page = nil
    queries = capture_sql_queries { page = relation.to_a }

    # Query 1: narrow ID scan with the join, no will_paginate_page_ids CTE.
    assert_equal 1, queries.grep(/\bSELECT\b.*\bLIMIT\s+2\s+OFFSET\s+2\b/i).grep_v(/will_paginate_page_ids/i).size
    # Query 2: full-row fetch by IDs, no join, no LIMIT/OFFSET.
    assert_equal 1, queries.grep(/\bFIELD\b/i).size

    assert_equal 2, page.size
    # Verify we got the right page (users sorted by username, page 2 of 2-per-page = indices 2..3).
    assert_includes page.map(&:id), third_user.id

    assert_kind_of WillPaginate::Collection, page
    assert_equal 2, page.current_page
    assert_equal 2, page.per_page
    assert_equal 5, page.total_entries
  end

  test 'join-paginated relations preserve preloaded associations' do
    skip_unless_mysql

    users = FactoryBot.create_list(:user_with_account, 2)
    second_user = users.max_by(&:id)
    relation = User.joins(:account)
                   .where(id: users.map(&:id))
                   .includes(:account)
                   .order(:id)
                   .paginate(page: 2, per_page: 1, total_entries: 2)
    page = nil

    queries = capture_sql_queries { page = relation.to_a }

    # Two queries: ID scan + full-row fetch (with includes).
    assert queries.size >= 2
    assert_equal 0, queries.grep(/will_paginate_page_ids/i).size
    assert page.first.association(:account).loaded?
    assert_equal second_user.account_id, page.first.account.id
  end

  test 'join-paginated relations can filter and order by joined tables and use raw SQL joins' do
    skip_unless_mysql

    users = FactoryBot.create_list(:user_with_account, 5)
    account_ids = users.map(&:account_id)
    expected_ids = users.sort_by(&:account_id).reverse.drop(2).take(2).map(&:id)

    {
      'association join' => User.joins(:account),
      'raw SQL join' => User.joins('INNER JOIN accounts ON accounts.id = users.account_id')
    }.each do |name, base_relation|
      relation = base_relation.where(accounts: { id: account_ids }).order('accounts.id DESC').paginate(page: 2, per_page: 2)
      page = nil
      queries = capture_sql_queries { page = relation.to_a }

      assert_equal 1, queries.grep(/\bFIELD\(/i).size, name
      assert_equal expected_ids, page.map(&:id), name
    end
  end

  test 'join-paginated relations with a custom select use the standard query' do
    skip_unless_mysql

    users = FactoryBot.create_list(:user_with_account, 2)
    relation = User.joins(:account)
                   .select('users.*, accounts.org_name AS joined_org_name')
                   .where(id: users.map(&:id))
                   .paginate(page: 2, per_page: 1, total_entries: 2)

    assert_number_of_queries(1, matching: /\A(?![\s\S]*FIELD\()[\s\S]*\bLIMIT\s+1\s+OFFSET\s+1\b/i) { relation.to_a }
  end

  test 'the optimized lookup is not used for unsafe query shapes' do
    skip_unless_mysql

    users = FactoryBot.create_list(:user_with_account, 2)
    unsafe_relations = {
      'references' => User.includes(:account).references(:account),
      'grouping' => User.select(:state).group(:state),
      'having' => User.select(:state).group(:state).having('COUNT(*) > 0'),
      'distinct' => User.distinct,
      'custom from' => User.from('users'),
      'lock' => User.lock
    }
    unsafe_relations['existing CTE'] = User.with(other_users: User.select(:id)) if User.connection.supports_common_table_expressions?

    unsafe_relations.each_value do |base_relation|
      relation = base_relation.where(id: users.map(&:id)).paginate(page: 2, per_page: 1, total_entries: 2)

      assert_number_of_queries(
        1,
        matching: /\A(?![\s\S]*will_paginate_page_ids)[\s\S]*\b(?:WITH|SELECT)\b[\s\S]*\bLIMIT\s+1\s+OFFSET\s+1\b/i
      ) { relation.to_a }
    end
  end

  test 'split queries are used without CTE support' do
    skip_unless_mysql

    users = FactoryBot.create_list(:user_with_account, 3).sort_by(&:id)
    relation = User.where(id: users.map(&:id)).order(:id).paginate(page: 2, per_page: 1, total_entries: 3)
    relation.connection.stubs(:supports_common_table_expressions?).returns(false)
    page = nil

    queries = capture_sql_queries { page = relation.to_a }

    assert_equal 0, queries.grep(/will_paginate_page_ids/i).size
    assert_equal 1, queries.grep(/\bFIELD\(/i).size
    assert_equal [users.second.id], page.map(&:id)
  end

  # Association loading directives on each code path.  Each combination must use the optimized lookup
  # (CTE or split queries), return the right page and leave the association loaded for the page record.
  PATHS = {
    cte: 'CTE',
    split_with_joins: 'split queries (relation with joins)',
    split_without_cte: 'split queries (no joins, CTE unsupported)'
  }.freeze

  %i[includes preload eager_load].each do |loader|
    PATHS.each do |path, description|
      test "#{loader} loads the association on the right page record with #{description}" do
        users = create_users_with_accounts(%w[n-a n-b n-c n-d])
        relation = base_relation_for(path, users).public_send(loader, :account).order(:id).paginate(page: 2, per_page: 1)

        page = nil
        queries = capture_sql_queries { page = relation.to_a }

        assert_optimized_lookup_used(path, queries)
        assert_equal [users.second.id], page.map(&:id)
        assert page.first.association(:account).loaded?
        assert_equal users.second.account_id, page.first.account.id
      end

      test "#{loader} does not trigger N+1 queries for a page with several records with #{description}" do
        users = create_users_with_accounts(%w[n-a n-b n-c n-d])
        relation = base_relation_for(path, users).public_send(loader, :account).order(:id).paginate(page: 2, per_page: 2)

        page = nil
        queries = capture_sql_queries { page = relation.to_a }
        queries += capture_sql_queries { page.each { |user| user.account.org_name } }

        assert_equal users.drop(2).map(&:id), page.map(&:id)
        assert_equal 0, queries.grep(/FROM `accounts` WHERE `accounts`\.`id` = \d+ LIMIT 1/).size, queries.join("\n")
      end
    end
  end

  test 'eager_load of a has_many is converted to preload, keeping the page boundary on parents' do
    skip_unless_mysql_with_cte

    provider = FactoryBot.create(:provider_account)
    accounts = FactoryBot.create_list(:buyer_account, 3, provider_account: provider).sort_by(&:id)
    accounts.each { |account| FactoryBot.create_list(:user, 2, account: account) }
    relation = Account.where(id: accounts.map(&:id)).eager_load(:users).order(:id).paginate(page: 2, per_page: 1)
    page = nil

    queries = capture_sql_queries { page = relation.to_a }

    assert_equal 1, queries.grep(/\bWITH.+will_paginate_page_ids/i).size, queries.join("\n")
    assert_equal 0, queries.grep(/LEFT OUTER JOIN/i).size, queries.join("\n")
    assert_equal [accounts.second.id], page.map(&:id)
    assert page.first.association(:users).loaded?
    assert_equal accounts.second.users.count, page.first.users.size
    assert_operator page.first.users.size, :>, 1
  end

  test 'paginating converts eager_load to preload immediately so that callers can strip it' do
    relation = User.eager_load(:account).paginate(page: 2, per_page: 1)

    assert_empty relation.eager_load_values
    assert_equal [:account], relation.preload_values
    assert_empty relation.unscope(:includes, :preload).preload_values
  end

  # Names are assigned in id order so that filtering and ordering by name give a different page than plain id order.
  ACCOUNT_NAMES = %w[n-b n-d n-a n-c].freeze

  # A condition or order on the association table needs that table to be joined for the page query.
  # `eager_load` is not such a join once a relation is paginated, the caller must be explicit about it.
  CONDITIONS_ON_ASSOCIATION = {
    'eager_load with explicit joins and a string where' => {
      relation: ->(rel) { rel.eager_load(:account).joins(:account).where("accounts.org_name IN ('n-d', 'n-a', 'n-c')").order(:id) },
      expected: ->(users) { [users[2].id] }, # n-d, n-a, n-c => users 1, 2, 3 => second is user 2
      optimized: true
    },
    'eager_load with explicit joins and a hash where' => {
      relation: ->(rel) { rel.eager_load(:account).joins(:account).where(accounts: { org_name: %w[n-d n-a n-c] }).order(:id) },
      expected: ->(users) { [users[2].id] },
      optimized: true
    },
    'eager_load with explicit joins and an order by the association table' => {
      relation: ->(rel) { rel.eager_load(:account).joins(:account).order(Arel.sql('accounts.org_name DESC')) },
      expected: ->(users) { [users[3].id] }, # n-d(1), n-c(3), n-b(0), n-a(2) => second is user 3
      optimized: true
    },
    'includes with a hash where on the included table (implicit references)' => {
      relation: ->(rel) { rel.includes(:account).where(accounts: { org_name: %w[n-d n-a n-c] }).order(:id) },
      expected: ->(users) { [users[2].id] },
      optimized: false
    },
    'includes with explicit references and a string where' => {
      relation: ->(rel) { rel.includes(:account).references(:accounts).where("accounts.org_name IN ('n-d', 'n-a', 'n-c')").order(:id) },
      expected: ->(users) { [users[2].id] },
      optimized: false
    },
    'includes with explicit references and an order by the association table' => {
      relation: ->(rel) { rel.includes(:account).references(:accounts).order(Arel.sql('accounts.org_name DESC')) },
      expected: ->(users) { [users[3].id] },
      optimized: false
    }
  }.freeze

  CONDITIONS_ON_ASSOCIATION.each do |condition, definition|
    test "#{condition} returns the right page and keeps the association loaded" do
      skip_unless_mysql

      users = create_users_with_accounts(ACCOUNT_NAMES)
      relation = definition[:relation].call(User.where(id: users.map(&:id))).paginate(page: 2, per_page: 1)
      page = nil

      queries = capture_sql_queries { page = relation.to_a }

      assert_equal definition[:expected].call(users), page.map(&:id)
      assert page.first.association(:account).loaded?
      # A JOIN needed for selecting the page keeps the relation out of the optimized lookup.
      assert_equal definition[:optimized] ? 1 : 0, queries.grep(/\bFIELD\(/i).size, queries.join("\n")
    end
  end

  # THE FAILURES BELOW DOCUMENT CURRENT BEHAVIOR, NOT A REQUIREMENT.
  #
  # `eager_load` is converted to `preload` once a relation is paginated (see EagerLoadToPreload), so the
  # LEFT OUTER JOIN it would have added no longer exists to satisfy a condition or an order that refers to
  # the association table.  Such a relation fails with an unknown column error, instead of being quietly
  # served by a different query.  Callers have to be explicit about the table: add `joins`, or use `includes`
  # with `references`.  Each test shows the failure and then the same query working once that is done.
  #
  # If a way is found to support this, for example by keeping the JOIN of the eager load in the ID scan
  # without breaking the page boundary of has_many associations, then the failing part of these tests is
  # expected to change or go away.  Nothing but the current behavior depends on it failing.
  CONDITIONS_ON_EAGER_LOADED_TABLE = {
    'a where hash' => {
      add: ->(rel) { rel.where(accounts: { org_name: %w[n-d n-a n-c] }).order(:id) },
      expected: ->(users) { [users[2].id] }
    },
    'a where string' => {
      add: ->(rel) { rel.where("accounts.org_name IN ('n-d', 'n-a', 'n-c')").order(:id) },
      expected: ->(users) { [users[2].id] }
    },
    'an order' => {
      add: ->(rel) { rel.order(Arel.sql('accounts.org_name DESC')) },
      expected: ->(users) { [users[3].id] }
    }
  }.freeze

  CONDITIONS_ON_EAGER_LOADED_TABLE.each do |condition, definition|
    PATHS.each do |path, description|
      test "eager_load with #{condition} on the eager loaded table fails, and works with joins or references, with #{description}" do
        users = create_users_with_accounts(ACCOUNT_NAMES)
        base = relation_not_joining_accounts(path, users)
        paginate = ->(relation) { definition[:add].call(relation).paginate(page: 2, per_page: 1) }

        # The failure: nothing joins the table the condition refers to.
        error = assert_raises(ActiveRecord::StatementInvalid) { paginate.call(base.eager_load(:account)).to_a }
        assert_match(/Unknown column 'accounts\.org_name'/, error.message)

        # The fix: an explicit JOIN, which the ID scan carries.
        page = paginate.call(base.eager_load(:account).joins(:account)).to_a
        assert_equal definition[:expected].call(users), page.map(&:id)
        assert page.first.association(:account).loaded?

        # The fix: `includes` with `references`, which uses the usual query with a JOIN.
        page = paginate.call(base.includes(:account).references(:accounts)).to_a
        assert_equal definition[:expected].call(users), page.map(&:id)
        assert page.first.association(:account).loaded?
      end
    end
  end

  # `references` is not a fix for `eager_load`: it makes AR join only for `includes`, and `eager_load`
  # has become a `preload` by now.  Current behavior as well, see above.
  test 'eager_load with references on the eager loaded table still fails' do
    skip_unless_mysql

    users = create_users_with_accounts(ACCOUNT_NAMES)
    relation = User.where(id: users.map(&:id)).eager_load(:account).references(:accounts)
                   .where(accounts: { org_name: %w[n-d n-a n-c] }).order(:id).paginate(page: 2, per_page: 1)

    error = assert_raises(ActiveRecord::StatementInvalid) { relation.to_a }

    assert_match(/Unknown column 'accounts\.org_name'/, error.message)
  end

  private

  # A relation that does not join the accounts table, so that only what a test adds can satisfy a condition on it.
  # The relation with joins joins it under an alias, as joining the table itself would satisfy the condition.
  def relation_not_joining_accounts(path, users)
    relation = base_relation_for(path, users)
    return relation unless path == :split_with_joins

    User.where(id: users.map(&:id)).joins('INNER JOIN accounts joined_accounts ON joined_accounts.id = users.account_id')
  end

  def create_users_with_accounts(org_names)
    users = FactoryBot.create_list(:user_with_account, org_names.size).sort_by(&:id)
    users.zip(org_names) { |user, name| user.account.update_columns(org_name: name) }
    users
  end

  def base_relation_for(path, users)
    relation = User.where(id: users.map(&:id))

    case path
    when :cte
      skip_unless_mysql_with_cte
    when :split_with_joins
      skip_unless_mysql
      return relation.joins(:account)
    when :split_without_cte
      skip_unless_mysql
      relation.connection.stubs(:supports_common_table_expressions?).returns(false)
    end

    relation
  end

  def assert_optimized_lookup_used(path, queries)
    if path == :cte
      assert_equal 1, queries.grep(/\bWITH.+will_paginate_page_ids/i).size, queries.join("\n")
    else
      assert_equal 0, queries.grep(/will_paginate_page_ids/i).size, queries.join("\n")
      assert_equal 1, queries.grep(/\bFIELD\(/i).size, queries.join("\n")
    end
  end

  def skip_unless_mysql
    skip 'requires MySQL' unless System::Database.mysql?
  end

  def skip_unless_mysql_with_cte
    skip_unless_mysql
    skip 'requires CTE support' unless ActiveRecord::Base.connection.supports_common_table_expressions?
  end
end
